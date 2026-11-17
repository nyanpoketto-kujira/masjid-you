import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

import 'package:mobile_remote/screens/simulation/schedule_simulation_dialog.dart';

// CATATAN REGRESI (ADR-033): file test ini SENGAJA tidak memanggil
// initializeDateFormatting. Versi lama dialog memakai
// DateFormat('EEEE, d MMMM yyyy', 'id_ID') yang melempar
// LocaleDataException bila data locale intl belum diinisialisasi,
// sehingga dialog tampil blank di perangkat. Dialog yang baru memakai
// format tanggal manual (formatTanggalId) dan harus terbangun penuh
// dalam kondisi persis seperti ini.
void main() {
  const config = MosqueConfig(latitude: -6.1754, longitude: 106.8272);

  Future<void> pumpDialog(
    WidgetTester tester, {
    required DateTime at,
    bool hasFridayPrayer = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleSimulationDialog(
            config: config,
            hasFridayPrayer: hasFridayPrayer,
            initialDateTime: at,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dialog terbangun penuh tanpa error locale (regresi blank)',
      (tester) async {
    // Selasa, 17 November 2026 pukul 03.00.
    await pumpDialog(tester, at: DateTime(2026, 11, 17, 3, 0));
    expect(tester.takeException(), isNull);
    expect(find.text('Simulasi Perhitungan Jadwal'), findsOneWidget);
    expect(find.text('Selasa, 17 November 2026'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);
    expect(find.textContaining('Lokasi: -6.1754, 106.8272'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);
  });

  testWidgets('enam baris jadwal tampil dan shalat berikutnya disorot',
      (tester) async {
    // Waktu simulasi diturunkan dari jadwal terhitung (30 menit sebelum
    // Subuh) agar tidak bergantung zona waktu mesin — lihat ADR-034.
    final reference = PrayerSchedule.calculate(
      config,
      DateTime(2026, 11, 17, 12, 0),
    );
    final fajr = reference.items
        .firstWhere((item) => item.type == PrayerType.fajr)
        .time;
    final at = fajr.subtract(const Duration(minutes: 30));
    await pumpDialog(tester, at: at);
    final expected = PrayerSchedule.calculate(config, at);
    expect(expected.items, hasLength(6));
    expect(expected.nextPrayer, PrayerType.fajr);
    for (final item in expected.items) {
      expect(
        find.text(item.type.displayNameForDate(item.time)),
        findsOneWidget,
        reason: 'baris ${item.type} harus tampil',
      );
      expect(
        find.textContaining(item.formattedTime),
        findsWidgets,
        reason: 'jam ${item.type} harus tampil',
      );
    }
    // Tepat satu baris disorot sebagai shalat berikutnya (Subuh).
    expect(find.textContaining('SELANJUTNYA'), findsOneWidget);
    expect(find.byIcon(Icons.alarm_on), findsOneWidget);
  });

  testWidgets('label Dzuhur menjadi Jumat di hari Jumat bila Jumatan aktif',
      (tester) async {
    // Jumat, 20 November 2026.
    await pumpDialog(tester, at: DateTime(2026, 11, 20, 3, 0));
    expect(find.text('Jumat'), findsOneWidget);
    expect(find.text('Dzuhur'), findsNothing);
  });

  testWidgets('label tetap Dzuhur di hari Jumat bila Jumatan nonaktif',
      (tester) async {
    await pumpDialog(
      tester,
      at: DateTime(2026, 11, 20, 3, 0),
      hasFridayPrayer: false,
    );
    expect(find.text('Dzuhur'), findsOneWidget);
    expect(find.text('Jumat'), findsNothing);
  });

  testWidgets('larut malam: shalat berikutnya Subuh besok tetap disorot',
      (tester) async {
    // 30 menit setelah Isya — semua jadwal hari ini sudah lewat
    // (diturunkan dari jadwal terhitung, kebal zona waktu; ADR-034).
    final reference = PrayerSchedule.calculate(
      config,
      DateTime(2026, 11, 17, 12, 0),
    );
    final isya = reference.items
        .firstWhere((item) => item.type == PrayerType.isha)
        .time;
    final at = isya.add(const Duration(minutes: 30));
    await pumpDialog(tester, at: at);
    final expected = PrayerSchedule.calculate(config, at);
    expect(expected.nextPrayer, PrayerType.fajr);
    expect(find.textContaining('SELANJUTNYA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
