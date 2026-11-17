import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_display/main.dart';
import 'package:tv_display/theme/app_theme.dart';

/// Tes ADR-030: tombol OK (select) remote TV di layar utama.
///
/// - Menu admin tertutup + fase normal: OK tidak melakukan apa pun
///   (tidak membuka menu, tidak error) — skip hanya untuk fase aktif.
/// - Menu admin terbuka: OK tetap milik menu (mengaktifkan item fokus,
///   yaitu toggle koneksi), BUKAN dikonsumsi handler skip fase.
///
/// Transisi skipToNextPhase() sendiri diuji tuntas di
/// prayer_state_machine_test.dart (semua fase termasuk Jumat).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Wajib: tanpa mock ini, SharedPreferences.getInstance() tidak pernah
    // selesai di zona fake-async dan rantai init layar (store -> server
    // lokal -> host Bluetooth) macet sebelum host dibuat.
    SharedPreferences.setMockInitialValues({});
  });

  Widget harness() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const MasjidDisplayScreen(autoPrayerCycle: false),
    );
  }

  /// Init layar memuat store + mengikat server WebSocket lokal (I/O nyata)
  /// sebelum host Bluetooth dibuat; di zona fake-async test, rantai itu
  /// hanya selesai bila event loop nyata diberi kesempatan jalan.
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
  }

  testWidgets('OK saat menu tertutup & fase normal: no-op aman',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpScreen(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Menu admin tidak ikut terbuka; layar utama tetap tampil.
    expect(find.text('Menu Admin'), findsNothing);
    expect(find.textContaining('Masjid'), findsAtLeast(1));
  });

  testWidgets('OK saat menu admin terbuka mengaktifkan item menu '
      '(bukan skip fase)', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpScreen(tester);

    // Tombol Back remote membuka menu admin (PopScope root) — disimulasikan
    // sebagai pop route sistem, bukan ketukan tombol di layar. Dua pump:
    // frame pertama memasang panel (ticker animasi mulai), frame kedua
    // menyelesaikan slide-in & memantapkan fokus D-Pad.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Menu Admin'), findsOneWidget);
    expect(find.text('Nyalakan Koneksi'), findsOneWidget);
    // Toggle masih OFF: aksi Mode Pairing belum ditawarkan.
    expect(find.text('Mode Pairing'), findsNothing);

    // OK pada item fokus (toggle) menyalakan koneksi: menu tetap terbuka
    // dan aksi Mode Pairing muncul — bukti OK diteruskan ke menu.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Menu Admin'), findsOneWidget);
    expect(find.text('Mode Pairing'), findsOneWidget);
  });
}
