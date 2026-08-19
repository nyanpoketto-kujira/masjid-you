import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('MosqueConfig & PrayerSchedule Tests', () {
    test('MosqueConfig serialization & deserialization', () {
      const config = MosqueConfig(
        name: 'Masjid Syuhada',
        address: 'Yogyakarta',
        latitude: -7.7828,
        longitude: 110.3671,
      );

      final jsonString = config.toJson();
      final parsedConfig = MosqueConfig.fromJson(jsonString);

      expect(parsedConfig.name, equals('Masjid Syuhada'));
      expect(parsedConfig.latitude, equals(-7.7828));
    });

    test('PrayerSchedule calculation produces 6 times', () {
      const config = MosqueConfig(
        latitude: -6.2088,
        longitude: 106.8456,
      );

      final schedule = PrayerSchedule.calculate(config, DateTime(2026, 8, 12, 10, 0));

      expect(schedule.items.length, equals(6));
      expect(schedule.nextPrayer, equals(PrayerType.dhuhr));
    });

    test('PrayerSchedule applies per-prayer offset', () {
      final config = MosqueConfig(
        latitude: -6.2088,
        longitude: 106.8456,
        prayerOffsets: {
          PrayerType.fajr: 5,
          PrayerType.dhuhr: -2,
        },
      );

      final withOffset = PrayerSchedule.calculate(config, DateTime(2026, 8, 12, 0, 30));
      const noOffset = MosqueConfig(
        latitude: -6.2088,
        longitude: 106.8456,
      );
      final base = PrayerSchedule.calculate(noOffset, DateTime(2026, 8, 12, 0, 30));

      final fajrOffset = withOffset.items
          .firstWhere((i) => i.type == PrayerType.fajr)
          .time
          .difference(base.items.firstWhere((i) => i.type == PrayerType.fajr).time);
      final dhuhrOffset = withOffset.items
          .firstWhere((i) => i.type == PrayerType.dhuhr)
          .time
          .difference(base.items.firstWhere((i) => i.type == PrayerType.dhuhr).time);
      final ishaOffset = withOffset.items
          .firstWhere((i) => i.type == PrayerType.isha)
          .time
          .difference(base.items.firstWhere((i) => i.type == PrayerType.isha).time);

      expect(fajrOffset, equals(const Duration(minutes: 5)));
      expect(dhuhrOffset, equals(const Duration(minutes: -2)));
      expect(ishaOffset, equals(Duration.zero));
    });

    test('MosqueConfig backward compat: prayerCorrectionMinutes seeds all offsets', () {
      final parsed = MosqueConfig.fromMap({'prayerCorrectionMinutes': 3});

      expect(parsed.offsetFor(PrayerType.fajr), equals(3));
      expect(parsed.offsetFor(PrayerType.isha), equals(3));
      expect(parsed.offsetFor(PrayerType.sunrise), equals(3));
    });

    test('MosqueConfig duration defaults & round-trip', () {
      const config = MosqueConfig(
        preAdhanMinutes: 20,
        adhanMinutes: 3,
        preIqomahMinutes: 2,
        shalatMinutes: 15,
      );

      final parsed = MosqueConfig.fromJson(config.toJson());

      expect(parsed.preAdhanMinutes, equals(20));
      expect(parsed.adhanMinutes, equals(3));
      expect(parsed.preIqomahMinutes, equals(2));
      expect(parsed.shalatMinutes, equals(15));
    });

    test('MosqueConfig duration falls back to defaults when absent', () {
      final parsed = MosqueConfig.fromMap({'name': 'Masjid Baru'});

      expect(parsed.preAdhanMinutes, equals(15));
      expect(parsed.adhanMinutes, equals(2));
      expect(parsed.preIqomahMinutes, equals(1));
      expect(parsed.shalatMinutes, equals(10));
    });

    test('PrayerPhase durationFor maps to config durations', () {
      const config = MosqueConfig(
        preAdhanMinutes: 30,
        adhanMinutes: 4,
        preIqomahMinutes: 3,
        shalatMinutes: 20,
        khutbahMinutes: 25,
      );

      expect(PrayerPhase.preAdhan.durationFor(config),
          equals(const Duration(minutes: 30)));
      expect(PrayerPhase.adhan.durationFor(config),
          equals(const Duration(minutes: 4)));
      expect(PrayerPhase.khutbah.durationFor(config),
          equals(const Duration(minutes: 25)));
      expect(PrayerPhase.preIqomah.durationFor(config),
          equals(const Duration(minutes: 3)));
      expect(PrayerPhase.shalat.durationFor(config),
          equals(const Duration(minutes: 20)));
      expect(PrayerPhase.normal.durationFor(config), equals(Duration.zero));
    });

    test('MosqueConfig Friday fields round-trip & defaults', () {
      const config = MosqueConfig(
        khutbahMinutes: 30,
        fridayKhatib: 'Ustadz Ahmad',
        fridayMuadzin: 'Ustadz Bilal',
      );

      final parsed = MosqueConfig.fromJson(config.toJson());

      expect(parsed.khutbahMinutes, equals(30));
      expect(parsed.fridayKhatib, equals('Ustadz Ahmad'));
      expect(parsed.fridayMuadzin, equals('Ustadz Bilal'));
    });

    test('MosqueConfig Friday fields fall back to defaults when absent', () {
      final parsed = MosqueConfig.fromMap({'name': 'Masjid Baru'});

      expect(parsed.khutbahMinutes, equals(20));
      expect(parsed.fridayKhatib, equals('Ustadz Khatib'));
      expect(parsed.fridayMuadzin, equals('Ustadz Bilal'));
    });

    test('PrayerType.displayNameForDate maps dhuhr to Jumat on Friday', () {
      final friday = DateTime(2026, 8, 14); // Friday
      final thursday = DateTime(2026, 8, 13); // Thursday

      expect(PrayerType.dhuhr.displayNameForDate(friday), equals('Jumat'));
      expect(PrayerType.dhuhr.displayNameForDate(thursday), equals('Dzuhur'));
      expect(PrayerType.maghrib.displayNameForDate(friday), equals('Maghrib'));
    });

    test('SyncPacket carries quick-action (skip) actions', () {
      const packet = SyncPacket(action: SyncAction.skipAdhan, payload: {});

      final parsed = SyncPacket.fromJson(packet.toJson());

      expect(parsed.action, equals(SyncAction.skipAdhan));
    });

    test('SyncPacket carries startIqomah action', () {
      const packet = SyncPacket(action: SyncAction.startIqomah, payload: {});

      final parsed = SyncPacket.fromJson(packet.toJson());

      expect(parsed.action, equals(SyncAction.startIqomah));
    });

    test('SyncPacket carries forcePhase action with phase payload', () {
      final packet = SyncPacket(
        action: SyncAction.forcePhase,
        payload: {'phase': 'adhan'},
      );

      final parsed = SyncPacket.fromJson(packet.toJson());

      expect(parsed.action, equals(SyncAction.forcePhase));
      expect(parsed.payload['phase'], equals('adhan'));
    });

    test('PrayerPhase.fromName parses valid names and falls back to normal', () {
      expect(PrayerPhase.fromName('adhan'), equals(PrayerPhase.adhan));
      expect(PrayerPhase.fromName('khutbah'), equals(PrayerPhase.khutbah));
      expect(PrayerPhase.fromName('shalat'), equals(PrayerPhase.shalat));
      expect(PrayerPhase.fromName(null), equals(PrayerPhase.normal));
      expect(PrayerPhase.fromName('unknown'), equals(PrayerPhase.normal));
    });

    test('SyncPacket serialization', () {
      final packet = SyncPacket(
        action: SyncAction.updateRunningText,
        payload: {
          'messages': [
            {'id': '1', 'content': 'Test Message', 'category': 'Umum'}
          ]
        },
      );

      final jsonStr = packet.toJson();
      final parsed = SyncPacket.fromJson(jsonStr);

      expect(parsed.action, equals(SyncAction.updateRunningText));
      expect(parsed.payload['messages'][0]['content'], equals('Test Message'));
    });
  });

  group('Info Masjid (MediaBanner) Tests', () {
    test('MediaBanner serialization round-trip with 4 fields', () {
      const banner = MediaBanner(
        id: 'b1',
        header: 'DONASI',
        title: 'Infaq Pembangunan',
        content: 'Salurkan untuk ruang belajar',
        footer: 'Amal Jariyah',
        base64Image: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      final parsed = MediaBanner.fromJson(banner.toJson());

      expect(parsed.header, equals('DONASI'));
      expect(parsed.title, equals('Infaq Pembangunan'));
      expect(parsed.content, equals('Salurkan untuk ruang belajar'));
      expect(parsed.footer, equals('Amal Jariyah'));
      expect(parsed.isActive, isTrue);
      expect(parsed.base64Image, equals('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='));
    });

    test('MediaBanner backward compat: subtitle maps to content', () {
      final parsed = MediaBanner.fromMap({
        'id': 'b2',
        'title': 'Kajian Subuh',
        'subtitle': 'Setiap Sabtu & Ahad',
        'imageUrl': '',
      });

      expect(parsed.header, equals('INFO MASJID'));
      expect(parsed.content, equals('Setiap Sabtu & Ahad'));
      expect(parsed.footer, equals(''));
    });
  });

  group('Kas (Cash Fund) Tests', () {
    test('KasTransaction serialization & deserialization', () {
      final tx = KasTransaction(
        id: 'tx1',
        type: KasType.masuk,
        amount: 50000,
        description: 'Infaq Jumat',
        date: DateTime(2026, 8, 13, 9, 30),
      );

      final jsonString = tx.toJson();
      final parsed = KasTransaction.fromJson(jsonString);

      expect(parsed.type, equals(KasType.masuk));
      expect(parsed.amount, equals(50000));
      expect(parsed.description, equals('Infaq Jumat'));
      expect(parsed.date, equals(DateTime(2026, 8, 13, 9, 30)));
    });

    test('KasTransaction type fallback to masuk on unknown', () {
      final parsed = KasTransaction.fromMap({
        'id': 'tx2',
        'type': 'unknown',
        'amount': 1000,
        'description': 'test',
      });

      expect(parsed.type, equals(KasType.masuk));
    });

    test('KasSummary computes total masuk, keluar and saldo', () {
      final transactions = [
        KasTransaction(
          id: '1',
          type: KasType.masuk,
          amount: 100000,
          description: 'A',
          date: DateTime(2026),
        ),
        KasTransaction(
          id: '2',
          type: KasType.keluar,
          amount: 25000,
          description: 'B',
          date: DateTime(2026),
        ),
        KasTransaction(
          id: '3',
          type: KasType.masuk,
          amount: 50000,
          description: 'C',
          date: DateTime(2026),
        ),
      ];

      final summary = KasSummary.fromTransactions(transactions);

      expect(summary.totalMasuk, equals(150000));
      expect(summary.totalKeluar, equals(25000));
      expect(summary.saldo, equals(125000));
    });

    test('KasSummary empty list yields zero saldo', () {
      final summary = KasSummary.fromTransactions([]);
      expect(summary.saldo, equals(0));
      expect(summary.totalMasuk, equals(0));
      expect(summary.totalKeluar, equals(0));
    });

    test('SyncPacket carries updateKas payload', () {
      final packet = SyncPacket(
        action: SyncAction.updateKas,
        payload: {
          'transactions': [
            {
              'id': 'tx1',
              'type': 'masuk',
              'amount': 100000,
              'description': 'Infaq',
              'date': DateTime(2026, 8, 13).toIso8601String(),
            }
          ]
        },
      );

      final parsed = SyncPacket.fromJson(packet.toJson());

      expect(parsed.action, equals(SyncAction.updateKas));
      expect(parsed.payload['transactions'][0]['amount'], equals(100000));
    });
  });
}
