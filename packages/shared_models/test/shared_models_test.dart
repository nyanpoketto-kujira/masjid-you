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

  group('MosqueConfig, IqamahDuration, PrayerType & PrayerPhase (refactor)', () {
    test('MosqueConfig: prayerOffsets dari fromMap bersifat unmodifiable', () {
      final parsed = MosqueConfig.fromMap({'prayerOffsets': {'fajr': 2}});
      expect(parsed.offsetFor(PrayerType.fajr), equals(2));
      expect(
        () => parsed.prayerOffsets[PrayerType.maghrib] = 9,
        throwsUnsupportedError,
      );
    });

    test('MosqueConfig.copyWith menyalin prayerOffsets secara deep copy', () {
      final base = MosqueConfig.fromMap({'prayerOffsets': {'fajr': 1}});
      final copy = base.copyWith(preAdhanMinutes: 5);
      expect(copy.prayerOffsets, equals(base.prayerOffsets));

      final replaced = base.copyWith(prayerOffsets: {PrayerType.isha: 4});
      expect(replaced.offsetFor(PrayerType.isha), equals(4));
      expect(replaced.offsetFor(PrayerType.fajr), equals(0));
      expect(() => replaced.prayerOffsets[PrayerType.isha] = 9,
          throwsUnsupportedError);
      expect(base.offsetFor(PrayerType.isha), equals(0));
    });

    test('MosqueConfig: nilai non-numerik untuk field angka tidak melempar', () {
      final parsed = MosqueConfig.fromMap({
        'latitude': 'bukan-angka',
        'preAdhanMinutes': 'x',
        'utcOffsetHours': [],
      });
      expect(parsed.latitude, equals(-6.2088));
      expect(parsed.preAdhanMinutes, equals(15));
      expect(parsed.utcOffsetHours, equals(7));
    });

    test('IqamahDuration: nilai double di-truncate & round-trip', () {
      final parsed = IqamahDuration.fromMap({'fajr': 12.7, 'maghrib': 5.2});
      expect(parsed.fajr, equals(12));
      expect(parsed.maghrib, equals(5));
      expect(parsed.dhuhr, equals(10));
      expect(IqamahDuration.fromMap(parsed.toMap()), equals(parsed));
    });

    test('PrayerTypeX.displayName mengisi semua 6 nilai', () {
      expect(PrayerType.fajr.displayName, equals('Subuh'));
      expect(PrayerType.sunrise.displayName, equals('Syuruq'));
      expect(PrayerType.dhuhr.displayName, equals('Dzuhur'));
      expect(PrayerType.asr.displayName, equals('Ashar'));
      expect(PrayerType.maghrib.displayName, equals('Maghrib'));
      expect(PrayerType.isha.displayName, equals('Isya'));
      expect(kAllPrayerTypes, equals(PrayerType.values));
    });

    test('PrayerPhaseX.label mengisi semua 6 fase', () {
      expect(PrayerPhase.normal.label, equals('Normal (Standby)'));
      expect(PrayerPhase.preAdhan.label, equals('Menjelang Azan'));
      expect(PrayerPhase.adhan.label, equals('Azan'));
      expect(PrayerPhase.khutbah.label, equals('Khutbah'));
      expect(PrayerPhase.preIqomah.label, equals('Jeda Ikamah'));
      expect(PrayerPhase.shalat.label, equals('Shalat Berlangsung'));
    });

    test('MosqueConfig equality & round-trip penuh', () {
      const config = MosqueConfig(
        name: 'Masjid A',
        utcOffsetHours: 8,
        prayerOffsets: {PrayerType.fajr: 1},
      );
      final round = MosqueConfig.fromJson(config.toJson());
      expect(round, equals(config));
      expect(round.hashCode, equals(config.hashCode));
      expect(round.iqamahDuration, equals(const IqamahDuration()));
      expect(round, isNot(equals(config.copyWith(adhanMinutes: 3))));
    });
  });

  group('RunningTextMessage, MediaBanner, KasTransaction (refactor)', () {
    test('RunningTextMessage: default, id generatif & round-trip', () {
      final parsed = RunningTextMessage.fromMap({'content': 'Teks pengumuman'});
      expect(parsed.id, isNotEmpty);
      expect(parsed.content, equals('Teks pengumuman'));
      expect(parsed.isActive, isTrue);
      expect(parsed.category, equals('Umum'));

      const msg = RunningTextMessage(
        id: 'rt1',
        content: 'Infaq diterima',
        isActive: false,
        category: 'Kas',
      );
      final round = RunningTextMessage.fromJson(msg.toJson());
      expect(round, equals(msg));
      expect(round.hashCode, equals(msg.hashCode));
      expect(round.isActive, isFalse);
      expect(round.category, equals('Kas'));
    });

    test('RunningTextMessage: tipe salah tidak melempar error', () {
      final parsed = RunningTextMessage.fromMap({
        'id': 123,
        'content': 456,
        'isActive': 'bukan-bool',
        'category': ['x'],
      });
      expect(parsed.id, isNotEmpty);
      expect(parsed.content, equals(''));
      expect(parsed.isActive, isTrue);
      expect(parsed.category, equals('Umum'));
    });

    test('MediaBanner: base64Image kosong dianggap null, terisi tetap ada', () {
      final empty = MediaBanner.fromMap({'id': 'b1', 'base64Image': ''});
      expect(empty.base64Image, isNull);
      final set = MediaBanner.fromMap({'id': 'b1', 'base64Image': 'abc123'});
      expect(set.base64Image, equals('abc123'));
    });

    test('MediaBanner.copyWith: clearBase64Image menghapus gambar', () {
      const banner = MediaBanner(
        id: 'b1',
        header: 'DONASI',
        title: 'T',
        content: 'C',
        base64Image: 'abc',
      );
      final cleared = banner.copyWith(clearBase64Image: true);
      expect(cleared.base64Image, isNull);
      expect(cleared.header, equals('DONASI'));
      // Perilaku lama tetap: tanpa clear, gambar dipertahankan / bisa diganti.
      expect(banner.copyWith(isActive: false).base64Image, equals('abc'));
      expect(banner.copyWith(base64Image: 'xyz').base64Image, equals('xyz'));
    });

    test('MediaBanner equality & toString menyembunyikan isi base64', () {
      const a = MediaBanner(
          id: 'b1', header: 'H', title: 'T', content: 'C', base64Image: 'rahasia');
      const b = MediaBanner(
          id: 'b1', header: 'H', title: 'T', content: 'C', base64Image: 'rahasia');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), isNot(contains('rahasia')));
      expect(a.toString(), contains('[set]'));
    });

    test('KasTransaction: tanggal tak valid tidak melempar & amount num -> int', () {
      final parsed = KasTransaction.fromMap({
        'id': 'tx1',
        'type': 'keluar',
        'amount': 12.9,
        'description': 'Beli Mukena',
        'date': 'bukan-tanggal',
      });
      expect(parsed.type, equals(KasType.keluar));
      expect(parsed.amount, equals(12));
      expect(parsed.date, isA<DateTime>());
      expect(KasTransaction.fromMap({'amount': 'bukan-num'}).amount, equals(0));
      expect(
          KasTransaction.fromMap({'description': 123}).description, equals(''));
    });

    test('KasSummary: saldo boleh negatif & equality', () {
      final summary = KasSummary.fromTransactions([
        KasTransaction(
            id: '1',
            type: KasType.keluar,
            amount: 50000,
            description: 'x',
            date: DateTime(2026)),
      ]);
      const same = KasSummary(totalMasuk: 0, totalKeluar: 50000, saldo: -50000);
      expect(summary.totalMasuk, equals(0));
      expect(summary.totalKeluar, equals(50000));
      expect(summary.saldo, equals(-50000));
      expect(summary, equals(same));
      expect(summary.hashCode, equals(same.hashCode));
    });
  });

  group('SyncPacket: ketangguhan & equality (refactor)', () {
    test('unknown action -> stateUpdate fallback', () {
      final parsed = SyncPacket.fromMap({
        'action': 'aksiTidakAda',
        'payload': {'a': 1},
      });
      expect(parsed.action, equals(SyncAction.stateUpdate));
      expect(parsed.payload, equals({'a': 1}));
    });

    test('action non-String & payload non-Map tetap valid', () {
      expect(SyncPacket.fromMap({'action': 42, 'payload': {}}).action,
          equals(SyncAction.stateUpdate));
      final listPayload =
          SyncPacket.fromMap({'action': 'triggerBeep', 'payload': []});
      expect(listPayload.action, equals(SyncAction.triggerBeep));
      expect(listPayload.payload, isEmpty);
      final missing = SyncPacket.fromMap({});
      expect(missing.action, equals(SyncAction.stateUpdate));
      expect(missing.payload, isEmpty);
    });

    test('kunci payload non-String dipaksa String tanpa error', () {
      final parsed = SyncPacket.fromMap({
        'action': 'forcePhase',
        'payload': {1: 'adhan'},
      });
      expect(parsed.payload.containsKey('1'), isTrue);
      expect(parsed.payload['1'], equals('adhan'));
    });

    test('semua SyncAction round-trip nama -> enum', () {
      for (final action in SyncAction.values) {
        final parsed = SyncPacket.fromJson(
          SyncPacket(action: action, payload: {}).toJson(),
        );
        expect(parsed.action, equals(action), reason: 'action ${action.name}');
      }
    });

    test('equality & hashCode berdasarkan action + payload', () {
      const a = SyncPacket(action: SyncAction.skipAdhan, payload: {'x': 1});
      const b = SyncPacket(action: SyncAction.skipAdhan, payload: {'x': 1});
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(
        a,
        isNot(equals(const SyncPacket(
            action: SyncAction.startShalat, payload: {'x': 1}))),
      );
      expect(
        a,
        isNot(equals(
            const SyncPacket(action: SyncAction.skipAdhan, payload: {'x': 2}))),
      );
    });
  });
}
