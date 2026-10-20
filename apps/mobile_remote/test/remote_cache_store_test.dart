import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_remote/main.dart';
import 'package:mobile_remote/services/remote_cache_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  StateSnapshot buildSnapshot() => StateSnapshot(
        config: const MosqueConfig(
          name: 'Masjid Al-Hikmah',
          address: 'Jl. Pemuda No. 45',
          latitude: -6.1754,
          longitude: 106.8272,
          preAdhanMinutes: 20,
          adhanMinutes: 3,
          khutbahMinutes: 25,
          fridayKhatib: 'Ustadz Ahmad',
        ),
        runningTexts: const [
          RunningTextMessage(id: 'rt1', content: 'Kajian Sabtu', category: 'Kajian'),
        ],
        banners: const [
          MediaBanner(id: 'b1', header: 'DONASI', title: 'Infaq', content: 'Ruang belajar'),
        ],
        kasTransactions: [
          KasTransaction(
            id: 'k1',
            type: KasType.masuk,
            amount: 2500000,
            description: 'Infaq Jumat',
            date: DateTime(2026, 8, 14, 9, 30),
          ),
        ],
        hasData: true,
      );

  group('RemoteCacheStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load() -> null bila cache belum pernah ada', () async {
      expect(await RemoteCacheStore().load(), isNull);
    });

    test('snapshot data resmi tersimpan & termuat kembali (round-trip)', () async {
      final store = RemoteCacheStore();
      final snapshot = buildSnapshot();
      await store.save(snapshot);

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded, equals(snapshot));
    });

    test('snapshot kosong (TV belum diisi) tidak dijadikan cache', () async {
      final store = RemoteCacheStore();
      await store.save(const StateSnapshot());

      expect(await store.load(), isNull);
    });

    test('cache rusak tidak melempar & dianggap tidak ada', () async {
      SharedPreferences.setMockInitialValues({
        RemoteCacheStore.snapshotKey: 'bukan-json',
      });

      expect(await RemoteCacheStore().load(), isNull);
    });
  });

  group('Remote startup memakai cache TV', () {
    testWidgets('form terisi nilai cache TV, bukan nilai hardcoded',
        (WidgetTester tester) async {
      final snapshot = buildSnapshot();
      SharedPreferences.setMockInitialValues({
        RemoteCacheStore.snapshotKey: json.encode(snapshot.toMap()),
      });

      await tester.pumpWidget(const MasjidYouRemoteApp());
      await tester.pump();

      // Nama masjid dari cache TV menggantikan nilai bawaan Remote.
      expect(find.text('Masjid Al-Hikmah'), findsOneWidget);
      expect(find.text('Masjid Agung Al-Hikmah'), findsNothing);

      // Durasi & petugas Jumat dari cache TV ikut terpasang di form.
      await tester.dragUntilVisible(
        find.text('Ustadz Ahmad'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ustadz Ahmad'), findsOneWidget);
    });

    testWidgets('tanpa cache, form memakai nilai bawaan Remote',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const MasjidYouRemoteApp());
      await tester.pump();

      expect(find.text('Masjid Agung Al-Hikmah'), findsOneWidget);
    });
  });
}
