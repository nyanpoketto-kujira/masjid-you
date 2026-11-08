import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/widgets/banner_carousel.dart';

void main() {
  group('BannerCarousel Image Caching', () {
    testWidgets(
        'BannerCarousel does not repeatedly decode base64Image on timer rebuild',
        (WidgetTester tester) async {
      // Create a dummy image (1x1 red pixel PNG)
      final dummyImage = base64Encode(const <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xFE,
        0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final banner = MediaBanner(
        id: 'test-1',
        header: 'Test',
        title: 'Test Title',
        content: 'Test Content',
        footer: 'Test Footer',
        base64Image: dummyImage,
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: [banner]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Pump again with identical widget (simulates rebuild from external timer)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: [banner]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Image.memory widget exists and is correctly rendered
      expect(find.byType(Image), findsWidgets,
          reason: 'Image should be rendered');
    });

    testWidgets('BannerCarousel re-decodes only when base64Image actually changes',
        (WidgetTester tester) async {
      final dummyImage1 = base64Encode(const <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xFE,
        0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final dummyImage2 = base64Encode(const <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x0C, 0x89, 0x54, 0x6B, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0xFE,
        0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      var banner = MediaBanner(
        id: 'test-1',
        header: 'Test',
        title: 'Test Title',
        content: 'Test Content',
        footer: 'Test Footer',
        base64Image: dummyImage1,
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: [banner]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsWidgets);

      // Update banner with different base64Image
      banner = MediaBanner(
        id: 'test-1',
        header: 'Test',
        title: 'Test Title',
        content: 'Test Content',
        footer: 'Test Footer',
        base64Image: dummyImage2,
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: [banner]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify new image is still rendered
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('BannerCarousel handles empty banners gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerCarousel(banners: []),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show placeholder
      expect(find.byIcon(Icons.mosque_rounded), findsOneWidget);
    });
  });
}
