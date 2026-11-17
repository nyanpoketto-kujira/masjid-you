import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:shared_models/shared_models.dart';

/// Batas dimensi terbesar logo untuk jalur Bluetooth (ADR-032).
///
/// Logo tampil di header TV sebagai kotak 1:1 setinggi ±76 dp —
/// 512 px sudah jauh di atas kebutuhan tampilnya, sementara ukuran
/// berkasnya menyusut drastis dibanding foto asli dari galeri.
const int kLogoBluetoothMaxDimension = 512;

/// Kualitas JPEG logo jalur Bluetooth bila gambar tanpa alpha.
const int kLogoBluetoothJpegQuality = 85;

/// Siapkan bytes logo untuk jalur Bluetooth: perkecil dimensi
/// terbesar ke maks [kLogoBluetoothMaxDimension] px.
///
/// Berbeda dari kompresi gambar latar (selalu JPEG), logo **menjaga
/// transparansi**: gambar ber-alpha di-encode ulang sebagai PNG
/// (logo masjid umumnya PNG transparan — JPEG akan menempelkan latar
/// buram di belakangnya), gambar tanpa alpha sebagai JPEG kualitas
/// [kLogoBluetoothJpegQuality]. Gambar yang sudah cukup kecil
/// dikembalikan apa adanya (tidak di-encode ulang).
///
/// Fail-soft: gambar yang tidak bisa di-decode dikembalikan apa
/// adanya. Logo ASLI di HP tidak pernah diubah fungsi ini — ini
/// hanya salinan kirim Bluetooth; jalur WebSocket selalu asli.
Uint8List prepareLogoBytesForBluetooth(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final maxDimension =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    if (maxDimension <= kLogoBluetoothMaxDimension) return bytes;
    final resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: kLogoBluetoothMaxDimension)
        : img.copyResize(decoded, height: kLogoBluetoothMaxDimension);
    final encoded = decoded.hasAlpha
        ? img.encodePng(resized)
        : img.encodeJpg(resized, quality: kLogoBluetoothJpegQuality);
    if (encoded.isEmpty) return bytes;
    return Uint8List.fromList(encoded);
  } catch (_) {
    return bytes;
  }
}

/// Terapkan [prepareLogoBytesForBluetooth] ke salinan base64 (untuk
/// payload sync). String rusak dikembalikan apa adanya.
String prepareLogoBase64ForBluetooth(String base64Image) {
  if (base64Image.isEmpty) return base64Image;
  try {
    final bytes = base64Decode(base64Image);
    return base64Encode(prepareLogoBytesForBluetooth(bytes));
  } catch (_) {
    return base64Image;
  }
}

/// Salinan [packet] `updateLogo` dengan logo disiapkan untuk jalur
/// Bluetooth. Paket asli tidak diubah; aksi lain dan logo kosong
/// (penghapusan) dikembalikan apa adanya.
SyncPacket compressedLogoPacket(SyncPacket packet) {
  if (packet.action != SyncAction.updateLogo) return packet;
  final rawLogo = packet.payload['logoBase64'];
  if (rawLogo is! String || rawLogo.isEmpty) return packet;
  return SyncPacket(
    action: packet.action,
    payload: {
      ...packet.payload,
      'logoBase64': prepareLogoBase64ForBluetooth(rawLogo),
    },
  );
}
