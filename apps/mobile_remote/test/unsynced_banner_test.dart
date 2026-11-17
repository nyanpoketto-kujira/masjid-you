import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_remote/main.dart';

/// Tes ADR-028: banner "Ada perubahan belum dikirim ke TV" tidak boleh
/// tampil di tab Pengaturan (sticky bar "Simpan & Update Ke TV" sudah
/// menangani config di sana), tetapi tetap tampil di tab lain.
///
/// Harness app penuh (koneksi WS/BT) terlalu berat untuk dirakit di tes,
/// jadi perilaku render kondisional dibuktikan lewat predikat
/// [shouldShowUnsyncedBanner] yang dipakai `build` menu utama, dirender
/// dalam pohon widget minimal yang meniru struktur kolom banner.
void main() {
  group('shouldShowUnsyncedBanner (ADR-028)', () {
    test('tanpa perubahan belum terkirim: tidak tampil di tab mana pun', () {
      for (var tab = 0; tab < 4; tab++) {
        expect(
          shouldShowUnsyncedBanner(hasUnsyncedChanges: false, tabIndex: tab),
          isFalse,
          reason: 'tab $tab',
        );
      }
    });

    test('ada perubahan: tampil di Beranda, Konten, dan Tes', () {
      for (final tab in [0, 1, 3]) {
        expect(
          shouldShowUnsyncedBanner(hasUnsyncedChanges: true, tabIndex: tab),
          isTrue,
          reason: 'tab $tab',
        );
      }
    });

    test('ada perubahan: TIDAK tampil di tab Pengaturan', () {
      expect(settingsTabIndex, 2);
      expect(
        shouldShowUnsyncedBanner(
          hasUnsyncedChanges: true,
          tabIndex: settingsTabIndex,
        ),
        isFalse,
      );
    });
  });

  group('render kondisional banner (ADR-028)', () {
    Widget harness({required bool hasUnsynced, required int tabIndex}) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              if (shouldShowUnsyncedBanner(
                hasUnsyncedChanges: hasUnsynced,
                tabIndex: tabIndex,
              ))
                const Text('Ada perubahan belum dikirim ke TV'),
              const Text('isi tab'),
            ],
          ),
        ),
      );
    }

    testWidgets('banner ter-render di tab Konten saat ada perubahan',
        (tester) async {
      await tester.pumpWidget(harness(hasUnsynced: true, tabIndex: 1));
      expect(
        find.text('Ada perubahan belum dikirim ke TV'),
        findsOneWidget,
      );
    });

    testWidgets('banner TIDAK ter-render di tab Pengaturan', (tester) async {
      await tester.pumpWidget(
        harness(hasUnsynced: true, tabIndex: settingsTabIndex),
      );
      expect(find.text('Ada perubahan belum dikirim ke TV'), findsNothing);
      expect(find.text('isi tab'), findsOneWidget);
    });

    testWidgets('banner TIDAK ter-render tanpa perubahan di tab Konten',
        (tester) async {
      await tester.pumpWidget(harness(hasUnsynced: false, tabIndex: 1));
      expect(find.text('Ada perubahan belum dikirim ke TV'), findsNothing);
    });
  });
}
