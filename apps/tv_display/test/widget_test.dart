// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tv_display/main.dart';

void main() {
  testWidgets('MasjidYouTVApp loads smoke test', (WidgetTester tester) async {
    // Set TV screen dimensions (1920x1080)
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MasjidYouTVApp());

    // Verify app renders title or mosque name
    expect(find.textContaining('Masjid'), findsAtLeast(1));
  });

  testWidgets('TV layout has no overflow at small TV viewport', (WidgetTester tester) async {
    // Simulate emulator logical size (1920x1080 physical @ 2x density = 960x540)
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MasjidYouTVApp());
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Kas'), findsAtLeast(1));
    expect(find.textContaining('Pemasukan'), findsOneWidget);
    expect(find.textContaining('Pengeluaran'), findsOneWidget);
  });
}
