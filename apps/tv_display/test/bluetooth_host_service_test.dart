import 'dart:convert';

import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';
import 'package:tv_display/server/bluetooth_host_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('com.masjidyou/bluetooth_sync');
  const eventChannel = EventChannel('com.masjidyou/bluetooth_sync/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;
  late List<Map<String, dynamic>> sentFrames;

  /// Sink event untuk simulasi event dari native.
  late MockStreamHandlerEventSink eventSink;

  setUp(() {
    BluetoothSync.debugResetEvents();
    calls = [];
    sentFrames = [];

    messenger.setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      calls.add(call);
      if (call.method == 'send') {
        final bytes = call.arguments['bytes'] as List<int>;
        sentFrames.add(
          json.decode(utf8.decode(bytes)) as Map<String, dynamic>,
        );
      }
      switch (call.method) {
        case 'isSupported':
        case 'isEnabled':
        case 'enable':
        case 'hasPermission':
        case 'requestPermission':
        case 'makeDiscoverable':
          return true;
        default:
          return null;
      }
    });
    // Simulasi events channel: sink ditahan agar bisa di-emit dari luar.
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, sink) {
          eventSink = sink;
        },
        onCancel: (arguments) {},
      ),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  Map<String, dynamic> mapForEvent(BluetoothSyncEventType type,
      Map<String, dynamic>? data) {
    switch (type) {
      case BluetoothSyncEventType.connected:
        return {'type': 'connected', 'name': 'Remote HP'};
      case BluetoothSyncEventType.data:
        return {'type': 'data', 'bytes': data!['bytes']};
      case BluetoothSyncEventType.disconnected:
        return {'type': 'disconnected'};
      default:
        return {'type': type.name};
    }
  }

  /// Simulasi event dari native.
  void emitEvent(BluetoothSyncEventType type, {Map<String, dynamic>? data}) {
    eventSink.success(mapForEvent(type, data));
  }

  test('start() generate PIN 4 digit dan emit listening', () async {
    final received = <SyncPacket>[];
    final service = BluetoothHostService(onPacketReceived: received.add);
    await service.start();
    expect(service.isRunning, isTrue);
    expect(service.pin, isNotNull);
    expect(service.pin!.length, 4);
    expect(RegExp(r'^\d{4}$').hasMatch(service.pin!), isTrue);
    await service.stop();
  });

  test('paket data ditolak sebelum auth, diteruskan setelah authSuccess',
      () async {
    final received = <SyncPacket>[];
    final service = BluetoothHostService(onPacketReceived: received.add);
    await service.start();
    final pin = service.pin!;

    // Koneksi terbentuk -> TV kirim authChallenge.
    emitEvent(BluetoothSyncEventType.connected);
    await Future<void>.delayed(Duration.zero);
    expect(
      sentFrames.any((f) => f['action'] == 'authChallenge'),
      isTrue,
    );
    final nonce = sentFrames
        .lastWhere((f) => f['action'] == 'authChallenge')['payload']['nonce'] as String;

    // Data sebelum auth ditolak.
    emitEvent(BluetoothSyncEventType.data, data: {
      'bytes': utf8.encode(const SyncPacket(
        action: SyncAction.updateConfig,
        payload: {'name': 'X'},
      ).toJson()),
    });
    await Future<void>.delayed(Duration.zero);
    expect(received, isEmpty);

    // Jawab PIN benar.
    final authResp = SyncPacket(
      action: SyncAction.authResponse,
      payload: {'pin': pin, 'nonce': nonce},
    );
    emitEvent(BluetoothSyncEventType.data, data: {
      'bytes': utf8.encode(authResp.toJson()),
    });
    await Future<void>.delayed(Duration.zero);
    expect(
      sentFrames.any((f) => f['action'] == 'authSuccess'),
      isTrue,
    );

    // Data setelah auth diteruskan.
    emitEvent(BluetoothSyncEventType.data, data: {
      'bytes': utf8.encode(const SyncPacket(
        action: SyncAction.updateConfig,
        payload: {'name': 'Y'},
      ).toJson()),
    });
    await Future<void>.delayed(Duration.zero);
    expect(received, hasLength(1));
    expect(received.single.action, SyncAction.updateConfig);
    expect(received.single.payload['name'], 'Y');

    await service.stop();
  });

  test('PIN salah memicu authFailure dan koneksi ditutup setelah 3x',
      () async {
    final received = <SyncPacket>[];
    final service = BluetoothHostService(onPacketReceived: received.add);
    await service.start();
    final pin = service.pin!;

    emitEvent(BluetoothSyncEventType.connected);
    await Future<void>.delayed(Duration.zero);
    final nonce = sentFrames
        .lastWhere((f) => f['action'] == 'authChallenge')['payload']['nonce'] as String;

    // Salah 3x.
    for (var i = 0; i < 3; i++) {
      final wrong = SyncPacket(
        action: SyncAction.authResponse,
        payload: {'pin': pin == '1234' ? '0000' : '1234', 'nonce': nonce},
      );
      emitEvent(BluetoothSyncEventType.data, data: {
        'bytes': utf8.encode(wrong.toJson()),
      });
      await Future<void>.delayed(Duration.zero);
    }
    expect(
      sentFrames.where((f) => f['action'] == 'authFailure').length,
      3,
    );
    // Koneksi ditutup: disconnect dipanggil di native.
    expect(calls.any((c) => c.method == 'disconnect'), isTrue);

    await service.stop();
  });

  test('stateStream memancarkan authenticated=true setelah PIN benar',
      () async {
    final received = <SyncPacket>[];
    final service = BluetoothHostService(onPacketReceived: received.add);
    await service.start();
    final pin = service.pin!;
    final states = <BluetoothHostState>[];
    final sub = service.stateStream.listen(states.add);

    emitEvent(BluetoothSyncEventType.connected);
    await Future<void>.delayed(Duration.zero);
    final nonce = sentFrames
        .lastWhere((f) => f['action'] == 'authChallenge')['payload']['nonce'] as String;

    emitEvent(BluetoothSyncEventType.data, data: {
      'bytes': utf8.encode(SyncPacket(
        action: SyncAction.authResponse,
        payload: {'pin': pin, 'nonce': nonce},
      ).toJson()),
    });
    await Future<void>.delayed(Duration.zero);

    final connected = states.lastWhere((s) => s.status == BluetoothHostStatus.connected);
    expect(connected.authenticated, isTrue);
    expect(connected.isAuthenticated, isTrue);

    await sub.cancel();
    await service.stop();
  });
}
