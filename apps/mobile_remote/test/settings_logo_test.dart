import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/settings/settings_tab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes ADR-032: seksi Logo Masjid di tab Pengaturan grup Masjid —
/// pratinjau 1:1, tombol Pilih/Ganti/Hapus, dan indikator progress
/// pengiriman Bluetooth.
void main() {
  TextEditingController text(String value) =>
      TextEditingController(text: value);

  // PNG 1x1 valid sebagai bytes logo contoh.
  final logoBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  );

  Future<void> pumpSettings(
    WidgetTester tester, {
    Uint8List? logoBytes,
    double? logoSendProgress,
    VoidCallback? onPickLogo,
    VoidCallback? onRemoveLogo,
  }) async {
    final offsetControllers = <PrayerType, TextEditingController>{
      for (final type in kAllPrayerTypes) type: text('0'),
    };
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTab(
            config: const MosqueConfig(),
            nameController: text('Masjid Uji'),
            addressController: text('Jl. Uji'),
            latitudeController: text('-6.2'),
            longitudeController: text('106.8'),
            prayerOffsetControllers: offsetControllers,
            preAdhanController: text('10'),
            adhanController: text('2'),
            preIqomahController: text('1'),
            shalatController: text('10'),
            khutbahController: text('30'),
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
            logoBytes: logoBytes,
            logoSendProgress: logoSendProgress,
            onPickLogo: onPickLogo,
            onRemoveLogo: onRemoveLogo,
          ),
        ),
      ),
    );
  }

  testWidgets('tanpa logo: ajakan memilih, tanpa tombol Hapus',
      (tester) async {
    var picks = 0;
    await pumpSettings(tester, onPickLogo: () => picks++);
    expect(find.text('Logo Masjid'), findsOneWidget);
    expect(find.text('Pilih Logo'), findsOneWidget);
    expect(find.text('Hapus'), findsNothing);
    expect(
      find.textContaining('Header TV tampil seperti biasa'),
      findsOneWidget,
    );
    await tester.tap(find.text('Pilih Logo'));
    expect(picks, 1);
  });

  testWidgets('dengan logo: pratinjau 1:1 + Ganti + Hapus berfungsi',
      (tester) async {
    var picks = 0;
    var removals = 0;
    await pumpSettings(
      tester,
      logoBytes: logoBytes,
      onPickLogo: () => picks++,
      onRemoveLogo: () => removals++,
    );
    final preview = find.byKey(const Key('settings-logo-preview'));
    expect(preview, findsOneWidget);
    // Pratinjau persis persegi (1:1), sama seperti tampil di TV.
    final size = tester.getSize(preview);
    expect(size.width, size.height);
    expect(find.text('Ganti Logo'), findsOneWidget);
    await tester.tap(find.text('Ganti Logo'));
    expect(picks, 1);
    await tester.tap(find.text('Hapus'));
    expect(removals, 1);
  });

  testWidgets('progress pengiriman logo tampil dengan persen',
      (tester) async {
    await pumpSettings(
      tester,
      logoBytes: logoBytes,
      logoSendProgress: 0.5,
    );
    expect(find.text('Mengirim logo 50%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('tanpa pengiriman berjalan, indikator tidak tampil',
      (tester) async {
    await pumpSettings(tester, logoBytes: logoBytes);
    expect(find.textContaining('Mengirim logo'), findsNothing);
  });
}
