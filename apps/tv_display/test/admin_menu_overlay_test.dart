import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_display/theme/app_theme.dart';
import 'package:tv_display/widgets/admin_menu_overlay.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('panel tampil di sisi kanan & container rounded biasa',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: false,
      pin: null,
      statusText: 'Mode Bluetooth: tidak aktif',
      isError: false,
      ipText: 'IP TV: 192.168.1.10',
      onStartPairingMode: () {},
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    // Selesaikan animasi slide-in.
    await tester.pumpAndSettle();

    // Panel: width 400, anchor kanan, full height.
    final panel = tester.getRect(find.byType(SlideTransition).last);
    expect(panel.width, 400);
    expect(panel.right, 1920);
    expect(panel.top, 0);
    expect(panel.bottom, 1080);

    // Judul & toggle tampil.
    expect(find.text('Menu Admin'), findsOneWidget);
    expect(find.text('Nyalakan Koneksi'), findsOneWidget);

    // Container toggle memakai RoundedRectangleBorder 16 (bukan M3ShapeBorder).
    final containers = tester.widgetList<Container>(find.byType(Container));
    final toggleBox = containers.firstWhere((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.borderRadius == BorderRadius.circular(16);
    });
    expect(toggleBox, isNotNull);
  });

  testWidgets('PIN tampil saat koneksi aktif', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: true,
      pin: '4838',
      statusText: 'Mode Bluetooth: siap — tunggu Remote menyambung',
      isError: false,
      ipText: 'IP TV: 192.168.1.10',
      onStartPairingMode: () {},
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.text('4838'), findsOneWidget);
    expect(find.text('PIN Koneksi'), findsOneWidget);
  });

  testWidgets('tombol Back pada panel memicu onClose setelah slide-out',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    var closed = false;
    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: false,
      pin: null,
      statusText: null,
      isError: false,
      ipText: 'IP TV: 192.168.1.10',
      onStartPairingMode: () {},
      onToggleBluetooth: (_) {},
      onClose: () {
        closed = true;
      },
    )));
    await tester.pumpAndSettle();

    // Item 'Kembali' ada di daftar aksi D-Pad; mengetapnya menutup panel.
    expect(find.text('Kembali'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
  });

  testWidgets('fokus D-Pad: toggle autofocus, OK memicu toggle, '
      'panah bawah pindah fokus', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool? toggledTo;
    var closed = false;
    var btOn = false;

    Widget buildPanel() => _wrap(AdminMenuOverlay(
          btEnabled: btOn,
          pin: '4838',
          statusText: null,
          isError: false,
          ipText: 'IP TV: 192.168.1.10',
          onStartPairingMode: () {},
          onToggleBluetooth: (v) {
            toggledTo = v;
            btOn = v;
          },
          onClose: () => closed = true,
        ));

    await tester.pumpWidget(buildPanel());
    await tester.pumpAndSettle();

    // Item pertama (toggle) memakai Focus autofocus.
    expect(
      find.descendant(
        of: find.byType(AdminMenuOverlay),
        matching: find.byWidgetPredicate(
            (w) => w is Focus && w is! FocusScope && w.autofocus),
      ),
      findsOneWidget,
    );

    // OK/Enter pada toggle memanggil onToggleBluetooth(true).
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(toggledTo, isTrue);

    // Daftar aksi kini hanya: toggle -> kembali. Panah bawah memindahkan
    // fokus ke 'Kembali'; OK di sana menutup panel.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('IP TV tampil di panel (ADR-029)', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: false,
      pin: null,
      statusText: null,
      isError: false,
      ipText: 'IP TV: 192.168.1.23',
      onStartPairingMode: () {},
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.text('IP TV: 192.168.1.23'), findsOneWidget);
  });

  testWidgets('Mode Pairing hanya tampil saat koneksi aktif & bisa diklik',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    var pairingCalls = 0;
    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: true,
      pin: '4838',
      statusText: null,
      isError: false,
      ipText: 'IP TV: tidak ada jaringan',
      onStartPairingMode: () => pairingCalls++,
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.text('Mode Pairing'), findsOneWidget);
    await tester.tap(find.text('Mode Pairing'));
    await tester.pump();
    expect(pairingCalls, 1);

    // Koneksi nonaktif: aksi Mode Pairing tidak ditawarkan.
    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: false,
      pin: null,
      statusText: null,
      isError: false,
      ipText: 'IP TV: tidak ada jaringan',
      onStartPairingMode: () => pairingCalls++,
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    await tester.pumpAndSettle();
    expect(find.text('Mode Pairing'), findsNothing);
  });

  testWidgets('countdown Mode Pairing tampil saat jendela aktif',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap(AdminMenuOverlay(
      btEnabled: true,
      pin: '4838',
      statusText: null,
      isError: false,
      ipText: 'IP TV: 192.168.1.23',
      pairingActive: true,
      pairingRemainingSeconds: 272,
      onStartPairingMode: () {},
      onToggleBluetooth: (_) {},
      onClose: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.text('Mode Pairing aktif — 04:32'), findsOneWidget);
  });

  group('formatPairingCountdown', () {
    test('format mm:ss dengan padding nol', () {
      expect(formatPairingCountdown(300), '05:00');
      expect(formatPairingCountdown(272), '04:32');
      expect(formatPairingCountdown(9), '00:09');
      expect(formatPairingCountdown(0), '00:00');
      expect(formatPairingCountdown(-5), '00:00');
    });
  });
}
