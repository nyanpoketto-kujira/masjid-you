import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_remote/services/background_send_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tes ADR-031: keputusan kompresi kirim gambar latar, kompresi
/// sungguhan (pure Dart), dan preferensi opsi tanpa kompresi.
void main() {
  group('shouldCompressBackgroundForSend (keputusan kirim)', () {
    test('Bluetooth + kompresi aktif (default) -> kompres', () {
      expect(
        shouldCompressBackgroundForSend(
          transport: BackgroundSendTransport.bluetooth,
          sendUncompressed: false,
        ),
        isTrue,
      );
    });

    test('Bluetooth + opsi tanpa kompresi -> kirim asli', () {
      expect(
        shouldCompressBackgroundForSend(
          transport: BackgroundSendTransport.bluetooth,
          sendUncompressed: true,
        ),
        isFalse,
      );
    });

    test('WebSocket selalu asli, apa pun opsinya', () {
      expect(
        shouldCompressBackgroundForSend(
          transport: BackgroundSendTransport.websocket,
          sendUncompressed: false,
        ),
        isFalse,
      );
      expect(
        shouldCompressBackgroundForSend(
          transport: BackgroundSendTransport.websocket,
          sendUncompressed: true,
        ),
        isFalse,
      );
    });
  });

  group('compressBackgroundImageBytes', () {
    /// Foto JPEG 2400x1200 kualitas tinggi dengan gradien halus
    /// menyerupai foto kamera sungguhan (input realistis kompresi:
    /// file JPEG besar dari galeri HP).
    Uint8List bigPhotoJpg() {
      final image = img.Image(width: 2400, height: 1200);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixelRgb(
            x,
            y,
            (127 + 127 * (x / 2400)).round(),
            (127 + 127 * (y / 1200)).round(),
            ((x + y) ~/ 8) % 256,
          );
        }
      }
      return Uint8List.fromList(img.encodeJpg(image, quality: 97));
    }

    test('gambar besar diperkecil ke maks 1920px + JPEG lebih ringan', () {
      final original = bigPhotoJpg();
      final compressed = compressBackgroundImageBytes(original);

      expect(compressed.length, lessThan(original.length));
      final decoded = img.decodeImage(compressed);
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(1920));
      expect(decoded.height, lessThanOrEqualTo(1920));
      // Rasio aspek dipertahankan (2400x1200 -> 1920x960).
      expect(decoded.width, 1920);
      expect(decoded.height, 960);
      // Hasilnya JPEG (SOI marker FF D8).
      expect(compressed[0], 0xFF);
      expect(compressed[1], 0xD8);
    });

    test('gambar kecil valid tetap bisa di-decode setelah proses', () {
      final small = img.Image(width: 64, height: 32);
      img.fill(small, color: img.ColorRgb8(10, 120, 60));
      final png = Uint8List.fromList(img.encodePng(small));
      final result = compressBackgroundImageBytes(png);
      final decoded = img.decodeImage(result);
      expect(decoded, isNotNull);
      expect(decoded!.width, 64);
      expect(decoded.height, 32);
    });

    test('bytes rusak dikembalikan apa adanya (fail-soft)', () {
      final garbage = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(compressBackgroundImageBytes(garbage), garbage);
    });

    test('base64 rusak dikembalikan apa adanya', () {
      expect(compressBackgroundBase64('!!!'), '!!!');
      expect(compressBackgroundBase64(''), '');
    });
  });

  group('compressedBackgroundPacket', () {
    test('hanya aksi updateBackgroundImages yang diubah', () {
      const other = SyncPacket(action: SyncAction.updateConfig, payload: {
        'images': [
          {'base64Image': 'QUJD'}
        ]
      });
      expect(identical(compressedBackgroundPacket(other), other), isTrue);
    });

    test('gambar di payload diganti versi terkompresi, id utuh', () {
      final image = img.Image(width: 2000, height: 1000);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixelRgb(
            x,
            y,
            (127 + 127 * (x / 2000)).round(),
            (127 + 127 * (y / 1000)).round(),
            ((x + y) ~/ 8) % 256,
          );
        }
      }
      final originalB64 = base64Encode(img.encodeJpg(image, quality: 97));
      final packet = SyncPacket(
        action: SyncAction.updateBackgroundImages,
        payload: {
          'images': [
            {'id': 'bg1', 'base64Image': originalB64, 'isActive': true},
          ],
        },
      );
      final result = compressedBackgroundPacket(packet);
      final images = result.payload['images'] as List;
      final first = images.first as Map;
      expect(first['id'], 'bg1');
      expect(first['isActive'], isTrue);
      expect(first['base64Image'], isNot(originalB64));
      expect((first['base64Image'] as String).length,
          lessThan(originalB64.length));
      // Paket asal tidak dimutasi.
      expect(
          (packet.payload['images'] as List).first['base64Image'], originalB64);
    });
  });

  group('BackgroundSendPreferences', () {
    test('default kompresi aktif; nilai tersimpan terbaca kembali', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await BackgroundSendPreferences.loadSendUncompressed(), isFalse);
      await BackgroundSendPreferences.saveSendUncompressed(true);
      expect(await BackgroundSendPreferences.loadSendUncompressed(), isTrue);
      await BackgroundSendPreferences.saveSendUncompressed(false);
      expect(await BackgroundSendPreferences.loadSendUncompressed(), isFalse);
    });
  });
}
