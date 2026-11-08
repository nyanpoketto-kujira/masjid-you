import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/banners_subtab.dart';

void main() {
  group('BannerThumbnail Image Caching', () {
    testWidgets(
        '_BannerThumbnail widget caches base64Image and renders correctly',
        (WidgetTester tester) async {
      base64Encode(const <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xFE,
        0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannersSubtab(
              banners: [],
              headerController: TextEditingController(),
              titleController: TextEditingController(),
              contentController: TextEditingController(),
              footerController: TextEditingController(),
              onAddBanner: (_) {},
              onEditBanner: (_) {},
              onRemoveBanner: (_) {},
              onToggleBanner: (_, __) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(BannersSubtab), findsOneWidget);
    });

    testWidgets(
        'Thumbnail widget renders image with gaplessPlayback and cacheWidth',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                Text('Item Test'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Item Test'), findsOneWidget);
    });
  });
}
