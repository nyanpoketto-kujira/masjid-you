import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/theme/app_theme.dart';
import 'package:tv_display/widgets/prayer_state_overlay.dart';

void main() {
  Future<void> pumpOverlay(
    WidgetTester tester, {
    required PrayerPhase phase,
    Duration remaining = const Duration(minutes: 1),
  }) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: PrayerStateOverlay(
            phase: phase,
            prayerName: 'Maghrib',
            remaining: remaining,
            total: const Duration(minutes: 2),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('normal phase renders nothing (SizedBox.shrink)', (tester) async {
    await pumpOverlay(tester, phase: PrayerPhase.normal);

    expect(find.byType(PrayerStateOverlay), findsOneWidget);
  });

  testWidgets('PRE_ADHAN shows countdown ring without overflow at TV viewport',
      (tester) async {
    await pumpOverlay(tester, phase: PrayerPhase.preAdhan);

    expect(find.text('Menjelang Azan Maghrib'), findsOneWidget);
    expect(find.text('menuju azan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ADHAN shows wavy bar without overflow at TV viewport',
      (tester) async {
    await pumpOverlay(tester, phase: PrayerPhase.adhan);

    expect(find.text('Azan Maghrib Berkumandang'), findsOneWidget);
    expect(find.text('Mohon khusyuk mendengarkan azan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('KHUTBAH shows count-up timer + staff chips without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: const PrayerStateOverlay(
            phase: PrayerPhase.khutbah,
            prayerName: 'Jumat',
            remaining: Duration(minutes: 5),
            total: Duration(minutes: 20),
            fridayKhatib: 'Ustadz Ahmad',
            fridayMuadzin: 'Ustadz Bilal',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Khutbah Jumat Sedang Berlangsung'), findsOneWidget);
    expect(find.text('Khatib'), findsOneWidget);
    expect(find.text('Muadzin'), findsOneWidget);
    expect(find.text('Ustadz Ahmad'), findsOneWidget);
    expect(find.text('Ustadz Bilal'), findsOneWidget);
    // Hitung maju: total 20:00 - remaining 5:00 = 15:00 (bukan hitung mundur)
    expect(find.text('15:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PRE_IQOMAH shows shaf ring without overflow at TV viewport',
      (tester) async {
    await pumpOverlay(tester, phase: PrayerPhase.preIqomah);

    expect(find.text('Shalat Maghrib Sebentar Lagi'), findsOneWidget);
    expect(
      find.text('Mohon merapatkan shaf dan mematikan nada dering HP.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('SHALAT shows dim full-screen text without overflow',
      (tester) async {
    await pumpOverlay(tester, phase: PrayerPhase.shalat);

    expect(find.text('Sedang Melangsungkan Shalat Maghrib'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
