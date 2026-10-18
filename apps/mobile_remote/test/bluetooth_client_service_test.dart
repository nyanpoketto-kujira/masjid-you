import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_remote/services/bluetooth_client_service.dart';

/// Fake platform: satu instance melayani kedua channel plugin.
///
/// `hasPermission`/`requestPermission` memakai [permissionGranted] yang
/// dievaluasi saat dipanggil (bukan ditangkap saat handler didaftarkan).
class _FakeBluetoothPlatform {
  final List<String> calls = <String>[];

  /// null = belum diset, pakai default setuju.
  bool? permissionGranted;

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
          return permissionGranted ?? true;
        case 'requestPermission':
          return permissionGranted ?? true;
        case 'isEnabled':
        case 'enable':
        case 'makeDiscoverable':
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

  /// Kirim event dari "plugin" ke Dart.
  void emit(Map<String, Object?> event) => sink?.success(event);

  /// Beri kesempatan future platform-channel terselesaikan.
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
    fail('kondisi tidak terpenuhi${reason == null ? '' : ' ($reason)'}; calls=$calls');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBluetoothPlatform platform;

  setUp(() {
    // Stream event di-cache oleh paket; reset supaya tiap tes membuka stream
    // plugin sendiri (meniru proses baru).
    BluetoothSync.debugResetEvents();
    platform = _FakeBluetoothPlatform()..install();
  });

  tearDown(() => platform.uninstall());


  const tv = BluetoothDeviceInfo(
    name: 'Masjid You TV',
    address: 'AA:BB:CC:DD:EE:01',
    bonded: false,
  );

  group('BluetoothClientService discovery', () {
    test('perangkat tanpa nama tetap masuk daftar sebagai "?"', () async {
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => platform.sink != null);

      platform.emit({'type': 'discovered', 'address': 'AA:BB', 'name': null});
      platform.emit({'type': 'discovered', 'address': 'CC:DD', 'name': 'TV'});
      await platform.until(() => service.currentState.devices.length == 2);

      final devices = service.currentState.devices;
      expect(devices.map((d) => d.address), ['AA:BB', 'CC:DD']);
      expect(devices.first.name, '?');
      expect(devices.last.name, 'TV');
      await service.dispose();
    });

    test('bonded mengikuti event, bukan hardcoded false', () async {
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => platform.sink != null);
      platform.emit({
        'type': 'discovered',
        'address': 'AA:BB',
        'name': 'TV',
        'bonded': true,
      });
      await platform.until(() => service.currentState.devices.isNotEmpty);
      expect(service.currentState.devices.single.bonded, isTrue);
      await service.dispose();
    });

    test('perangkat duplikat tidak ditambahkan dua kali', () async {
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => platform.sink != null);
      platform.emit({'type': 'discovered', 'address': 'AA:BB', 'name': 'TV'});
      platform.emit({'type': 'discovered', 'address': 'AA:BB', 'name': 'TV'});
      await platform.until(() => service.currentState.devices.isNotEmpty);
      expect(service.currentState.devices, hasLength(1));
      await service.dispose();
    });

    test('discoveryFinished menghentikan status discovering', () async {
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => platform.sink != null);
      expect(service.currentState.status, BluetoothClientStatus.discovering);
      platform.emit({'type': 'discoveryFinished'});
      await platform.until(
        () => service.currentState.status != BluetoothClientStatus.discovering,
      );
      await service.dispose();
    });

    test('izin ditolak -> error, startDiscovery tidak dipanggil', () async {
      platform.permissionGranted = false;
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => service.currentState.error != null);
      expect(service.currentState.error, contains('Izin'));
      expect(service.currentState.isScanning, isFalse);
      expect(platform.calls, isNot(contains('startDiscovery')));
      await service.dispose();
    });
  });

  group('BluetoothClientService koneksi', () {
    test('connected lalu error -> tidak lagi berstatus connected', () async {
      final service = BluetoothClientService(maxReconnectAttempts: 0);
      await service.connectTo(tv);
      await platform.until(() => platform.sink != null);
      expect(platform.calls, contains('connect'));

      platform.emit(
        {'type': 'connected', 'name': 'TV', 'address': tv.address},
      );
      await platform.until(() => service.isConnected);
      expect(service.currentState.status, BluetoothClientStatus.connected);
      expect(service.currentState.peerName, 'TV');

      platform.emit({'type': 'error', 'error': 'socket tertutup'});
      await platform.until(() => !service.isConnected);
      expect(service.currentState.status, BluetoothClientStatus.error);
      expect(service.currentState.error, 'socket tertutup');
      await service.dispose();
    });

    test('error saat scan menghentikan scanning (tidak stuck)', () async {
      final service = BluetoothClientService();
      await service.startDiscovery();
      await platform.until(() => platform.sink != null);
      platform.emit({'type': 'error', 'error': 'scan gagal'});
      await platform.until(() => service.currentState.error != null);
      expect(service.currentState.isScanning, isFalse);
      expect(service.currentState.status, BluetoothClientStatus.error);
      await service.dispose();
    });

    test('disconnected -> reconnect otomatis memanggil connect lagi',
        () async {
      final service = BluetoothClientService(
        reconnectDelay: const Duration(milliseconds: 5),
      );
      await service.connectTo(tv);
      await platform.until(() => platform.sink != null);
      platform.emit(
        {'type': 'connected', 'name': 'TV', 'address': tv.address},
      );
      await platform.until(() => service.isConnected);
      platform.calls.clear();

      platform.emit({'type': 'disconnected'});
      await platform.until(
        () => service.currentState.status == BluetoothClientStatus.reconnecting,
      );
      await platform.until(
        () => platform.calls.contains('connect'),
        reason: 'reconnect harus memanggil connect',
      );
      expect(service.isConnected, isFalse);
      await service.dispose();
    });

    test('reconnect berhenti setelah maxReconnectAttempts', () async {
      final service = BluetoothClientService(
        maxReconnectAttempts: 1,
        reconnectDelay: const Duration(milliseconds: 5),
      );
      await service.connectTo(tv);
      await platform.until(() => platform.sink != null);
      platform.emit(
        {'type': 'connected', 'name': 'TV', 'address': tv.address},
      );
      await platform.until(() => service.isConnected);

      platform.emit({'type': 'disconnected'});
      await platform.until(
        () => platform.calls.where((c) => c == 'connect').length >= 2,
      );
      // Percobaan sambung ulang gagal (tidak ada event `connected`).
      platform.emit({'type': 'error', 'error': 'timeout'});
      await platform.until(() => service.currentState.error != null);
      expect(service.currentState.error, contains('Tekan sambung'));
      await service.dispose();
    });

    test('disconnect() mematikan auto-reconnect', () async {
      final service = BluetoothClientService(
        reconnectDelay: const Duration(milliseconds: 5),
      );
      await service.connectTo(tv);
      await platform.until(() => platform.sink != null);
      platform.emit(
        {'type': 'connected', 'name': 'TV', 'address': tv.address},
      );
      await platform.until(() => service.isConnected);

      await service.disconnect();
      platform.calls.clear();
      platform.emit({'type': 'disconnected'});
      await platform.settle(30);
      expect(platform.calls, isNot(contains('connect')));
      expect(service.currentState.status, BluetoothClientStatus.idle);
      await service.dispose();
    });
  });
}
