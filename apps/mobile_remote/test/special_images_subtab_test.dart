import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/special_images_subtab.dart';
import 'package:shared_models/shared_models.dart';

/// 1x1 PNG transparan.
const _png1x1 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';

void main() {
  const images = [
    SpecialImage(id: 'a', base64Image: _png1x1, caption: 'Gambar Satu'),
    SpecialImage(
        id: 'b', base64Image: _png1x1, caption: 'Gambar Dua', isActive: false),
  ];

  Widget harness({
    List<SpecialImage> data = images,
    void Function(String, bool)? onToggle,
    void Function(String)? onRemove,
    void Function(String, int)? onMove,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SpecialImagesSubtab(
          images: data,
          onAddImage: (_, __) {},
          onRemoveImage: onRemove ?? (_) {},
          onToggleImage: onToggle ?? (_, __) {},
          onMoveImage: onMove ?? (_, __) {},
        ),
      ),
    );
  }

  Future<void> revealList(WidgetTester tester) async {
    // Seret ListView manual sampai daftar terbangun (scrollUntilVisible
    // ambigu di halaman ini karena ada Scrollable internal TextField).
    final target = find.text('Gambar Satu');
    for (var i = 0; i < 30; i++) {
      if (target.evaluate().isNotEmpty) {
        await tester.ensureVisible(target);
        await tester.pump();
        return;
      }
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pump();
    }
    fail('Daftar gambar tidak ditemukan setelah scroll');
  }

  testWidgets('daftar gambar tampil dengan caption & nomor urut',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await revealList(tester);

    expect(find.text('Gambar 1'), findsOneWidget);
    expect(find.text('Gambar 2'), findsOneWidget);
    expect(find.text('Gambar Satu'), findsOneWidget);
    expect(find.text('Gambar Dua'), findsOneWidget);
  });

  testWidgets('daftar kosong menampilkan teks kosong', (tester) async {
    await tester.pumpWidget(harness(data: const []));
    await tester.pump();

    expect(find.text('Belum ada gambar khusus.'), findsOneWidget);
  });

  testWidgets('sakelar memanggil onToggleImage dengan id & nilai baru',
      (tester) async {
    String? toggledId;
    bool? toggledValue;
    await tester.pumpWidget(harness(onToggle: (id, val) {
      toggledId = id;
      toggledValue = val;
    }));
    await tester.pump();
    await revealList(tester);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    await tester.ensureVisible(switches.first);
    await tester.pump();
    await tester.tap(switches.first);
    await tester.pump();

    expect(toggledId, equals('a'));
    expect(toggledValue, isFalse); // gambar 'a' awalnya aktif
  });

  testWidgets('tombol hapus memanggil onRemoveImage', (tester) async {
    String? removedId;
    await tester.pumpWidget(harness(onRemove: (id) => removedId = id));
    await tester.pump();
    await revealList(tester);

    await tester.tap(find.text('Hapus').first);
    await tester.pump();

    expect(removedId, equals('a'));
  });

  testWidgets('tombol urutan: tepi daftar non-aktif, tengah memanggil callback',
      (tester) async {
    String? movedId;
    int? movedDelta;
    await tester.pumpWidget(harness(onMove: (id, delta) {
      movedId = id;
      movedDelta = delta;
    }));
    await tester.pump();
    await revealList(tester);

    // IconButton adalah ancestor dari Tooltip yang ia buat.
    Finder iconButtonOf(Finder tooltip) => find.ancestor(
          of: tooltip,
          matching: find.byType(IconButton),
        );
    final upButtons = find.byTooltip('Naikkan urutan');
    final downButtons = find.byTooltip('Turunkan urutan');
    expect(upButtons, findsNWidgets(2));
    expect(downButtons, findsNWidgets(2));

    // Gambar pertama tidak bisa naik, gambar terakhir tidak bisa turun.
    expect(tester.widget<IconButton>(iconButtonOf(upButtons.first)).onPressed,
        isNull);
    expect(tester.widget<IconButton>(iconButtonOf(downButtons.last)).onPressed,
        isNull);

    // Gambar pertama turun -> urutan bertukar.
    await tester.ensureVisible(iconButtonOf(downButtons.first));
    await tester.pump();
    await tester.tap(iconButtonOf(downButtons.first));
    await tester.pump();
    expect(movedId, equals('a'));
    expect(movedDelta, equals(1));
  });

  testWidgets('tombol Simpan Gambar non-aktif sebelum gambar dipilih',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Simpan Gambar'),
    );
    expect(button.onPressed, isNull);
  });
}
