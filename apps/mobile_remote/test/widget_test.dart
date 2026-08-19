// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_remote/main.dart';

void main() {
  testWidgets('MasjidYouRemoteApp loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pump();

    // Verify title loads
    expect(find.text('Remote Masjid DKM'), findsOneWidget);
  });

  testWidgets('Tes tab shows phase-force buttons', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MasjidYouRemoteApp());
    await tester.pump();

    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Tes'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Menu Tes — Simulasi Waktu Shalat'), findsOneWidget);
    expect(find.text('Paksa Fase — Hari Biasa'), findsOneWidget);
    expect(find.text('Normal (Standby)'), findsOneWidget);
    expect(find.text('ADHAN · Azan Berkumandang'), findsOneWidget);
    expect(find.text('SHALAT · Shalat Berlangsung'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('KHUTBAH · Khutbah Jumat'),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paksa Fase — Hari Jumat'), findsOneWidget);
    expect(find.text('KHUTBAH · Khutbah Jumat'), findsOneWidget);
  });
}
