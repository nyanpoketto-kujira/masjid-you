import 'package:flutter/material.dart';
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
      onToggleBluetooth: (_) {},
      onClose: () {},
      onCopyPin: () {},
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
      onToggleBluetooth: (_) {},
      onClose: () {},
      onCopyPin: () {},
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
      onToggleBluetooth: (_) {},
      onClose: () {
        closed = true;
      },
      onCopyPin: () {},
    )));
    await tester.pumpAndSettle();

    // Simulasi Back: panggil onPopInvokedWithResult lewat didPopWidget...
    // PopScope menangkap Back secara sistem; di test kita panggil handler
    // langsung via PopScope widget.
    final popScope = tester.widget<PopScope>(find.byType(PopScope).first);
    // PopScope tidak expose callback; gunakan mekanisme system navigator.
    final dynamicState = tester.state(find.byType(AdminMenuOverlay));
    // Trigger close via tombol Kembali yang visible.
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(dynamicState, isNotNull);
    expect(popScope.canPop, isFalse);
  });
}
