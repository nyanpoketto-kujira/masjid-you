import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('StateSnapshot (TV -> Remote)', () {
    StateSnapshot buildSample() => StateSnapshot(
          config: const MosqueConfig(
            name: 'Masjid Al-Hikmah',
            address: 'Jl. Pemuda No. 45',
            latitude: -6.1754,
            longitude: 106.8272,
            utcOffsetHours: 7,
            prayerOffsets: {PrayerType.fajr: 2, PrayerType.isha: -1},
            preAdhanMinutes: 20,
            adhanMinutes: 3,
            preIqomahMinutes: 2,
            shalatMinutes: 12,
            khutbahMinutes: 25,
            fridayKhatib: 'Ustadz Ahmad',
            fridayMuadzin: 'Ustadz Bilal',
          ),
          runningTexts: const [
            RunningTextMessage(
              id: 'rt1',
              content: 'Kajian rutin Sabtu',
              category: 'Kajian',
            ),
            RunningTextMessage(
              id: 'rt2',
              content: 'Saldo kas pekan ini',
              isActive: false,
              category: 'Kas',
            ),
          ],
          banners: const [
            MediaBanner(
              id: 'b1',
              header: 'DONASI',
              title: 'Infaq Pembangunan',
              content: 'Salurkan untuk ruang belajar',
              footer: 'Amal Jariyah',
              base64Image: 'abc123',
            ),
          ],
          kasTransactions: [
            KasTransaction(
              id: 'k1',
              type: KasType.masuk,
              amount: 2500000,
              description: 'Infaq Jumat',
              date: DateTime(2026, 8, 14, 9, 30),
            ),
            KasTransaction(
              id: 'k2',
              type: KasType.keluar,
              amount: 750000,
              description: 'Listrik masjid',
              date: DateTime(2026, 8, 15, 10),
            ),
          ],
          hasData: true,
        );

    test('round-trip lewat SyncPacket membawa seluruh data utuh', () {
      final snapshot = buildSample();
      final packet = SyncPacket(
        action: SyncAction.stateSnapshot,
        payload: snapshot.toMap(),
      );

      final parsedPacket = SyncPacket.fromJson(packet.toJson());
      expect(parsedPacket.action, equals(SyncAction.stateSnapshot));

      final parsed = StateSnapshot.fromMap(parsedPacket.payload);
      expect(parsed, equals(snapshot));
      expect(parsed.hashCode, equals(snapshot.hashCode));
      expect(parsed.hasData, isTrue);
      expect(parsed.config.name, equals('Masjid Al-Hikmah'));
      expect(parsed.config.offsetFor(PrayerType.fajr), equals(2));
      expect(parsed.config.offsetFor(PrayerType.isha), equals(-1));
      expect(parsed.config.fridayKhatib, equals('Ustadz Ahmad'));
      expect(parsed.runningTexts.length, equals(2));
      expect(parsed.runningTexts[1].isActive, isFalse);
      expect(parsed.banners.single.base64Image, equals('abc123'));
      expect(parsed.kasTransactions.length, equals(2));
      expect(parsed.kasTransactions[1].type, equals(KasType.keluar));
      expect(parsed.kasTransactions[1].date, equals(DateTime(2026, 8, 15, 10)));
    });

    test('snapshot kosong (TV belum pernah diisi) ditandai hasData=false', () {
      const empty = StateSnapshot();
      expect(empty.hasData, isFalse);

      final parsed = StateSnapshot.fromMap(empty.toMap());
      expect(parsed.hasData, isFalse);
      expect(parsed.runningTexts, isEmpty);
      expect(parsed.banners, isEmpty);
      expect(parsed.kasTransactions, isEmpty);
      expect(parsed, equals(empty));
    });

    test('payload rusak tidak melempar & jatuh ke default aman', () {
      final parsed = StateSnapshot.fromMap(const {
        'config': 'bukan-map',
        'runningTexts': 'bukan-list',
        'banners': [1, 'x', null],
        'kasTransactions': [
          {'id': 'k1', 'type': 'masuk', 'amount': 5000}
        ],
        'hasData': 'bukan-bool',
      });

      expect(parsed.config, equals(const MosqueConfig()));
      expect(parsed.runningTexts, isEmpty);
      expect(parsed.banners, isEmpty);
      expect(parsed.kasTransactions.single.amount, equals(5000));
      expect(parsed.hasData, isFalse);

      // Payload benar-benar kosong pun tetap valid.
      final blank = StateSnapshot.fromMap(const {});
      expect(blank, equals(const StateSnapshot()));
    });

    test('equality membedakan isi snapshot', () {
      final snapshot = buildSample();
      final same = StateSnapshot.fromMap(snapshot.toMap());
      expect(snapshot, equals(same));

      final withoutKas = StateSnapshot(
        config: snapshot.config,
        runningTexts: snapshot.runningTexts,
        banners: snapshot.banners,
        hasData: true,
      );
      expect(snapshot, isNot(equals(withoutKas)));
      expect(
        snapshot,
        isNot(equals(StateSnapshot(
          config: snapshot.config,
          runningTexts: snapshot.runningTexts,
          banners: snapshot.banners,
          kasTransactions: snapshot.kasTransactions,
        ))),
      );
    });
  });
}
