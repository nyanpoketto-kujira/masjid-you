import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_remote/services/logo_send_service.dart';
import 'package:shared_models/shared_models.dart';

/// Tes ADR-032: penyiapan logo untuk jalur Bluetooth — diperkecil ke
/// maks 512 px, transparansi dijaga (PNG ber-alpha tidak di-JPEG),
/// fail-soft, dan transformasi paket `updateLogo`.
Uint8List _png({required int size, required bool alpha}) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(
    image,
    color: alpha
        ? img.ColorRgba8(0, 128, 0, 128)
        : img.ColorRgba8(0, 128, 0, 255),
  );
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List _jpg({required int size}) {
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(200, 30, 30));
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

bool _isPng(Uint8List bytes) =>
    bytes.length > 4 &&
    bytes[0] == 0x89 &&
    bytes[1] == 0x50 && // P
    bytes[2] == 0x4E && // N
    bytes[3] == 0x47; // G

bool _isJpeg(Uint8List bytes) =>
    bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

void main() {
  group('prepareLogoBytesForBluetooth', () {
    test('PNG besar ber-alpha -> diperkecil <= 512 dan tetap PNG', () {
      final prepared = prepareLogoBytesForBluetooth(_png(size: 1200, alpha: true));
      final decoded = img.decodeImage(prepared)!;
      expect(decoded.width, kLogoBluetoothMaxDimension);
      expect(decoded.height, kLogoBluetoothMaxDimension);
      expect(_isPng(prepared), isTrue);
      expect(decoded.hasAlpha, isTrue);
    });

    test('JPEG besar tanpa alpha -> diperkecil <= 512 dan tetap JPEG', () {
      final prepared = prepareLogoBytesForBluetooth(_jpg(size: 1024));
      final decoded = img.decodeImage(prepared)!;
      expect(decoded.width, kLogoBluetoothMaxDimension);
      expect(_isJpeg(prepared), isTrue);
    });

    test('gambar kecil (<= 512) dikembalikan apa adanya', () {
      final small = _png(size: 128, alpha: true);
      expect(prepareLogoBytesForBluetooth(small), small);
    });

    test('bytes bukan gambar dikembalikan apa adanya (fail-soft)', () {
      final junk = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(prepareLogoBytesForBluetooth(junk), junk);
    });
  });

  group('prepareLogoBase64ForBluetooth', () {
    test('base64 gambar besar -> base64 hasil perkecilan', () {
      final source = base64Encode(_jpg(size: 900));
      final prepared = prepareLogoBase64ForBluetooth(source);
      final decoded = img.decodeImage(base64Decode(prepared))!;
      expect(decoded.width, kLogoBluetoothMaxDimension);
    });

    test('string rusak dikembalikan apa adanya', () {
      expect(prepareLogoBase64ForBluetooth('!!!bukan-base64!!!'),
          '!!!bukan-base64!!!');
      expect(prepareLogoBase64ForBluetooth(''), '');
    });
  });

  group('compressedLogoPacket', () {
    test('paket updateLogo: logo besar diperkecil di salinan paket', () {
      final bigLogo = base64Encode(_png(size: 1000, alpha: true));
      final packet = SyncPacket(
        action: SyncAction.updateLogo,
        payload: {'logoBase64': bigLogo},
      );
      final compressed = compressedLogoPacket(packet);
      expect(compressed.action, SyncAction.updateLogo);
      final out = compressed.payload['logoBase64'] as String;
      expect(out, isNot(bigLogo));
      final decoded = img.decodeImage(base64Decode(out))!;
      expect(decoded.width, kLogoBluetoothMaxDimension);
      // Paket asli tidak diubah.
      expect(packet.payload['logoBase64'], bigLogo);
    });

    test('paket updateLogo tanpa logo (penghapusan) tidak diubah', () {
      const packet = SyncPacket(
        action: SyncAction.updateLogo,
        payload: {'logoBase64': null},
      );
      expect(compressedLogoPacket(packet), same(packet));
    });

    test('aksi lain tidak diubah', () {
      final packet = SyncPacket(
        action: SyncAction.updateConfig,
        payload: {'logoBase64': base64Encode(_jpg(size: 900))},
      );
      expect(compressedLogoPacket(packet), same(packet));
    });
  });
}
