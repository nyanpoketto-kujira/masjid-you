import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/screens/content/kas_subtab.dart';
import 'package:shared_models/shared_models.dart';

/// Tes Fase 3 (ADR-025) untuk sub-tab Kas: kartu ringkasan di atas, baris
/// menampilkan kata Masuk/Keluar, hapus lewat tombol, FAB + dialog
/// full-screen, dan empty state seragam.
void main() {
  final transactions = [
    KasTransaction(
      id: '1',
      type: KasType.masuk,
      amount: 5000000,
      description: 'Kotak Amal Jumat Utama',
      date: DateTime(2026, 11, 13, 10, 0),
    ),
    KasTransaction(
      id: '2',
      type: KasType.keluar,
      amount: 750000,
      description: 'Kebersihan & Listrik Masjid',
      date: DateTime(2026, 11, 15, 9, 30),
    ),
  ];

  Widget harness({
    List<KasTransaction>? data,
    void Function(String)? onRemove,
  }) {
    final txs = data ?? transactions;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    addTearDown(() {
      amountController.dispose();
      descriptionController.dispose();
    });
    return MaterialApp(
      home: Scaffold(
        body: KasSubtab(
          transactions: txs,
          amountController: amountController,
          descriptionController: descriptionController,
          kasType: KasType.masuk,
          onTypeChanged: (_) {},
          onAddTransaction: () {},
          onRemoveTransaction: onRemove ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('kartu ringkasan tetap di atas daftar', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('SALDO KAS'), findsOneWidget);
    expect(find.text('PEMASUKAN'), findsOneWidget);
    expect(find.text('PENGELUARAN'), findsOneWidget);
    // Saldo = 5.000.000 - 750.000 = 4.250.000.
    expect(find.textContaining('4.250.000'), findsWidgets);
  });

  testWidgets('baris transaksi menampilkan kata Masuk/Keluar selain warna',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.textContaining('Masuk •'), findsOneWidget);
    expect(find.textContaining('Keluar •'), findsOneWidget);
    expect(find.text('Kotak Amal Jumat Utama'), findsOneWidget);
    expect(find.text('Kebersihan & Listrik Masjid'), findsOneWidget);
  });

  testWidgets('tombol hapus memanggil onRemoveTransaction', (tester) async {
    String? removedId;
    await tester.pumpWidget(harness(onRemove: (id) => removedId = id));
    await tester.pump();

    await tester.tap(find.byTooltip('Hapus transaksi').first);
    await tester.pump();

    expect(removedId, equals('1'));
  });

  testWidgets('empty state tampil bila transaksi kosong', (tester) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    addTearDown(() {
      amountController.dispose();
      descriptionController.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KasSubtab(
            transactions: const [],
            amountController: amountController,
            descriptionController: descriptionController,
            kasType: KasType.masuk,
            onTypeChanged: (_) {},
            onAddTransaction: () {},
            onRemoveTransaction: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Belum ada transaksi kas'), findsOneWidget);
    expect(find.text('Tambah Transaksi'), findsWidgets);
  });

  testWidgets('FAB membuka dialog tambah transaksi', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    await tester.tap(find.text('Tambah Transaksi'));
    await tester.pumpAndSettle();

    // Judul dialog + field nominal/keterangan ada di dialog.
    expect(find.text('Tambah Transaksi'), findsWidgets);
    expect(find.text('Nominal (Rp)'), findsOneWidget);
    expect(find.text('Keterangan / Sumber / Peruntukan'), findsOneWidget);
    // Nominal kosong: tombol Simpan non-aktif.
    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Simpan'),
    );
    expect(saveButton.onPressed, isNull);
  });
}
