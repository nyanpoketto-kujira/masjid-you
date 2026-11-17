import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/widgets/background_slideshow.dart';

/// Tes ADR-031: logika rotasi slideshow gambar latar TV.
void main() {
  // PNG 1x1 valid (dua warna berbeda) sebagai fixture gambar.
  const pngA =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  const pngB =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

  BackgroundImage img(String id, {bool active = true}) =>
      BackgroundImage(id: id, base64Image: pngA, isActive: active);

  group('nextSlideshowIndex', () {
    test('maju satu langkah', () {
      expect(nextSlideshowIndex(0, 3), 1);
      expect(nextSlideshowIndex(1, 3), 2);
    });

    test('wrap-around ke awal setelah gambar terakhir', () {
      expect(nextSlideshowIndex(2, 3), 0);
      expect(nextSlideshowIndex(4, 5), 0);
    });

    test('aman untuk 0 dan 1 gambar', () {
      expect(nextSlideshowIndex(0, 0), 0);
      expect(nextSlideshowIndex(0, 1), 0);
      expect(nextSlideshowIndex(5, 1), 0);
    });

    test('indeks negatif / di luar rentang dinormalkan', () {
      expect(nextSlideshowIndex(-1, 3), 1);
      expect(nextSlideshowIndex(7, 3), 2);
    });
  });

  Widget harness(List<BackgroundImage> images, {int interval = 5}) {
    return MaterialApp(
      home: Scaffold(
        body: BackgroundSlideshow(
          images: images,
          intervalSeconds: interval,
          fallback: const Text('FALLBACK'),
        ),
      ),
    );
  }

  testWidgets('daftar kosong -> fallback', (tester) async {
    await tester.pumpWidget(harness(const []));
    await tester.pump();
    expect(find.text('FALLBACK'), findsOneWidget);
  });

  testWidgets('semua gambar non-aktif -> fallback', (tester) async {
    await tester.pumpWidget(harness([img('a', active: false)]));
    await tester.pump();
    expect(find.text('FALLBACK'), findsOneWidget);
  });

  testWidgets('satu gambar aktif tampil statis (tidak berotasi)',
      (tester) async {
    await tester.pumpWidget(harness([
      BackgroundImage(id: 'a', base64Image: pngA),
      BackgroundImage(id: 'b', base64Image: pngB, isActive: false),
    ]));
    await tester.pump();
    expect(find.byKey(const ValueKey('bg-a')), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(find.byKey(const ValueKey('bg-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('bg-b')), findsNothing);
  });

  testWidgets('dua gambar bergantian sesuai interval + wrap-around',
      (tester) async {
    await tester.pumpWidget(harness([
      BackgroundImage(id: 'a', base64Image: pngA),
      BackgroundImage(id: 'b', base64Image: pngB),
    ], interval: 5));
    await tester.pump();
    expect(find.byKey(const ValueKey('bg-a')), findsOneWidget);

    // Lewati interval + animasi crossfade.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const ValueKey('bg-b')), findsOneWidget);

    // Interval berikutnya: kembali ke gambar pertama.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const ValueKey('bg-a')), findsOneWidget);
  });

  testWidgets('bytes gambar rusak -> fallback, bukan crash', (tester) async {
    await tester.pumpWidget(harness([
      const BackgroundImage(id: 'rusak', base64Image: '!!!bukan-base64!!!'),
    ]));
    await tester.pump();
    expect(find.text('FALLBACK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
