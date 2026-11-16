import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/settings/settings_tab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes toggle tampilan kartu samping TV di tab Pengaturan:
/// `showKas` (tampilkan kas) & `hasFridayPrayer` (ada Jumatan).
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
    required bool showKas,
    required bool hasFridayPrayer,
    ValueChanged<bool>? onShowKasChanged,
    ValueChanged<bool>? onHasFridayPrayerChanged,
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
          showKas: showKas,
          hasFridayPrayer: hasFridayPrayer,
          onShowKasChanged: onShowKasChanged ?? (_) {},
          onHasFridayPrayerChanged: onHasFridayPrayerChanged ?? (_) {},
          isFetchingLocation: false,
          isConnected: true,
          tvPhase: PrayerPhase.normal,
          onFetchLocation: () {},
          onSaveConfig: () {},
          onSendQuickAction: (_) {},
          onShowSimulation: (_) {},
          onExportBackup: () {},
          onImportBackup: () {},
        ),
      ),
    );
  }

  Finder switchTile(String title) => find.ancestor(
        of: find.text(title),
        matching: find.byType(SwitchListTile),
      );

  Future<void> reveal(WidgetTester tester, String title) async {
    // Seret ListView manual sampai target terbangun: scrollUntilVisible
    // tidak bisa dipakai karena halaman ini punya banyak Scrollable
    // (GridView + Scrollable internal tiap TextField).
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

  testWidgets('kedua toggle tampil dengan nilai dari config', (tester) async {
    await tester.pumpWidget(harness(showKas: false, hasFridayPrayer: true));
    await tester.pump();

    await reveal(tester, 'Tampilkan Kas Masjid');
    final kasTile = tester.widget<SwitchListTile>(
      switchTile('Tampilkan Kas Masjid'),
    );
    expect(kasTile.value, isFalse);

    await reveal(tester, 'Ada Shalat Jumat (Jumatan)');
    final fridayTile = tester.widget<SwitchListTile>(
      switchTile('Ada Shalat Jumat (Jumatan)'),
    );
    expect(fridayTile.value, isTrue);
  });

  testWidgets('mengubah toggle memanggil callback masing-masing',
      (tester) async {
    bool? kasValue;
    bool? fridayValue;
    await tester.pumpWidget(harness(
      showKas: true,
      hasFridayPrayer: true,
      onShowKasChanged: (v) => kasValue = v,
      onHasFridayPrayerChanged: (v) => fridayValue = v,
    ));
    await tester.pump();

    await reveal(tester, 'Tampilkan Kas Masjid');
    await tester.tap(switchTile('Tampilkan Kas Masjid'));
    await tester.pump();
    expect(kasValue, isFalse);

    await reveal(tester, 'Ada Shalat Jumat (Jumatan)');
    await tester.tap(switchTile('Ada Shalat Jumat (Jumatan)'));
    await tester.pump();
    expect(fridayValue, isFalse);
  });

  bool? fieldEnabled(WidgetTester tester, String label) {
    final field = tester.widget<TextField>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(TextField),
      ),
    );
    return field.enabled;
  }

  testWidgets('Jumatan mati: field khutbah, khatib & muadzin non-aktif',
      (tester) async {
    await tester.pumpWidget(harness(showKas: true, hasFridayPrayer: false));
    await tester.pump();

    await reveal(tester, 'Durasi Khutbah');
    expect(fieldEnabled(tester, 'Durasi Khutbah'), isFalse);
    expect(fieldEnabled(tester, 'Nama Khatib'), isFalse);
    expect(fieldEnabled(tester, 'Nama Muadzin'), isFalse);
  });

  testWidgets('Jumatan aktif: field Jumat bisa diedit', (tester) async {
    await tester.pumpWidget(harness(showKas: true, hasFridayPrayer: true));
    await tester.pump();

    await reveal(tester, 'Nama Khatib');
    expect(fieldEnabled(tester, 'Nama Khatib'), isTrue);
  });
}
