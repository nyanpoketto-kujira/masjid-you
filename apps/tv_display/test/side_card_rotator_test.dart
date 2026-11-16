import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/widgets/side_card_rotator.dart';

/// 1x1 PNG transparan, cukup untuk membuktikan gambar ter-decode & tampil.
const _png1x1 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';

void main() {
  // 13 Agustus 2026 = Kamis, 14 Agustus 2026 = Jumat.
  final thursday = DateTime(2026, 8, 13);
  final friday = DateTime(2026, 8, 14);

  final transactions = [
    KasTransaction(
      id: '1',
      type: KasType.masuk,
      amount: 1000000,
      description: 'Infaq',
      date: DateTime(2026, 8, 10),
    ),
  ];

  Widget harness({
    required MosqueConfig config,
    required DateTime date,
    List<SpecialImage> images = const [],
    Duration interval = const Duration(seconds: 10),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: SideCardRotator(
              config: config,
              transactions: transactions,
              images: images,
              date: date,
              interval: interval,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('hari biasa: kartu kas tampil statis', (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(),
      date: thursday,
    ));
    await tester.pump();

    expect(find.text('Kas Masjid'), findsOneWidget);
    expect(find.text('Petugas Jumat'), findsNothing);
  });

  testWidgets('hari Jumat: rotasi kas -> petugas Jumat -> gambar -> kas lagi',
      (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(),
      date: friday,
      images: const [
        SpecialImage(id: 'a', base64Image: _png1x1, caption: 'Gambar A'),
      ],
    ));
    await tester.pump();
    expect(find.text('Kas Masjid'), findsOneWidget);

    // Lewati satu interval + selesaikan animasi switcher (500ms).
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Petugas Jumat'), findsOneWidget);
    expect(find.text('Kas Masjid'), findsNothing);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Gambar A'), findsOneWidget);

    // Putaran berikutnya kembali ke kas.
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Kas Masjid'), findsOneWidget);
  });

  testWidgets('musholla: kartu Jumat tidak pernah tampil di hari Jumat',
      (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(hasFridayPrayer: false),
      date: friday,
      images: const [
        SpecialImage(id: 'a', base64Image: _png1x1, caption: 'Gambar A'),
      ],
    ));
    await tester.pump();
    expect(find.text('Kas Masjid'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    // Langsung ke gambar, petugas Jumat dilewati.
    expect(find.text('Gambar A'), findsOneWidget);
    expect(find.text('Petugas Jumat'), findsNothing);
  });

  testWidgets('kas dimatikan: rotasi mulai dari kartu berikutnya',
      (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(showKas: false),
      date: friday,
    ));
    await tester.pump();

    expect(find.text('Petugas Jumat'), findsOneWidget);
    expect(find.text('Kas Masjid'), findsNothing);
  });

  testWidgets('playlist kosong: placeholder tampil, tidak crash',
      (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(showKas: false, hasFridayPrayer: false),
      date: friday,
    ));
    await tester.pump();

    expect(find.text('Jagalah Shaf dan Shalatlah Tepat Waktu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gambar base64 rusak: fallback tampil, tidak crash',
      (tester) async {
    await tester.pumpWidget(harness(
      config: const MosqueConfig(showKas: false),
      date: thursday,
      images: const [
        SpecialImage(id: 'bad', base64Image: '!!!bukan-base64!!!'),
      ],
    ));
    await tester.pump();

    expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
