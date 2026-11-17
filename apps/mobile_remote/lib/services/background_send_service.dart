import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Jalur transport pengiriman gambar latar ke TV.
enum BackgroundSendTransport { bluetooth, websocket }

/// Keputusan kompresi gambar latar saat kirim (ADR-031) — fungsi murni,
/// teruji tanpa UI:
///
/// - Bluetooth + opsi "tanpa kompresi" MATI (default) -> kompres.
/// - Bluetooth + opsi "tanpa kompresi" AKTIF -> kirim asli.
/// - WebSocket -> selalu asli (LAN cepat, tidak perlu kompres).
bool shouldCompressBackgroundForSend({
  required BackgroundSendTransport transport,
  required bool sendUncompressed,
}) {
  return transport == BackgroundSendTransport.bluetooth && !sendUncompressed;
}

/// Batas dimensi terbesar hasil kompresi (piksel) — cukup untuk layar
/// TV 1080p/4K dari jarak pandang normal, jauh lebih ringan di RFCOMM.
const int kBackgroundCompressMaxDimension = 1920;

/// Kualitas JPEG hasil kompresi (0-100).
const int kBackgroundCompressJpegQuality = 80;

/// Kompresi bytes gambar untuk pengiriman Bluetooth: decode, perkecil
/// bila dimensi terbesar melebihi [kBackgroundCompressMaxDimension],
/// lalu encode ulang sebagai JPEG kualitas
/// [kBackgroundCompressJpegQuality].
///
/// Fail-soft: gambar yang tidak bisa di-decode dikembalikan apa adanya,
/// dan bila hasil kompresi ternyata tidak lebih kecil (mis. sumber
/// sudah JPEG mungil), bytes asli yang dipakai. Gambar ASLI di HP tidak
/// pernah diubah fungsi ini — kompresi hanya untuk salinan kirim.
Uint8List compressBackgroundImageBytes(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    var working = decoded;
    final maxDimension =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    if (maxDimension > kBackgroundCompressMaxDimension) {
      working = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: kBackgroundCompressMaxDimension)
          : img.copyResize(decoded, height: kBackgroundCompressMaxDimension);
    }
    final encoded = img.encodeJpg(
      working,
      quality: kBackgroundCompressJpegQuality,
    );
    if (encoded.isEmpty || encoded.length >= bytes.length) return bytes;
    return Uint8List.fromList(encoded);
  } catch (_) {
    return bytes;
  }
}

/// Terapkan [compressBackgroundImageBytes] ke salinan base64 (untuk
/// payload sync). String rusak dikembalikan apa adanya.
String compressBackgroundBase64(String base64Image) {
  if (base64Image.isEmpty) return base64Image;
  try {
    final bytes = base64Decode(base64Image);
    return base64Encode(compressBackgroundImageBytes(bytes));
  } catch (_) {
    return base64Image;
  }
}

/// Salinan [packet] `updateBackgroundImages` dengan setiap gambar
/// terkompresi (untuk jalur Bluetooth). Paket asli tidak diubah; aksi
/// lain dikembalikan apa adanya.
SyncPacket compressedBackgroundPacket(SyncPacket packet) {
  if (packet.action != SyncAction.updateBackgroundImages) return packet;
  final rawImages = packet.payload['images'];
  if (rawImages is! List) return packet;
  return SyncPacket(
    action: packet.action,
    payload: {
      ...packet.payload,
      'images': [
        for (final entry in rawImages)
          if (entry is Map)
            {
              for (final e in entry.entries) '${e.key}': e.value,
              if (entry['base64Image'] is String)
                'base64Image':
                    compressBackgroundBase64(entry['base64Image'] as String),
            }
          else
            entry,
      ],
    },
  );
}

/// Preferensi pengiriman gambar latar yang tersimpan lokal di HP:
/// opsi "kirim tanpa kompresi" untuk jalur Bluetooth (ADR-031).
/// Default `false` = kompresi AKTIF (yang dianjurkan untuk RFCOMM).
class BackgroundSendPreferences {
  BackgroundSendPreferences._();

  static const String sendUncompressedKey = 'bg_send_uncompressed';

  static Future<bool> loadSendUncompressed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(sendUncompressedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveSendUncompressed(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(sendUncompressedKey, value);
    } catch (_) {
      // Plugin tidak tersedia (mis. test) -> preferensi hanya di memori.
    }
  }
}
