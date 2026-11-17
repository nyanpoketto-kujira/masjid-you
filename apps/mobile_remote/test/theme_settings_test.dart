import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/settings/settings_tab.dart';
import 'package:mobile_remote/theme/theme_preferences.dart';
import 'package:shared_models/shared_models.dart';

/// Tes seksi "Tampilan Aplikasi" di tab Pengaturan (Fase 0 refaktor UI):
/// SegmentedButton tema (Sistem/Terang/Gelap) & warna
/// (Ikuti Wallpaper/Hijau Masjid).
void main() {
  late Map<PrayerType, TextEditingController> offsetControllers;

  setUp(() {
    offsetControllers = {
      for (final type in kAllPrayerTypes)
        type: TextEditingController(text: '0'),
    };
  });

  tearDown(() {
    for (final c in offsetControllers.values) {
      c.dispose();
    }
  });

  TextEditingController text([String value = '']) =>
      TextEditingController(text: value);

  Widget harness({
    ThemeMode themeMode = ThemeMode.system,
    AppColorSource colorSource = AppColorSource.dynamic,
    ValueChanged<ThemeMode>? onThemeModeChanged,
    ValueChanged<AppColorSource>? onColorSourceChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SettingsTab(
          config: const MosqueConfig(),
          nameController: text('Masjid Uji'),
          addressController: text('Jl. Uji'),
          latitudeController: text('-6.2'),
          longitudeController: text('106.8'),
          prayerOffsetControllers: offsetControllers,
          preAdhanController: text('15'),
          adhanController: text('2'),
          preIqomahController: text('1'),
          shalatController: text('10'),
          khutbahController: text('20'),
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
          onSaveConfig: () {},
          onSendQuickAction: (_) {},
          onShowSimulation: (_) {},
          onExportBackup: () {},
          onImportBackup: () {},
          themeMode: themeMode,
          colorSource: colorSource,
          onThemeModeChanged: onThemeModeChanged,
          onColorSourceChanged: onColorSourceChanged,
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

  testWidgets('seksi tampil dengan pilihan sesuai preferensi saat ini',
      (tester) async {
    await tester.pumpWidget(harness(
      themeMode: ThemeMode.dark,
      colorSource: AppColorSource.seed,
    ));
    await tester.pump();

    await reveal(tester, 'Tampilan Aplikasi');

    final temaButton = tester.widget<SegmentedButton<ThemeMode>>(
      find.byType(SegmentedButton<ThemeMode>),
    );
    expect(temaButton.selected, {ThemeMode.dark});

    final warnaButton = tester.widget<SegmentedButton<AppColorSource>>(
      find.byType(SegmentedButton<AppColorSource>),
    );
    expect(warnaButton.selected, {AppColorSource.seed});
  });

  testWidgets('mengetuk segmen memanggil callback dengan nilai baru',
      (tester) async {
    ThemeMode? modeDipilih;
    AppColorSource? warnaDipilih;
    await tester.pumpWidget(harness(
      onThemeModeChanged: (v) => modeDipilih = v,
      onColorSourceChanged: (v) => warnaDipilih = v,
    ));
    await tester.pump();

    await reveal(tester, 'Terang');
    await tester.tap(find.text('Terang'));
    await tester.pump();
    expect(modeDipilih, ThemeMode.light);

    await reveal(tester, 'Hijau Masjid');
    await tester.tap(find.text('Hijau Masjid'));
    await tester.pump();
    expect(warnaDipilih, AppColorSource.seed);
  });
}
