import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/settings/settings_tab.dart';
import 'package:mobile_remote/widgets/stepper_row.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Fase 2 refaktor UI (ADR-024): grup bertajuk, baris stepper untuk
/// offset & durasi, dan sticky bottom bar "Simpan & Update Ke TV" yang
/// hanya aktif saat ada perubahan (dirty).
void main() {
  late Map<PrayerType, TextEditingController> offsetControllers;
  late TextEditingController preAdhanController;
  late TextEditingController khutbahController;

  setUp(() {
    offsetControllers = {
      for (final type in kAllPrayerTypes)
        type: TextEditingController(text: '0'),
    };
    preAdhanController = TextEditingController(text: '15');
    khutbahController = TextEditingController(text: '20');
  });

  tearDown(() {
    for (final c in offsetControllers.values) {
      c.dispose();
    }
    preAdhanController.dispose();
    khutbahController.dispose();
  });

  TextEditingController text([String value = '']) =>
      TextEditingController(text: value);

  Widget harness({bool isDirty = false, VoidCallback? onSaveConfig}) {
    return MaterialApp(
      home: Scaffold(
        body: SettingsTab(
          config: const MosqueConfig(),
          nameController: text('Masjid Uji'),
          addressController: text('Jl. Uji'),
          latitudeController: text('-6.2'),
          longitudeController: text('106.8'),
          prayerOffsetControllers: offsetControllers,
          preAdhanController: preAdhanController,
          adhanController: text('2'),
          preIqomahController: text('1'),
          shalatController: text('10'),
          khutbahController: khutbahController,
          fridayKhatibController: text('Ustadz Khatib'),
          fridayMuadzinController: text('Ustadz Bilal'),
          showKas: true,
          hasFridayPrayer: true,
          onShowKasChanged: (_) {},
          onHasFridayPrayerChanged: (_) {},
          isFetchingLocation: false,
          isConnected: true,
          tvPhase: PrayerPhase.normal,
          onFetchLocation: () {},
          onSaveConfig: onSaveConfig ?? () {},
          onSendQuickAction: (_) {},
          onShowSimulation: (_) {},
          onExportBackup: () {},
          onImportBackup: () {},
          isDirty: isDirty,
        ),
      ),
    );
  }

  Future<void> reveal(WidgetTester tester, String title) async {
    final target = find.text(title);
    for (var i = 0; i < 30; i++) {
      if (target.evaluate().isNotEmpty) {
        await tester.ensureVisible(target);
        await tester.pump();
        return;
      }
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pump();
    }
    fail('Tidak menemukan "$title" setelah scroll');
  }

  Finder stepperButton(String tooltip) => find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(IconButton),
      );

  bool stepperEnabled(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(stepperButton(tooltip)).onPressed != null;

  testWidgets('grup bertajuk Pengaturan tampil semua', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    for (final title in [
      'Masjid',
      'Lokasi & Jadwal',
      'Penyesuaian Waktu',
      'Durasi Tampilan TV',
      'Tampilan TV',
      'Tampilan Aplikasi',
      'Data',
    ]) {
      await reveal(tester, title);
      expect(find.text(title), findsWidgets);
    }
  });

  testWidgets('stepper offset menulis ke controller yang sama',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await reveal(tester, 'Subuh');

    expect(offsetControllers[PrayerType.fajr]!.text, '0');
    await tester.tap(stepperButton('Tambah Subuh'));
    await tester.pump();
    expect(offsetControllers[PrayerType.fajr]!.text, '1');
    await tester.tap(stepperButton('Tambah Subuh'));
    await tester.pump();
    expect(offsetControllers[PrayerType.fajr]!.text, '2');

    // Offset boleh negatif (geser jadwal lebih awal).
    await tester.tap(stepperButton('Kurangi Subuh'));
    await tester.pump();
    expect(offsetControllers[PrayerType.fajr]!.text, '1');

    // Di batas bawah -60: tombol kurang mati.
    offsetControllers[PrayerType.fajr]!.text = '-60';
    await tester.pump();
    expect(stepperEnabled(tester, 'Kurangi Subuh'), isFalse);
  });

  testWidgets('stepper durasi menulis ke controller yang sama',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await reveal(tester, 'Jelang Azan');

    expect(preAdhanController.text, '15');
    await tester.tap(stepperButton('Tambah Jelang Azan'));
    await tester.pump();
    expect(preAdhanController.text, '16');
  });

  testWidgets('tombol simpan sticky non-aktif bila tidak ada perubahan',
      (tester) async {
    await tester.pumpWidget(harness(isDirty: false));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Simpan & Update Ke TV'),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Ada perubahan belum disimpan'), findsNothing);
  });

  testWidgets('tombol simpan sticky aktif & memanggil onSaveConfig bila dirty',
      (tester) async {
    var saved = false;
    await tester.pumpWidget(
        harness(isDirty: true, onSaveConfig: () => saved = true));
    await tester.pump();

    expect(find.text('Ada perubahan belum disimpan'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Simpan & Update Ke TV'),
    );
    expect(button.onPressed, isNotNull);
    await tester.tap(find.text('Simpan & Update Ke TV'));
    await tester.pump();
    expect(saved, isTrue);
  });

  testWidgets('widget StepperRow menghormati batas min/max', (tester) async {
    final controller = TextEditingController(text: '60');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepperRow(
            label: 'Uji',
            controller: controller,
            min: -60,
            max: 60,
          ),
        ),
      ),
    );
    await tester.pump();

    // Di batas atas: tombol tambah mati, kurang hidup.
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Tambah Uji'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip('Kurangi Uji'));
    await tester.pump();
    expect(controller.text, '59');
  });
}
