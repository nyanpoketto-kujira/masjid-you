import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/server/local_ws_server.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  test('LocalServer broadcast SyncPacket ke klien & menerima paket dari klien',
      () async {
    final received = <SyncPacket>[];
    final server = LocalServer(onPacketReceived: received.add);
    final port = await server.start(port: 0);
    addTearDown(server.stop);

    expect(port, isNotNull);
    expect(port, greaterThan(0));

    final channel =
        WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:$port'));
    await channel.ready.timeout(const Duration(seconds: 5));
    addTearDown(channel.sink.close);

    // Beri waktu handler shelf mendaftarkan klien sebelum broadcast.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final packet = SyncPacket(
      action: SyncAction.stateUpdate,
      payload: {'phase': PrayerPhase.adhan.name},
    );
    server.broadcast(packet);

    final got =
        await channel.stream.first.timeout(const Duration(seconds: 5));
    final decoded = SyncPacket.fromJson(got.toString());
    expect(decoded.action, equals(SyncAction.stateUpdate));
    expect(decoded.payload['phase'], equals('adhan'));

    // Arah sebaliknya: frame dari klien sampai ke callback onPacketReceived.
    channel.sink.add(
      const SyncPacket(action: SyncAction.triggerBeep, payload: {}).toJson(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(received.map((p) => p.action), contains(SyncAction.triggerBeep));
  });

  test('LocalServer di port 0 menghasilkan port bebas yang berbeda', () async {
    final a = LocalServer(onPacketReceived: (_) {});
    final b = LocalServer(onPacketReceived: (_) {});
    addTearDown(a.stop);
    addTearDown(b.stop);

    final portA = await a.start(port: 0);
    final portB = await b.start(port: 0);

    expect(portA, isNotNull);
    expect(portB, isNotNull);
    expect(portB, isNot(equals(portA)));
  });
}
