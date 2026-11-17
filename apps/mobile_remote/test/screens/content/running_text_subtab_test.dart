import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/running_text_subtab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Fase 3 (ADR-025) untuk sub-tab Running Text: FAB + dialog
/// full-screen, ReorderableListView dengan handle drag + nomor urut, dan
/// empty state seragam.
void main() {
  const texts = [
    RunningTextMessage(
        id: '1',
        content: 'Jumat Keliling Pekan Ini Bersama Ustadz H. Ahmad Ridwan',
        category: 'Kajian'),
    RunningTextMessage(
        id: '2',
        content: 'Saldo Kas Masjid Per Minggu Ini: Rp 42.500.000',
        category: 'Kas'),
  ];

  Widget harness({
    List<RunningTextMessage> data = texts,
    void Function(String)? onRemove,
    void Function(int, int)? onReorder,
  }) {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    return MaterialApp(
      home: Scaffold(
        body: RunningTextSubtab(
          runningTexts: data,
          runningTextController: controller,
          selectedCategory: 'Pengumuman',
          categories: const ['Pengumuman', 'Kajian', 'Kas'],
          onCategoryChanged: (_) {},
          onAddMessage: () {},
          onEditMessage: (_) {},
          onRemoveMessage: onRemove ?? (_) {},
          onReorder: onReorder,
        ),
      ),
    );
  }

  testWidgets('daftar tampil dengan nomor urut & handle drag', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text(texts[0].content), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
  });

  testWidgets('daftar kosong menampilkan empty state seragam',
      (tester) async {
    await tester.pumpWidget(harness(data: const []));
    await tester.pump();

    expect(find.text('Belum ada teks berjalan'), findsOneWidget);
    expect(find.text('Tambah Teks'), findsWidgets);
  });

  testWidgets('tombol hapus memanggil onRemoveMessage', (tester) async {
    String? removedId;
    await tester.pumpWidget(harness(onRemove: (id) => removedId = id));
    await tester.pump();

    await tester.tap(find.byTooltip('Hapus teks').first);
    await tester.pump();

    expect(removedId, equals('1'));
  });

  testWidgets('drag handle memanggil onReorder', (tester) async {
    int? oldIndex;
    int? newIndex;
    await tester.pumpWidget(harness(onReorder: (o, n) {
      oldIndex = o;
      newIndex = n;
    }));
    await tester.pump();

    await tester.drag(
      find.byIcon(Icons.drag_handle).first,
      const Offset(0, 200),
    );
    await tester.pump();

    expect(oldIndex, equals(0));
    expect(newIndex, isNotNull);
    expect(newIndex, greaterThan(0));
  });

  testWidgets('FAB membuka dialog tambah teks dengan tombol Simpan',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    await tester.tap(find.text('Tambah Teks'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Teks Berjalan'), findsOneWidget);
    // Isi kosong: tombol Simpan non-aktif.
    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Simpan'),
    );
    expect(saveButton.onPressed, isNull);
  });
}
