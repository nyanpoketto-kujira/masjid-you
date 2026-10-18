import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

import 'package:tv_display/theme/app_theme.dart';
import 'package:tv_display/widgets/header_clock.dart';

Widget _wrap(HeaderClock child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

Future<void> _pump(WidgetTester tester, HeaderClock header) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(_wrap(header));
}

const _config = MosqueConfig(name: 'Test Masjid', address: 'Jl. Test');

void main() {
  testWidgets('chip Mode Bluetooth tampil sebagai peringatan saat gagal',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
        btActive: false,
        btError: true,
        btStatus: 'Mode Bluetooth: gagal — cek Bluetooth',
      ),
    );
    expect(find.textContaining('Mode Bluetooth: gagal'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
  });

  testWidgets('chip Mode Bluetooth tampil dengan status menyiapkan saat listening',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
        btStatus: 'Mode Bluetooth: menyiapkan...',
      ),
    );
    expect(find.textContaining('Mode Bluetooth: menyiapkan'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
  });

  testWidgets('chip Mode Bluetooth tampil dengan nama perangkat saat aktif',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
        btActive: true,
        btStatus: 'Mode Bluetooth: aktif (SM-X135G)',
      ),
    );
    expect(find.textContaining('Mode Bluetooth: aktif'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth_connected), findsOneWidget);
  });

  testWidgets('chip Mode Direct tampil dengan SSID saat hotspot aktif',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
        p2pActive: true,
        p2pSsid: 'AndroidAP-ABC',
        p2pIp: '10.111.222.1',
      ),
    );
    expect(find.textContaining('Mode Direct: AndroidAP-ABC'), findsOneWidget);
    expect(find.textContaining('10.111.222.1'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_tethering), findsOneWidget);
  });

  testWidgets(
      'saat P2P nonaktif, chip Mode Direct tidak tampil (Bluetooth jadi indikator)',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
        p2pError: true,
        p2pStatus: 'Mode Direct: nonaktif',
      ),
    );
    expect(find.textContaining('Mode Direct'), findsNothing);
  });

  testWidgets('tanpa info sync, chip Mode Bluetooth/Direct tidak tampil',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
      ),
    );
    expect(find.textContaining('Mode Bluetooth'), findsNothing);
    expect(find.textContaining('Mode Direct'), findsNothing);
  });
}
