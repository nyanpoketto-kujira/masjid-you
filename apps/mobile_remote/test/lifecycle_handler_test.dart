import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/services.dart';
import 'package:mobile_remote/services/bluetooth_client_service.dart';

/// Mock platform untuk testing lifecycle behavior.
class _FakeBTPlatform {
  final List<String> calls = <String>[];
  MockStreamHandlerEventSink? sink;

  late final MethodChannel channel = const MethodChannel('com.masjidyou/bluetooth_sync');
  late final EventChannel events =
      const EventChannel('com.masjidyou/bluetooth_sync/events');

  TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void install() {
    _messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'hasPermission':
        case 'requestPermission':
        case 'isEnabled':
        case 'enable':
        case 'makeDiscoverable':
        case 'isLocationEnabled':
          return true;
        default:
          return null;
      }
    });
    _messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        onListen: (arguments, events) => sink = events,
        onCancel: (arguments) {},
      ),
    );
  }

  void uninstall() {
    _messenger.setMockMethodCallHandler(channel, null);
    _messenger.setMockStreamHandler(events, null);
    sink = null;
  }

  void emit(Map<String, Object?> event) => sink?.success(event);

  Future<void> settle([int rounds = 12]) async {
    for (var i = 0; i < rounds; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> until(bool Function() predicate, {String? reason}) async {
    for (var i = 0; i < 200; i++) {
      if (predicate()) return;
      await settle(1);
    }
    fail('kondisi tidak terpenuhi${reason == null ? '' : ' ($reason)'};');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBTPlatform platform;

  setUp(() {
    BluetoothSync.debugResetEvents();
    platform = _FakeBTPlatform()..install();
  });

  tearDown(() => platform.uninstall());

  const tv = BluetoothDeviceInfo(
    name: 'Masjid You TV',
    address: 'AA:BB:CC:DD:EE:01',
    bonded: false,
  );

  group('Lifecycle handler — tidak disconnect di paused/hidden', () {
    test(
      'AppLifecycleState.paused TIDAK memanggil disconnect',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);
        expect(platform.calls, contains('connect'));

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);
        expect(service.isConnected, isTrue);

        platform.calls.clear();

        // Simulasi image_picker atau dialog sistem yang membuat app jadi paused.
        // TEST: disconnect TIDAK boleh dipanggil saat paused.
        await service.handleAppLifecycleState(AppLifecycleState.paused);
        await platform.settle(10);

        // Verifikasi: tidak ada panggilan disconnect.
        expect(
          platform.calls,
          isNot(contains('disconnect')),
          reason: 'paused TIDAK boleh disconnect BT',
        );
        // Koneksi tetap hidup.
        expect(service.isConnected, isTrue);

        await service.dispose();
      },
    );

    test(
      'AppLifecycleState.hidden TIDAK memanggil disconnect',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);
        expect(service.isConnected, isTrue);

        platform.calls.clear();

        // Simulasi hidden state (modal/overlay dialog).
        await service.handleAppLifecycleState(AppLifecycleState.hidden);
        await platform.settle(10);

        expect(
          platform.calls,
          isNot(contains('disconnect')),
          reason: 'hidden TIDAK boleh disconnect BT',
        );
        expect(service.isConnected, isTrue);

        await service.dispose();
      },
    );

    test(
      'AppLifecycleState.detached MEMANGGIL disconnect',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);

        platform.calls.clear();

        // App ditutup — BOLEH disconnect.
        await service.handleAppLifecycleState(AppLifecycleState.detached);
        await platform.settle(10);

        // Verifikasi: disconnect HARUS dipanggil.
        expect(
          platform.calls,
          contains('disconnect'),
          reason: 'detached HARUS disconnect BT',
        );

        await service.dispose();
      },
    );

    test(
      'paused → resumed: koneksi tetap aktif (no forced reconnect)',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);

        platform.calls.clear();

        // Paused (image_picker terbuka).
        await service.handleAppLifecycleState(AppLifecycleState.paused);
        await platform.settle(5);
        expect(service.isConnected, isTrue);

        // Resumed (kembali dari image_picker).
        await service.handleAppLifecycleState(AppLifecycleState.resumed);
        await platform.settle(5);

        // Koneksi tetap hidup, tidak perlu reconnect.
        expect(service.isConnected, isTrue);
        expect(
          platform.calls,
          isNot(contains('disconnect')),
          reason: 'paused→resumed sequence TIDAK boleh disconnect',
        );

        await service.dispose();
      },
    );

    test(
      'multiple paused/hidden cycles: koneksi tetap stabil',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);

        for (int i = 0; i < 3; i++) {
          platform.calls.clear();

          // Simulasi multiple paused/hidden: dialog → dismiss → lain dialog
          await service.handleAppLifecycleState(AppLifecycleState.paused);
          await platform.settle(3);
          await service.handleAppLifecycleState(AppLifecycleState.resumed);
          await platform.settle(3);
          await service.handleAppLifecycleState(AppLifecycleState.hidden);
          await platform.settle(3);
          await service.handleAppLifecycleState(AppLifecycleState.resumed);
          await platform.settle(3);

          expect(
            platform.calls,
            isNot(contains('disconnect')),
            reason: 'siklus $i: TIDAK boleh disconnect',
          );
          expect(
            service.isConnected,
            isTrue,
            reason: 'siklus $i: koneksi harus tetap aktif',
          );
        }

        await service.dispose();
      },
    );
  });

  group('Lifecycle handler — edge case', () {
    test(
      'detached SAAT disconnect sudah dalam proses: tidak error',
      () async {
        final service = BluetoothClientService(maxReconnectAttempts: 0);
        await service.connectTo(tv);
        await platform.until(() => platform.sink != null);

        platform.emit({'type': 'connected', 'name': 'TV', 'address': tv.address});
        await platform.until(() => service.isConnected);

        // Detached & emit disconnect dalam urutan cepat.
        await service.handleAppLifecycleState(AppLifecycleState.detached);
        await platform.settle(1);
        platform.emit({'type': 'disconnected'});
        await platform.settle(5);

        // Tidak boleh crash atau error.
        expect(service.isConnected, isFalse);

        await service.dispose();
      },
    );
  });
}


