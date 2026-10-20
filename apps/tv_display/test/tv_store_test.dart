import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_display/state/tv_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TvStore (persist data resmi TV)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load() -> null selama TV belum pernah diisi', () async {
      final store = TvStore();
      expect(await store.load(), isNull);
    });

    test('simpan lalu muat kembali seluruh data (round-trip)', () async {
      final store = TvStore();
      const config = MosqueConfig(
        name: 'Masjid Al-Hikmah',
        address: 'Jl. Pemuda No. 45',
        latitude: -6.1754,
        longitude: 106.8272,
        preAdhanMinutes: 20,
        adhanMinutes: 3,
        fridayKhatib: 'Ustadz Ahmad',
        prayerOffsets: {PrayerType.fajr: 2},
      );
      const messages = [
        RunningTextMessage(id: 'rt1', content: 'Kajian Sabtu', category: 'Kajian'),
      ];
      const banners = [
        MediaBanner(id: 'b1', header: 'DONASI', title: 'Infaq', content: 'Ruang belajar'),
      ];
      final transactions = [
        KasTransaction(
          id: 'k1',
          type: KasType.masuk,
          amount: 2500000,
          description: 'Infaq Jumat',
          date: DateTime(2026, 8, 14, 9, 30),
        ),
      ];

      await store.saveConfig(config);
      await store.saveRunningTexts(messages);
      await store.saveBanners(banners);
      await store.saveKas(transactions);

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.hasData, isTrue);
      expect(loaded.config, equals(config));
      expect(loaded.runningTexts, equals(messages));
      expect(loaded.banners, equals(banners));
      expect(loaded.kasTransactions, equals(transactions));
    });

    test('data rusak di penyimpanan tidak melempar & jatuh ke default', () async {
      SharedPreferences.setMockInitialValues({
        TvStore.hasDataKey: true,
        TvStore.configKey: 'bukan-json',
        TvStore.runningTextsKey: '{"bukan": "list"}',
        TvStore.bannersKey: '[1, "x"]',
        TvStore.kasKey: '',
      });

      final loaded = await TvStore().load();
      expect(loaded, isNotNull);
      expect(loaded!.config, equals(const MosqueConfig()));
      expect(loaded.runningTexts, isEmpty);
      expect(loaded.banners, isEmpty);
      expect(loaded.kasTransactions, isEmpty);
    });

    test('menyimpan satu blok saja sudah menandai TV punya data resmi', () async {
      final store = TvStore();
      await store.saveKas(const []);

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.hasData, isTrue);
      expect(loaded.kasTransactions, isEmpty);
      // Blok yang belum pernah dikirim tetap memakai default aman.
      expect(loaded.config, equals(const MosqueConfig()));
    });
  });
}
