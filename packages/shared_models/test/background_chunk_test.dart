import 'dart:convert';

import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

/// Tes ADR-031: model BackgroundImage, field interval slideshow di
/// MosqueConfig, backgroundImages di StateSnapshot, dan codec chunking
/// transfer Bluetooth (encode + reassemble).
void main() {
  group('BackgroundImage', () {
    test('roundtrip toMap/fromMap utuh', () {
      const image = BackgroundImage(
        id: 'bg-1',
        base64Image: 'QUJD',
        isActive: false,
      );
      final restored = BackgroundImage.fromMap(image.toMap());
      expect(restored, image);
    });

    test('roundtrip JSON utuh', () {
      const image = BackgroundImage(id: 'bg-2', base64Image: 'REVG');
      expect(BackgroundImage.fromJson(image.toJson()), image);
    });

    test('fromMap toleran: field hilang -> default aman', () {
      final image = BackgroundImage.fromMap(const {});
      expect(image.base64Image, '');
      expect(image.isActive, isTrue);
      expect(image.id, isNotEmpty);
    });

    test('copyWith mengubah satu field', () {
      const image = BackgroundImage(id: 'x', base64Image: 'QQ==');
      final copy = image.copyWith(isActive: false);
      expect(copy.isActive, isFalse);
      expect(copy.base64Image, 'QQ==');
    });
  });

  group('MosqueConfig.backgroundSlideSeconds', () {
    test('default 30 detik', () {
      expect(const MosqueConfig().backgroundSlideSeconds, 30);
    });

    test('roundtrip toMap/fromMap mempertahankan nilai', () {
      const config = MosqueConfig(backgroundSlideSeconds: 45);
      final restored = MosqueConfig.fromMap(config.toMap());
      expect(restored.backgroundSlideSeconds, 45);
      expect(restored, config);
    });

    test('fromMap tanpa kunci -> default 30 (payload lama)', () {
      final map = const MosqueConfig().toMap()
        ..remove('backgroundSlideSeconds');
      expect(MosqueConfig.fromMap(map).backgroundSlideSeconds, 30);
    });

    test('fromMap men-clamp di luar rentang 5..300', () {
      final low = MosqueConfig.fromMap({'backgroundSlideSeconds': 1});
      expect(low.backgroundSlideSeconds, 5);
      final high = MosqueConfig.fromMap({'backgroundSlideSeconds': 9999});
      expect(high.backgroundSlideSeconds, 300);
    });

    test('copyWith men-clamp juga', () {
      const config = MosqueConfig();
      expect(
          config.copyWith(backgroundSlideSeconds: 0).backgroundSlideSeconds, 5);
      expect(
          config.copyWith(backgroundSlideSeconds: 301).backgroundSlideSeconds,
          300);
      expect(config.copyWith(backgroundSlideSeconds: 12).backgroundSlideSeconds,
          12);
    });
  });

  group('StateSnapshot.backgroundImages', () {
    test('roundtrip membawa daftar gambar latar', () {
      const snapshot = StateSnapshot(
        backgroundImages: [
          BackgroundImage(id: 'a', base64Image: 'QQ=='),
          BackgroundImage(id: 'b', base64Image: 'Qg==', isActive: false),
        ],
        hasData: true,
      );
      final restored = StateSnapshot.fromMap(snapshot.toMap());
      expect(restored, snapshot);
      expect(restored.backgroundImages.length, 2);
    });

    test('snapshot lama tanpa kunci -> daftar kosong', () {
      final map = const StateSnapshot(hasData: true).toMap()
        ..remove('backgroundImages');
      expect(StateSnapshot.fromMap(map).backgroundImages, isEmpty);
    });
  });

  group('chunking transfer (ADR-031)', () {
    SyncPacket bigPacket(int approxChars) {
      // Payload teks panjang agar JSON melewati ambang chunking.
      return SyncPacket(
        action: SyncAction.updateBackgroundImages,
        payload: {
          'images': [
            {'id': 'big', 'base64Image': 'A' * approxChars, 'isActive': true},
          ],
        },
      );
    }

    test('paket kecil tidak di-chunk (jalur lama, kompatibel)', () {
      const packet = SyncPacket(
        action: SyncAction.updateConfig,
        payload: {'name': 'Masjid'},
      );
      final encoding = encodeChunkedTransfer(packet);
      expect(encoding.chunked, isFalse);
      expect(encoding.packets, [packet]);
    });

    test('paket besar dipecah dan dirangkai ulang byte-identik', () {
      final packet = bigPacket(200 * 1024);
      final encoding = encodeChunkedTransfer(packet, transferId: 'tx-test');
      expect(encoding.chunked, isTrue);
      expect(encoding.packets.length, greaterThan(2));
      for (final chunk in encoding.packets) {
        expect(chunk.action, SyncAction.chunkedData);
        expect(chunk.payload['data'].toString().length,
            lessThanOrEqualTo(kChunkDataLength));
      }

      final reassembler = ChunkReassembler();
      SyncPacket? result;
      for (final chunk in encoding.packets) {
        result = reassembler.addChunk(chunk) ?? result;
      }
      expect(result, isNotNull);
      expect(result!.toJson(), packet.toJson());
      expect(reassembler.hasPendingTransfer, isFalse);
      expect(reassembler.lastError, isNull);
    });

    test('chunk datang tidak berurutan tetap lengkap', () {
      final packet = bigPacket(150 * 1024);
      final encoding = encodeChunkedTransfer(packet, transferId: 'tx-urut');
      final shuffled = [...encoding.packets.reversed];
      final reassembler = ChunkReassembler();
      SyncPacket? result;
      for (final chunk in shuffled) {
        result = reassembler.addChunk(chunk) ?? result;
      }
      expect(result?.toJson(), packet.toJson());
    });

    test('chunk hilang -> tidak pernah lengkap, tanpa error palsu', () {
      final packet = bigPacket(150 * 1024);
      final encoding = encodeChunkedTransfer(packet, transferId: 'tx-hilang');
      final reassembler = ChunkReassembler();
      SyncPacket? result;
      // Lewati chunk kedua.
      for (var i = 0; i < encoding.packets.length; i++) {
        if (i == 1) continue;
        result = reassembler.addChunk(encoding.packets[i]) ?? result;
      }
      expect(result, isNull);
      expect(reassembler.hasPendingTransfer, isTrue);
      expect(reassembler.receivedCount, encoding.packets.length - 1);
      expect(reassembler.lastError, isNull);
    });

    test('chunk duplikat identik diabaikan, hasil tetap benar', () {
      final packet = bigPacket(150 * 1024);
      final encoding = encodeChunkedTransfer(packet, transferId: 'tx-dup');
      final reassembler = ChunkReassembler();
      SyncPacket? result;
      for (final chunk in encoding.packets) {
        result = reassembler.addChunk(chunk) ?? result;
        // Kirim ulang chunk yang sama (mis. retry pengirim).
        result = reassembler.addChunk(chunk) ?? result;
      }
      expect(result?.toJson(), packet.toJson());
      expect(reassembler.lastError, isNull);
    });

    test('chunk duplikat konflik -> transfer dibuang + error', () {
      final packet = bigPacket(150 * 1024);
      final encoding = encodeChunkedTransfer(packet, transferId: 'tx-konflik');
      final reassembler = ChunkReassembler();
      reassembler.addChunk(encoding.packets[0]);
      final conflict = SyncPacket(
        action: SyncAction.chunkedData,
        payload: {
          ...encoding.packets[0].payload,
          'data': 'X' * 100,
        },
      );
      expect(reassembler.addChunk(conflict), isNull);
      expect(reassembler.hasPendingTransfer, isFalse);
      expect(reassembler.lastError, isNotNull);
    });

    test('metadata rusak -> dibuang + error', () {
      final reassembler = ChunkReassembler();
      final bad = SyncPacket(
        action: SyncAction.chunkedData,
        payload: const {'transferId': 'tx', 'seq': 'nol'},
      );
      expect(reassembler.addChunk(bad), isNull);
      expect(reassembler.lastError, isNotNull);
      expect(reassembler.hasPendingTransfer, isFalse);
    });

    test('transfer baru menggantikan transfer lama yang menggantung', () {
      final first =
          encodeChunkedTransfer(bigPacket(150 * 1024), transferId: 'tx-lama');
      final second =
          encodeChunkedTransfer(bigPacket(150 * 1024), transferId: 'tx-baru');
      final reassembler = ChunkReassembler();
      reassembler.addChunk(first.packets[0]);
      expect(reassembler.hasPendingTransfer, isTrue);
      SyncPacket? result;
      for (final chunk in second.packets) {
        result = reassembler.addChunk(chunk) ?? result;
      }
      expect(result, isNotNull);
      expect(reassembler.lastError, isNull);
    });

    test('paket non-chunk ditolak reassembler', () {
      final reassembler = ChunkReassembler();
      expect(
        reassembler.addChunk(
            const SyncPacket(action: SyncAction.updateConfig, payload: {})),
        isNull,
      );
      expect(reassembler.lastError, isNotNull);
    });

    test('SyncPacket chunkedData roundtrip JSON (protokol tetap parse)', () {
      final packet = bigPacket(100 * 1024);
      final chunk =
          encodeChunkedTransfer(packet, transferId: 'tx-json').packets.first;
      final parsed = SyncPacket.fromJson(chunk.toJson());
      expect(parsed.action, SyncAction.chunkedData);
      expect(parsed.payload['transferId'], 'tx-json');
      // Dan paket hasil rangkaian parse sebagai aksi aslinya.
      expect(SyncAction.values.byName('updateBackgroundImages'),
          SyncAction.updateBackgroundImages);
      expect(json.decode(packet.toJson())['action'], 'updateBackgroundImages');
    });
  });
}
