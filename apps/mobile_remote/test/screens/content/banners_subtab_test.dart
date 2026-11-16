import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/banners_subtab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Fase 3 (ADR-025) untuk sub-tab Info Masjid/Banner: FAB + dialog
/// full-screen, ReorderableListView dengan handle drag + nomor urut, dan
/// empty state seragam.
void main() {
  const banners = [
    MediaBanner(
      id: '1',
      header: 'INFO MASJID',
      title: 'Kajian Rutin Subuh',
      content: 'Setiap Hari Sabtu & Ahad bersama Dewan Asatidz',
      footer: 'Gratis & terbuka untuk umum',
    ),
    MediaBanner(
      id: '2',
      header: 'DONASI',
      title: 'Mari Tunaikan Infaq & Shadaqah',
      content: 'Salurkan kepedulian Anda untuk Pembangunan Ruang Belajar',
      footer: 'Amal Jariyah',
      isActive: false,
    ),
  ];

  Widget harness({
    List<MediaBanner> data = banners,
    void Function(String)? onRemove,
    void Function(int, int)? onReorder,
    void Function(String, bool)? onToggle,
  }) {
    TextEditingController text() => TextEditingController();
    return MaterialApp(
      home: Scaffold(
        body: BannersSubtab(
          banners: data,
          headerController: text(),
          titleController: text(),
          contentController: text(),
          footerController: text(),
          onAddBanner: (_) {},
          onEditBanner: (_) {},
          onRemoveBanner: onRemove ?? (_) {},
          onToggleBanner: onToggle ?? (_, __) {},
          onReorder: onReorder,
        ),
      ),
    );
  }

  testWidgets('daftar tampil dengan nomor urut banner & handle drag',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('Banner 1 · INFO MASJID'), findsOneWidget);
    expect(find.text('Banner 2 · DONASI'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
  });

  testWidgets('daftar kosong menampilkan empty state seragam',
      (tester) async {
    await tester.pumpWidget(harness(data: const []));
    await tester.pump();

    expect(find.text('Belum ada banner informasi'), findsOneWidget);
    expect(find.text('Tambah Banner'), findsWidgets);
  });

  testWidgets('tombol hapus memanggil onRemoveBanner', (tester) async {
    String? removedId;
    await tester.pumpWidget(harness(onRemove: (id) => removedId = id));
    await tester.pump();

    await tester.tap(find.text('Hapus').first);
    await tester.pump();

    expect(removedId, equals('1'));
  });

  testWidgets('sakelar memanggil onToggleBanner', (tester) async {
    String? toggledId;
    bool? toggledValue;
    await tester.pumpWidget(harness(onToggle: (id, val) {
      toggledId = id;
      toggledValue = val;
    }));
    await tester.pump();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(toggledId, equals('1'));
    expect(toggledValue, isFalse);
  });

  testWidgets('drag handle memanggil onReorder', (tester) async {
    // Viewport diperbesar agar kedua kartu banner muat tanpa scroll
    // (auto-scroll saat drag mengganggu deteksi reorder).
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int? oldIndex;
    int? newIndex;
    await tester.pumpWidget(harness(onReorder: (o, n) {
      oldIndex = o;
      newIndex = n;
    }));
    await tester.pump();

    // Seret handle item pertama melewati item kedua. Gerakan harus
    // dilakukan bertahap dengan pump di antaranya: ReorderableListView
    // menghitung target urutan dari update drag per frame, jadi satu
    // lompatan besar (tester.drag/timedDrag) tidak memicu reorder.
    final handleCenter =
        tester.getCenter(find.byIcon(Icons.drag_handle).first);
    final gesture = await tester.startGesture(handleCenter);
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(oldIndex, equals(0));
    expect(newIndex, isNotNull);
    expect(newIndex, greaterThan(0));
  });

  testWidgets('FAB membuka dialog tambah banner dengan tombol Simpan',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    await tester.tap(find.text('Tambah Banner'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Banner'), findsWidgets);
    expect(find.text('Judul Utama'), findsOneWidget);
    // Semua field kosong & tanpa gambar: tombol Simpan non-aktif.
    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Simpan'),
    );
    expect(saveButton.onPressed, isNull);
  });
}
