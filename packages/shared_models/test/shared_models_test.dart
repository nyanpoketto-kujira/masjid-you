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
      );

      final parsed = MediaBanner.fromJson(banner.toJson());

      expect(parsed.header, equals('DONASI'));
      expect(parsed.title, equals('Infaq Pembangunan'));
      expect(parsed.content, equals('Salurkan untuk ruang belajar'));
      expect(parsed.footer, equals('Amal Jariyah'));
      expect(parsed.isActive, isTrue);
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
