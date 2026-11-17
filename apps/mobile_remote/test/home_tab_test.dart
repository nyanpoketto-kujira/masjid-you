import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/home/home_tab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Beranda (Fase 1 refaktor UI, keputusan D5): status TV, Aksi Cepat
/// 56dp, ringkasan kas, dan helper hitung mundur sholat.
void main() {
  group('helper format & jadwal', () {
    test('formatTanggalId memakai nama hari/bulan Indonesia', () {
      // 16 Nov 2026 adalah hari Senin.
      expect(
        formatTanggalId(DateTime(2026, 11, 16)),
        'Senin, 16 November 2026',
      );
      expect(
        formatTanggalId(DateTime(2026, 1, 1)),
        'Kamis, 1 Januari 2026',
      );
    });

    test('formatJam & formatHitungMundur selalu dua digit', () {
      expect(formatJam(DateTime(2026, 1, 1, 9, 5, 3)), '09:05:03');
      expect(
        formatHitungMundur(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
      expect(
        formatHitungMundur(const Duration(minutes: -5)),
        '00:00:00',
      );
    });

    // CATATAN ZONA WAKTU (ADR-034): PrayerSchedule mengembalikan instan
    // absolut (waktu shalat Jakarta sebagai momen UTC yang benar),
    // sedangkan makna jam dinding seperti "pagi hari"/"larut malam"
    // bergantung zona waktu mesin. Test yang meng-hardcode jam dinding
    // lokal gagal di runner CI (UTC). Karena itu waktu acuan di dua test
    // berikut DITURUNKAN dari jadwal terhitung itu sendiri, sehingga
    // berlaku di zona waktu mana pun.
    test('nextPrayerInfo: pagi hari -> sholat berikutnya hari ini', () {
      const config = MosqueConfig(
        latitude: -6.1754,
        longitude: 106.8272,
      );
      final schedule = PrayerSchedule.calculate(
        config,
        DateTime(2026, 11, 16, 12, 0),
      );
      final fajr = schedule.items
          .firstWhere((item) => item.type == PrayerType.fajr)
          .time;
      // 30 menit sebelum Subuh: sholat berikutnya adalah Subuh hari ini.
      final now = fajr.subtract(const Duration(minutes: 30));
      final next = nextPrayerInfo(config, now);
      expect(next, isNotNull);
      expect(next!.type, PrayerType.fajr);
      expect(next.time, fajr);
      expect(next.time.isAfter(now), isTrue);
    });

    test('nextPrayerInfo: larut malam -> Subuh besok', () {
      const config = MosqueConfig(
        latitude: -6.1754,
        longitude: 106.8272,
      );
      final schedule = PrayerSchedule.calculate(
        config,
        DateTime(2026, 11, 16, 12, 0),
      );
      final isya = schedule.items
          .firstWhere((item) => item.type == PrayerType.isha)
          .time;
      // 30 menit setelah Isya: semua jadwal hari ini sudah lewat,
      // sholat berikutnya adalah Subuh besok.
      final now = isya.add(const Duration(minutes: 30));
      final next = nextPrayerInfo(config, now);
      expect(next, isNotNull);
      expect(next!.type, PrayerType.fajr);
      final tomorrowFajr = PrayerSchedule.calculate(
        config,
        now.add(const Duration(days: 1)),
      ).items.firstWhere((item) => item.type == PrayerType.fajr).time;
      expect(next.time, tomorrowFajr);
      expect(next.time.isAfter(now), isTrue);
    });
  });

  group('HomeTab widget', () {
    Widget harness({
      bool muted = false,
      bool standby = false,
      VoidCallback? onToggleMuted,
      VoidCallback? onToggleStandby,
      VoidCallback? onSyncNow,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: HomeTab(
            mosqueName: 'Masjid Agung Al-Hikmah',
            transportLabel: 'Bluetooth',
            tvPhase: PrayerPhase.normal,
            tvMuted: muted,
            tvStandby: standby,
            config: const MosqueConfig(
              latitude: -6.1754,
              longitude: 106.8272,
            ),
            totalKasMasuk: 5000000,
            totalKasKeluar: 750000,
            onToggleMuted: onToggleMuted ?? () {},
            onToggleStandby: onToggleStandby ?? () {},
            onSyncNow: onSyncNow ?? () {},
          ),
        ),
      );
    }

    testWidgets('menampilkan status TV, jam, kas, dan tombol aksi 56dp',
        (tester) async {
      // Layar tinggi agar seluruh ListView terbangun dalam satu frame.
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.text('TV Terhubung'), findsOneWidget);
      expect(find.textContaining('via Bluetooth'), findsOneWidget);
      expect(find.text('Masjid Agung Al-Hikmah'), findsOneWidget);
      expect(find.text('Sholat Berikutnya'), findsOneWidget);
      expect(find.textContaining('Mulai dalam'), findsOneWidget);

      // Saldo = 5.000.000 - 750.000.
      expect(find.textContaining('4.250.000'), findsOneWidget);
      expect(find.textContaining('5.000.000'), findsOneWidget);

      // Ketiga tombol Aksi Cepat setinggi 56dp.
      for (final label in ['Senyap', 'Standby', 'Sinkron']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(SizedBox),
        );
        expect(tester.getSize(button.first).height, 56);
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('status senyap & standby tercermin di kartu status',
        (tester) async {
      await tester.pumpWidget(harness(muted: true, standby: true));
      await tester.pump();

      expect(find.text('TV Standby'), findsOneWidget);
      expect(find.textContaining('Senyap'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ketukan tombol memanggil callback masing-masing',
        (tester) async {
      var mute = 0, standby = 0, sync = 0;
      await tester.pumpWidget(harness(
        onToggleMuted: () => mute++,
        onToggleStandby: () => standby++,
        onSyncNow: () => sync++,
      ));
      await tester.pump();

      await tester.tap(find.text('Senyap'));
      await tester.tap(find.text('Standby'));
      await tester.tap(find.text('Sinkron'));
      await tester.pump();

      expect(mute, 1);
      expect(standby, 1);
      expect(sync, 1);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
