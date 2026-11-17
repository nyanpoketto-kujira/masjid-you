import 'dart:convert';

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
  testWidgets('nama & alamat masjid tetap tampil tanpa chip status',
      (tester) async {
    await _pump(
      tester,
      HeaderClock(
        config: _config,
        currentTime: DateTime(2026, 9, 12, 19, 16),
      ),
    );
    expect(find.text('Test Masjid'), findsOneWidget);
    expect(find.text('Jl. Test'), findsOneWidget);
    // Chip status sync dihapus: tidak ada teks Mode Bluetooth / Remote Sync IP.
    expect(find.textContaining('Mode Bluetooth'), findsNothing);
    expect(find.textContaining('Mode Direct'), findsNothing);
    expect(find.textContaining('Remote Sync IP'), findsNothing);
  });

  group('logo masjid (ADR-032)', () {
    // PNG 1x1 valid sebagai bytes logo contoh.
    final logoBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
      'z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );

    testWidgets('tanpa logo: tidak ada kotak logo sama sekali',
        (tester) async {
      await _pump(
        tester,
        HeaderClock(
          config: _config,
          currentTime: DateTime(2026, 9, 12, 19, 16),
        ),
      );
      expect(find.byKey(const Key('header-logo')), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('dengan logo: kotak 1:1 tampil dan nama bergeser ke kanan',
        (tester) async {
      await _pump(
        tester,
        HeaderClock(
          config: _config,
          currentTime: DateTime(2026, 9, 12, 19, 16),
        ),
      );
      final nameXWithoutLogo = tester.getTopLeft(find.text('Test Masjid')).dx;

      await _pump(
        tester,
        HeaderClock(
          config: _config,
          currentTime: DateTime(2026, 9, 12, 19, 16),
          logoBytes: logoBytes,
        ),
      );
      final logoFinder = find.byKey(const Key('header-logo'));
      expect(logoFinder, findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      // Kotak logo persis persegi 1:1 sebesar HeaderClock.logoSize.
      final logoSize = tester.getSize(logoFinder);
      expect(logoSize.width, HeaderClock.logoSize);
      expect(logoSize.height, HeaderClock.logoSize);
      expect(logoSize.width, logoSize.height);
      // Nama masjid bergeser ke kanan sebesar lebar logo + jaraknya.
      final nameXWithLogo = tester.getTopLeft(find.text('Test Masjid')).dx;
      expect(nameXWithLogo, greaterThan(nameXWithoutLogo));
      expect(
        nameXWithLogo - nameXWithoutLogo,
        HeaderClock.logoSize + 16,
      );
    });
  });
}
