import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

/// Tes fitur rotasi kartu slot samping TV:
/// toggle `showKas` & `hasFridayPrayer` di [MosqueConfig], model gambar
/// khusus [SpecialImage], dan perluasan [StateSnapshot] / [BackupBundle].
void main() {
  group('MosqueConfig — toggle showKas & hasFridayPrayer', () {
    test('default keduanya true (perilaku lama)', () {
      const config = MosqueConfig();
      expect(config.showKas, isTrue);
      expect(config.hasFridayPrayer, isTrue);
    });

    test('round-trip toMap/fromMap mempertahankan nilai false', () {
      const config = MosqueConfig(showKas: false, hasFridayPrayer: false);
      final parsed = MosqueConfig.fromMap(config.toMap());
      expect(parsed.showKas, isFalse);
      expect(parsed.hasFridayPrayer, isFalse);
      expect(parsed, equals(config));
    });

    test('round-trip JSON mempertahankan nilai false', () {
      const config = MosqueConfig(showKas: false, hasFridayPrayer: false);
      final parsed = MosqueConfig.fromJson(config.toJson());
      expect(parsed.showKas, isFalse);
      expect(parsed.hasFridayPrayer, isFalse);
    });

    test('payload lama tanpa kedua kunci jatuh ke default true', () {
      // Simulasi payload dari versi sebelum toggle ini ada.
      final legacy = Map<String, dynamic>.of(const MosqueConfig().toMap())
        ..remove('showKas')
        ..remove('hasFridayPrayer');
      final parsed = MosqueConfig.fromMap(legacy);
      expect(parsed.showKas, isTrue);
      expect(parsed.hasFridayPrayer, isTrue);
    });

    test('nilai bukan bool jatuh ke default true, bukan error', () {
      final parsed = MosqueConfig.fromMap(const {
        'showKas': 'tidak',
        'hasFridayPrayer': 0,
      });
      expect(parsed.showKas, isTrue);
      expect(parsed.hasFridayPrayer, isTrue);
    });

    test('copyWith hanya mengubah toggle yang diminta', () {
      const config = MosqueConfig();
      final noKas = config.copyWith(showKas: false);
      expect(noKas.showKas, isFalse);
      expect(noKas.hasFridayPrayer, isTrue);

      final musholla = config.copyWith(hasFridayPrayer: false);
      expect(musholla.showKas, isTrue);
      expect(musholla.hasFridayPrayer, isFalse);
    });

    test('equality & hashCode membedakan nilai toggle', () {
      const a = MosqueConfig();
      const b = MosqueConfig(showKas: false);
      const c = MosqueConfig(hasFridayPrayer: false);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
      expect(a.hashCode, isNot(equals(c.hashCode)));
    });
  });

  group('PrayerType.displayNameForDate — toggle Jumatan', () {
    // 14 Agustus 2026 adalah hari Jumat; 13 Agustus 2026 hari Kamis.
    final friday = DateTime(2026, 8, 14);
    final thursday = DateTime(2026, 8, 13);

    test('Jumatan ON: Dzuhur menjadi "Jumat" di hari Jumat', () {
      expect(PrayerType.dhuhr.displayNameForDate(friday), equals('Jumat'));
      expect(
        PrayerType.dhuhr.displayNameForDate(friday, hasFridayPrayer: true),
        equals('Jumat'),
      );
    });

    test('Jumatan OFF (musholla): Dzuhur tetap "Dzuhur" di hari Jumat', () {
      expect(
        PrayerType.dhuhr.displayNameForDate(friday, hasFridayPrayer: false),
        equals('Dzuhur'),
      );
    });

    test('hari biasa & shalat lain tidak terpengaruh toggle', () {
      expect(
        PrayerType.dhuhr.displayNameForDate(thursday, hasFridayPrayer: false),
        equals('Dzuhur'),
      );
      expect(
        PrayerType.maghrib.displayNameForDate(friday, hasFridayPrayer: false),
        equals('Maghrib'),
      );
      expect(
        PrayerType.maghrib.displayNameForDate(friday),
        equals('Maghrib'),
      );
    });
  });

  group('SpecialImage', () {
    const image = SpecialImage(
      id: 'img-1',
      caption: 'Pembangunan Ruang Belajar',
      base64Image: 'aGVsbG8=',
      isActive: false,
    );

    test('round-trip toMap/fromMap & JSON mempertahankan semua field', () {
      expect(SpecialImage.fromMap(image.toMap()), equals(image));
      expect(SpecialImage.fromJson(image.toJson()), equals(image));
    });

    test('default caption kosong & isActive true', () {
      const minimal = SpecialImage(id: 'x', base64Image: 'AA==');
      expect(minimal.caption, isEmpty);
      expect(minimal.isActive, isTrue);
    });

    test('fromMap toleran: field hilang / tipe salah jatuh ke default', () {
      final parsed = SpecialImage.fromMap(const {
        'id': 42,
        'caption': 7,
        'base64Image': null,
        'isActive': 'ya',
      });
      expect(parsed.id, isNotEmpty);
      expect(parsed.caption, isEmpty);
      expect(parsed.base64Image, isEmpty);
      expect(parsed.isActive, isTrue);
    });

    test('copyWith mengubah field terpilih saja', () {
      final changed = image.copyWith(isActive: true, caption: 'Baru');
      expect(changed.isActive, isTrue);
      expect(changed.caption, equals('Baru'));
      expect(changed.base64Image, equals(image.base64Image));
      expect(changed.id, equals(image.id));
    });

    test('toString tidak membocorkan isi base64', () {
      expect(image.toString(), isNot(contains('aGVsbG8=')));
      expect(image.toString(), contains('[set]'));
    });
  });

  group('StateSnapshot & BackupBundle — sideImages', () {
    const snapshot = StateSnapshot(
      config: MosqueConfig(showKas: false),
      sideImages: [
        SpecialImage(id: 'a', base64Image: 'AA==', caption: 'Satu'),
        SpecialImage(id: 'b', base64Image: 'BB==', isActive: false),
      ],
      hasData: true,
    );

    test('round-trip snapshot mempertahankan sideImages & urutannya', () {
      final parsed = StateSnapshot.fromMap(snapshot.toMap());
      expect(parsed, equals(snapshot));
      expect(parsed.sideImages.map((i) => i.id), equals(['a', 'b']));
    });

    test('snapshot lama tanpa kunci sideImages terbaca sebagai daftar kosong',
        () {
      final legacy = Map<String, dynamic>.of(snapshot.toMap())
        ..remove('sideImages');
      final parsed = StateSnapshot.fromMap(legacy);
      expect(parsed.sideImages, isEmpty);
      expect(parsed.config.showKas, isFalse);
    });

    test('entri sideImages yang bukan Map dilewati, bukan error', () {
      final parsed = StateSnapshot.fromMap(const {
        'sideImages': [
          {'id': 'ok', 'base64Image': 'AA=='},
          'rusak',
          42,
        ],
      });
      expect(parsed.sideImages.length, equals(1));
      expect(parsed.sideImages.single.id, equals('ok'));
    });

    test('BackupBundle round-trip ikut membawa sideImages', () {
      final bundle = BackupBundle(
        exportedAt: DateTime(2026, 11, 16, 18, 0),
        mosqueName: 'Musholla Al-Ikhlas',
        snapshot: snapshot,
      );
      final parsed = BackupBundle.fromMap(bundle.toMap());
      expect(parsed, equals(bundle));
      expect(parsed.snapshot.sideImages.length, equals(2));
    });
  });

  group('SyncPacket — updateSideImages', () {
    test('action name stabil untuk protokol sync', () {
      expect(SyncAction.updateSideImages.name, equals('updateSideImages'));
      final packet = SyncPacket.fromJson(
        const SyncPacket(
          action: SyncAction.updateSideImages,
          payload: {'images': []},
        ).toJson(),
      );
      expect(packet.action, equals(SyncAction.updateSideImages));
    });
  });
}
