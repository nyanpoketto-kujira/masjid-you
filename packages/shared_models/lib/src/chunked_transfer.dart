import 'dart:math';

import 'sync_packet.dart';

/// Transfer ter-chunk untuk payload besar via Bluetooth (ADR-031).
///
/// Framing RFCOMM yang ada (panjang 4-byte + satu JSON utuh) tetap dipakai
/// per paket; chunking hidup di lapisan [SyncPacket]: paket yang JSON-nya
/// melebihi [kChunkingThreshold] dipecah menjadi beberapa paket
/// [SyncAction.chunkedData] yang masing-masing membawa potongan string
/// JSON asli. Penerima merangkai ulang dengan [ChunkReassembler] dan baru
/// meneruskan paket aslinya setelah lengkap — gambar tidak pernah
/// diterapkan setengah-setengah.
///
/// Paket kecil TIDAK berubah sama sekali: tetap satu [SyncPacket] biasa
/// lewat jalur yang sudah ada (kompatibel dua arah dengan versi lama).

/// Panjang data (karakter JSON) per chunk: 32 KB — cukup besar agar
/// overhead metadata kecil, cukup kecil agar progress terasa dan satu
/// chunk yang hilang murah dikirim ulang sebagai transfer baru.
const int kChunkDataLength = 32 * 1024;

/// Ambang ukuran JSON (karakter) yang memicu chunking: 64 KB. Paket
/// config/konten biasa jauh di bawah ini; yang melewatinya praktis hanya
/// payload bergambar.
const int kChunkingThreshold = 64 * 1024;

/// Batas maksimum chunk per transfer di sisi penerima (pengaman memori):
/// 2048 x 32 KB = +/- 64 MB JSON. Transfer yang mengklaim lebih dari ini
/// dibuang sebagai tidak valid.
const int kMaxChunksPerTransfer = 2048;

int _transferCounter = 0;
final Random _transferRandom = Random();

/// Buat id transfer baru yang unik untuk sesi proses ini.
String newChunkTransferId() {
  _transferCounter++;
  final randomPart = _transferRandom.nextInt(1 << 32).toRadixString(16);
  return 'tx-${DateTime.now().millisecondsSinceEpoch}-'
      '$_transferCounter-$randomPart';
}

/// Hasil [encodeChunkedTransfer]: daftar paket yang harus dikirim berurutan.
class ChunkedEncoding {
  /// Paket-paket siap kirim. Bila [chunked] `false`, berisi tepat satu
  /// paket: paket aslinya, tanpa perubahan.
  final List<SyncPacket> packets;

  /// `true` bila paket asli dipecah menjadi paket `chunkedData`.
  final bool chunked;

  const ChunkedEncoding(this.packets, this.chunked);
}

/// Pecah [packet] menjadi chunk bila JSON-nya melebihi
/// [kChunkingThreshold]; di bawah ambang, kembalikan paket apa adanya.
ChunkedEncoding encodeChunkedTransfer(SyncPacket packet, {String? transferId}) {
  final json = packet.toJson();
  if (json.length <= kChunkingThreshold) {
    return ChunkedEncoding([packet], false);
  }
  final total = (json.length / kChunkDataLength).ceil();
  final id = transferId ?? newChunkTransferId();
  return ChunkedEncoding(
    [
      for (var seq = 0; seq < total; seq++)
        SyncPacket(
          action: SyncAction.chunkedData,
          payload: {
            'transferId': id,
            'action': packet.action.name,
            'seq': seq,
            'total': total,
            'data': json.substring(
              seq * kChunkDataLength,
              min((seq + 1) * kChunkDataLength, json.length),
            ),
          },
        ),
    ],
    true,
  );
}

/// Perangkai ulang chunk di sisi penerima.
///
/// Satu transfer aktif pada satu waktu (pengirim di sistem ini tunggal:
/// Remote DKM). Chunk dari transfer baru menggantikan transfer lama yang
/// belum selesai. Perilaku gagal — semuanya membuang transfer dan mengisi
/// [lastError], TIDAK pernah menghasilkan paket parsial:
///
/// - metadata hilang / tipe salah / `total` di luar 1..[kMaxChunksPerTransfer]
/// - `total`/`action` berubah di tengah transfer yang sama
/// - nomor urut di luar rentang
/// - chunk duplikat dengan isi berbeda (duplikat identik diabaikan)
///
/// Timeout tidak diterapkan: transfer yang tidak lengkap diam-diam
/// digantikan transfer berikutnya atau dibuang lewat [reset].
class ChunkReassembler {
  String? _transferId;
  String? _actionName;
  int _total = 0;
  final Map<int, String> _chunks = {};

  /// Deskripsi kegagalan transfer terakhir yang dibuang; `null` bila
  /// belum pernah gagal atau transfer baru yang valid sudah dimulai.
  String? lastError;

  /// `true` selama ada transfer yang belum lengkap.
  bool get hasPendingTransfer => _transferId != null;

  /// Jumlah chunk unik yang sudah diterima untuk transfer aktif.
  int get receivedCount => _chunks.length;

  /// Total chunk yang diharapkan untuk transfer aktif (0 = tidak ada).
  int get expectedTotal => _total;

  void reset() {
    _transferId = null;
    _actionName = null;
    _total = 0;
    _chunks.clear();
  }

  SyncPacket? _fail(String message) {
    lastError = message;
    reset();
    return null;
  }

  /// Masukkan satu paket chunk. Mengembalikan paket asli yang sudah
  /// utuh tepat saat chunk terakhir melengkapi transfer; selain itu
  /// `null` (termasuk untuk semua kasus gagal).
  SyncPacket? addChunk(SyncPacket packet) {
    if (packet.action != SyncAction.chunkedData) {
      return _fail('bukan paket chunkedData');
    }
    final payload = packet.payload;
    final transferId = payload['transferId'];
    final actionName = payload['action'];
    final seq = payload['seq'];
    final total = payload['total'];
    final data = payload['data'];
    if (transferId is! String ||
        transferId.isEmpty ||
        actionName is! String ||
        seq is! int ||
        total is! int ||
        data is! String) {
      return _fail('metadata chunk tidak valid');
    }
    if (total < 1 || total > kMaxChunksPerTransfer) {
      return _fail('total chunk di luar batas: $total');
    }
    if (data.length > kChunkDataLength) {
      return _fail('chunk melebihi ukuran maksimum');
    }

    if (_transferId != null && _transferId != transferId) {
      // Transfer baru menggantikan yang belum selesai (pengirim tunggal).
      reset();
    }
    if (_transferId == null) {
      _transferId = transferId;
      _actionName = actionName;
      _total = total;
      lastError = null;
    } else if (total != _total || actionName != _actionName) {
      return _fail('metadata berubah di tengah transfer');
    }

    if (seq < 0 || seq >= _total) {
      return _fail('nomor urut chunk di luar rentang: $seq');
    }
    final existing = _chunks[seq];
    if (existing != null && existing != data) {
      return _fail('chunk duplikat dengan isi berbeda pada urutan $seq');
    }
    _chunks[seq] = data;

    if (_chunks.length < _total) return null;
    final joined = StringBuffer();
    for (var i = 0; i < _total; i++) {
      joined.write(_chunks[i]);
    }
    reset();
    try {
      return SyncPacket.fromJson(joined.toString());
    } catch (_) {
      return _fail('hasil rangkaian bukan JSON paket yang valid');
    }
  }
}
