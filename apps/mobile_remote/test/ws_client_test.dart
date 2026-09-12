import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_remote/services/ws_client.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  group('RemoteWsClient.isValidIp', () {
    test('accepts valid IPv4 addresses', () {
      expect(RemoteWsClient.isValidIp('192.168.1.10'), isTrue);
      expect(RemoteWsClient.isValidIp('10.0.0.1'), isTrue);
      expect(RemoteWsClient.isValidIp('255.255.255.255'), isTrue);
      expect(RemoteWsClient.isValidIp('0.0.0.0'), isTrue);
    });

    test('rejects non-IPv4 input', () {
      expect(RemoteWsClient.isValidIp(''), isFalse);
      expect(RemoteWsClient.isValidIp('not-an-ip'), isFalse);
      expect(RemoteWsClient.isValidIp('999.1.1.1'), isFalse);
      expect(RemoteWsClient.isValidIp('192.168.1.1.1'), isFalse);
      expect(RemoteWsClient.isValidIp('192.168.1'), isFalse);
    });

    test('boundary cases: 256, leading zeros, whitespace & 4 octets', () {
      expect(RemoteWsClient.isValidIp('256.1.1.1'), isFalse);
      expect(RemoteWsClient.isValidIp('01.1.1.1'), isFalse);
      expect(RemoteWsClient.isValidIp(' 192.168.1.1'), isFalse);
      expect(RemoteWsClient.isValidIp('192.168.1.1 '), isFalse);
      expect(RemoteWsClient.isValidIp('172.16.254.1'), isTrue);
    });
  });

  group('RemoteWsClient.connect guards', () {
    test('returns false for invalid or empty IP without attempting network',
        () async {
      final client = RemoteWsClient();

      expect(await client.connect(''), isFalse);
      expect(await client.connect('acak-ip-sembarang'), isFalse);
      expect(await client.connect('999.1.1.1'), isFalse);
      expect(client.isConnected, isFalse);
    });

    test('returns false for out-of-range port', () async {
      final client = RemoteWsClient();
      expect(await client.connect('192.168.1.10', port: 0), isFalse);
      expect(await client.connect('192.168.1.10', port: 70000), isFalse);
      expect(client.isConnected, isFalse);
    });
  });

  group('RemoteWsClient disconnected safety', () {
    test('sendPacket tanpa koneksi adalah no-op (tidak melempar)', () {
      final client = RemoteWsClient();
      client.sendPacket(
        const SyncPacket(action: SyncAction.skipAdhan, payload: {}),
      );
      expect(client.isConnected, isFalse);
    });

    test('semua helper kirim akses aman walau belum terhubung', () {
      final client = RemoteWsClient();
      final tx = KasTransaction(
        id: 't1',
        type: KasType.masuk,
        amount: 1000,
        description: 'Infaq',
        date: DateTime(2026, 1, 1),
      );

      expect(() => client.sendConfigUpdate(const MosqueConfig()),
          returnsNormally);
      expect(
        () => client.sendRunningTextsUpdate(const [
          RunningTextMessage(id: 'a', content: 'b'),
        ]),
        returnsNormally,
      );
      expect(
        () => client.sendBannersUpdate(const [
          MediaBanner(id: 'b1', header: 'H', title: 'T', content: 'C'),
        ]),
        returnsNormally,
      );
      expect(() => client.sendKasUpdate([tx]), returnsNormally);
      expect(() => client.sendSkipAdhan(), returnsNormally);
      expect(() => client.sendStartShalat(), returnsNormally);
      expect(() => client.sendStartIqomah(), returnsNormally);
      expect(() => client.sendFinishShalat(), returnsNormally);
      expect(() => client.sendForcePhase(PrayerPhase.adhan), returnsNormally);
      expect(client.isConnected, isFalse);
    });

    test('disconnect idempotent dan mengosongkan status koneksi', () {
      final client = RemoteWsClient();
      expect(client.disconnect, returnsNormally);
      expect(client.isConnected, isFalse);
      client.disconnect();
      expect(client.isConnected, isFalse);
      expect(() => client.sendSkipAdhan(), returnsNormally);
    });
  });
}
