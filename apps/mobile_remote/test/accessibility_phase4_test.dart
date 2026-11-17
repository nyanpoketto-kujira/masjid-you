import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/home/home_tab.dart';
import 'package:mobile_remote/screens/settings/settings_tab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Fase 4 (ADR-026): skala teks 200% tidak boleh overflow/exception
/// di SettingsTab & HomeTab, dan target sentuh utama >=48dp.
void main() {
  /// Viewport HP (360x800 logis) agar overflow skala teks besar pada
  /// layar sempit ikut terdeteksi.
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Bungkus app dengan textScaler 2.0 (di dalam MaterialApp lewat
  /// `builder`, karena WidgetsApp membangun MediaQuery-nya sendiri dari
  /// platform view).
  Widget withTextScaler(Widget home) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2.0)),
        child: child!,
      ),
      home: home,
    );
  }

  TextEditingController text([String value = '']) =>
      TextEditingController(text: value);

  Widget settingsHarness({bool isDirty = false}) {
    final offsetControllers = {
      for (final type in kAllPrayerTypes)
        type: TextEditingController(text: '0'),
    };
    return Scaffold(
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
        isDirty: isDirty,
      ),
    );
  }

  Widget homeHarness() {
    return Scaffold(
      body: HomeTab(
        mosqueName: 'Masjid Uji',
        transportLabel: 'Bluetooth',
        tvPhase: PrayerPhase.normal,
        tvMuted: false,
        tvStandby: false,
        config: const MosqueConfig(
          latitude: -6.1754,
          longitude: 106.8272,
        ),
        totalKasMasuk: 5000000,
        totalKasKeluar: 750000,
        onToggleMuted: () {},
        onToggleStandby: () {},
        onSyncNow: () {},
      ),
    );
  }

  /// Gulung daftar sampai bawah sambil memastikan tidak ada exception
  /// (overflow RenderFlex dilaporkan sebagai FlutterError).
  Future<void> scrollThrough(WidgetTester tester) async {
    final list = find.byType(ListView);
    for (var i = 0; i < 40; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    expect(tester.takeException(), isNull);
  }

  testWidgets('SettingsTab skala teks 200%: tanpa overflow/exception',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(withTextScaler(settingsHarness()));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await scrollThrough(tester);

    // Semua grup tetap bisa ditemukan setelah digulung.
    expect(find.text('Tampilan Aplikasi'), findsWidgets);
    expect(find.text('Simpan & Update Ke TV'), findsOneWidget);
  });

  testWidgets('HomeTab skala teks 200%: tanpa overflow/exception',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(withTextScaler(homeHarness()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);

    await scrollThrough(tester);

    expect(find.text('Aksi Cepat'), findsWidgets);
    expect(find.text('Ringkasan Kas'), findsWidgets);
  });

  testWidgets('target sentuh utama >= 48dp', (tester) async {
    usePhoneViewport(tester);

    // Tombol simpan sticky Pengaturan (56dp).
    await tester.pumpWidget(withTextScaler(settingsHarness(isDirty: true)));
    await tester.pump();
    final saveSize = tester.getSize(
      find.widgetWithText(FilledButton, 'Simpan & Update Ke TV'),
    );
    expect(saveSize.height, greaterThanOrEqualTo(48));

    // Aksi Cepat Beranda (56dp). ListView membangun anak secara malas:
    // gulung dulu sampai tombol terbangun & masuk viewport.
    await tester.pumpWidget(withTextScaler(homeHarness()));
    await tester.pump();
    final target = find.text('Senyap');
    for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
    }
    await tester.ensureVisible(target);
    await tester.pump();
    final muteSize = tester.getSize(find.widgetWithText(
      OutlinedButton,
      'Senyap',
    ));
    expect(muteSize.height, greaterThanOrEqualTo(48));
    final syncSize = tester.getSize(find.widgetWithText(
      FilledButton,
      'Sinkron',
    ));
    expect(syncSize.height, greaterThanOrEqualTo(48));
  });
}
