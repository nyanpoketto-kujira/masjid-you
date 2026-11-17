import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/background_images_subtab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes ADR-031: editor Gambar Latar di Remote — sejajar pola test
/// editor Gambar Khusus, ditambah kartu opsi (stepper interval,
/// sakelar tanpa kompresi, indikator progress Bluetooth).
const _png1x1 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';

void main() {
  const images = [
    BackgroundImage(id: 'a', base64Image: _png1x1),
    BackgroundImage(id: 'b', base64Image: _png1x1, isActive: false),
  ];

  Widget harness({
    List<BackgroundImage> data = images,
    void Function(String, bool)? onToggle,
    void Function(String)? onRemove,
    TextEditingController? intervalController,
    bool sendUncompressed = false,
    void Function(bool)? onSendUncompressedChanged,
    double? sendProgress,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BackgroundImagesSubtab(
          images: data,
          onAddImage: (_) {},
          onRemoveImage: onRemove ?? (_) {},
          onToggleImage: onToggle ?? (_, __) {},
          intervalController:
              intervalController ?? TextEditingController(text: '30'),
          sendUncompressed: sendUncompressed,
          onSendUncompressedChanged: onSendUncompressedChanged ?? (_) {},
          sendProgress: sendProgress,
        ),
      ),
    );
  }

  testWidgets('daftar gambar latar tampil dengan nomor urut', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('Latar 1'), findsOneWidget);
    expect(find.text('Latar 2'), findsOneWidget);
  });

  testWidgets('daftar kosong menampilkan empty state', (tester) async {
    await tester.pumpWidget(harness(data: const []));
    await tester.pump();

    expect(find.text('Belum ada gambar latar'), findsOneWidget);
    expect(find.text('Tambah Gambar'), findsWidgets);
  });

  testWidgets('sakelar gambar memanggil onToggleImage', (tester) async {
    String? toggledId;
    bool? toggledValue;
    await tester.pumpWidget(harness(onToggle: (id, val) {
      toggledId = id;
      toggledValue = val;
    }));
    await tester.pump();

    // Switch pertama di pohon adalah sakelar opsi kirim di kartu atas;
    // yang ditarget adalah sakelar pada kartu 'Latar 1'.
    final firstCard = find.ancestor(
      of: find.text('Latar 1'),
      matching: find.byType(Card),
    );
    await tester
        .tap(find.descendant(of: firstCard, matching: find.byType(Switch)));
    await tester.pump();
    expect(toggledId, 'a');
    expect(toggledValue, isFalse);
  });

  testWidgets('tombol hapus memanggil onRemoveImage', (tester) async {
    String? removedId;
    await tester.pumpWidget(harness(onRemove: (id) => removedId = id));
    await tester.pump();

    await tester.tap(find.text('Hapus').first);
    await tester.pump();
    expect(removedId, 'a');
  });

  testWidgets('stepper interval menulis nilai baru ke controller',
      (tester) async {
    final controller = TextEditingController(text: '30');
    addTearDown(controller.dispose);
    await tester.pumpWidget(harness(intervalController: controller));
    await tester.pump();

    expect(find.text('Interval Slideshow'), findsOneWidget);
    expect(find.text('30 dtk'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah Interval Slideshow'));
    await tester.pump();
    expect(controller.text, '31');
    expect(find.text('31 dtk'), findsOneWidget);
  });

  testWidgets('sakelar tanpa kompresi memanggil callback', (tester) async {
    bool? changedTo;
    await tester.pumpWidget(harness(
      onSendUncompressedChanged: (v) => changedTo = v,
    ));
    await tester.pump();

    expect(find.text('Kirim tanpa kompresi'), findsOneWidget);
    await tester.tap(find.text('Kirim tanpa kompresi'));
    await tester.pump();
    expect(changedTo, isTrue);
  });

  testWidgets('progress pengiriman Bluetooth tampil determinate + persen',
      (tester) async {
    await tester.pumpWidget(harness(sendProgress: 0.4));
    await tester.pump();

    expect(find.text('Mengirim 40%'), findsOneWidget);
    final indicator = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(indicator.value, 0.4);
  });

  testWidgets('tanpa pengiriman berjalan, indikator tidak tampil',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
