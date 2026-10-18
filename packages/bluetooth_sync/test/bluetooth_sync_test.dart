import 'dart:async';

import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('com.masjidyou/bluetooth_sync');
  const eventChannel = EventChannel('com.masjidyou/bluetooth_sync/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Map<String, dynamic> lastCallArguments;
  late String lastCallMethod;
  late List<MethodCall> calls;

  /// Handler yang bisa diubah per-tes untuk mensimulasikan error platform.
  Future<Object?> Function(MethodCall call)? responder;

  setUp(() {
    BluetoothSync.debugResetEvents();
    lastCallArguments = {};
    lastCallMethod = '';
    calls = [];
    responder = null;

    messenger.setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      calls.add(call);
      lastCallMethod = call.method;
      lastCallArguments = call.arguments is Map
          ? Map<String, dynamic>.from(call.arguments as Map)
          : {};
      if (responder != null) return responder!(call);
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
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, sink) {},
        onCancel: (arguments) {},
      ),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  group('BluetoothDeviceInfo.fromMap', () {
    test('parses lengkap', () {
      final info = BluetoothDeviceInfo.fromMap({
        'name': 'SM-X135G',
        'address': 'AA:BB:CC:DD:EE:FF',
        'bonded': true,
      });
      expect(info.name, 'SM-X135G');
      expect(info.address, 'AA:BB:CC:DD:EE:FF');
      expect(info.bonded, isTrue);
    });

    test('default saat field kosong', () {
      final info = BluetoothDeviceInfo.fromMap({});
      expect(info.name, '?');
      expect(info.address, '');
      expect(info.bonded, isFalse);
    });

    test('nama kosong / null -> "?" (tidak dibuang)', () {
      expect(BluetoothDeviceInfo.fromMap({'name': ''}).name, '?');
      expect(BluetoothDeviceInfo.fromMap({'name': null}).name, '?');
    });
  });

  group('BluetoothSyncEvent.fromMap', () {
    test('event data membawa bytes Uint8List', () {
      final payload = Uint8List.fromList([1, 2, 3]);
      final event = BluetoothSyncEvent.fromMap({'type': 'data', 'bytes': payload});
      expect(event.type, BluetoothSyncEventType.data);
      expect(event.data, isA<Uint8List>());
      expect(event.data, [1, 2, 3]);
      expect(event.deviceAddress, isNull);
    });

    test('bytes sebagai List<int> tetap diterima sebagai Uint8List', () {
      final event = BluetoothSyncEvent.fromMap({
        'type': 'data',
        'bytes': <int>[9, 8, 7],
      });
      expect(event.data, isA<Uint8List>());
      expect(event.data, [9, 8, 7]);
    });

    test('bytes format salah -> null, bukan crash', () {
      final event = BluetoothSyncEvent.fromMap({'type': 'data', 'bytes': 'x'});
      expect(event.data, isNull);
    });

    test('event discovered membawa perangkat', () {
      final event = BluetoothSyncEvent.fromMap({
        'type': 'discovered',
        'address': 'AA:BB:CC:DD:EE:FF',
        'name': 'SM-X135G',
        'bonded': true,
      });
      expect(event.type, BluetoothSyncEventType.discovered);
      expect(event.deviceAddress, 'AA:BB:CC:DD:EE:FF');
      expect(event.deviceName, 'SM-X135G');
      expect(event.bonded, isTrue);
    });

    test('event error membawa pesan', () {
      final event = BluetoothSyncEvent.fromMap({
        'type': 'error',
        'error': 'Bluetooth mati',
      });
      expect(event.type, BluetoothSyncEventType.error);
      expect(event.error, 'Bluetooth mati');
    });

    test('type tidak dikenal -> error dengan pesan diagnosis', () {
      final event = BluetoothSyncEvent.fromMap({'type': 'haha'});
      expect(event.type, BluetoothSyncEventType.error);
      expect(event.error, contains('haha'));
    });
  });

  group('BluetoothSyncEventType parsing lengkap', () {
    for (final type in BluetoothSyncEventType.values) {
      test('parses ${type.name}', () {
        final event = BluetoothSyncEvent.fromMap({'type': type.name});
        expect(event.type, type);
      });
    }

    test('enum berisi semua event yang dipakai plugin Kotlin', () {
      final names = BluetoothSyncEventType.values.map((e) => e.name).toSet();
      expect(
        names,
        containsAll(<String>[
          'listening',
          'connected',
          'data',
          'disconnected',
          'error',
          'discovered',
          'discoveryFinished',
        ]),
      );
    });
  });

  group('BluetoothSync method channel', () {
    test('requestPermission mengirim mode host', () async {
      await BluetoothSync.requestPermission(mode: 'host');
      expect(lastCallMethod, 'requestPermission');
      expect(lastCallArguments['mode'], 'host');
    });

    test('requestPermission default mode client', () async {
      await BluetoothSync.requestPermission();
      expect(lastCallMethod, 'requestPermission');
      expect(lastCallArguments['mode'], 'client');
    });

    test('hasPermission mengirim mode host', () async {
      await BluetoothSync.hasPermission(mode: 'host');
      expect(lastCallMethod, 'hasPermission');
      expect(lastCallArguments['mode'], 'host');
    });

    test('startHost mengirim serviceName', () async {
      await BluetoothSync.startHost('Masjid You TV');
      expect(lastCallMethod, 'startHost');
      expect(lastCallArguments['serviceName'], 'Masjid You TV');
    });

    test('makeDiscoverable mengirim seconds', () async {
      await BluetoothSync.makeDiscoverable(120);
      expect(lastCallMethod, 'makeDiscoverable');
      expect(lastCallArguments['seconds'], 120);
    });

    test('makeDiscoverable meneruskan penolakan user sebagai false', () async {
      responder = (call) async => call.method == 'makeDiscoverable' ? false : true;
      expect(await BluetoothSync.makeDiscoverable(120), isFalse);
    });

    test('makeDiscoverable tanpa Activity -> PlatformException', () async {
      responder = (call) async {
        throw PlatformException(code: 'NO_ACTIVITY', message: 'butuh Activity');
      };
      expect(
        () => BluetoothSync.makeDiscoverable(120),
        throwsA(isA<PlatformException>()),
      );
    });

    test('connect mengirim address', () async {
      await BluetoothSync.connect('AA:BB:CC:DD:EE:FF');
      expect(lastCallMethod, 'connect');
      expect(lastCallArguments['address'], 'AA:BB:CC:DD:EE:FF');
    });

    test('send mengirim bytes Uint8List', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      await BluetoothSync.send(bytes);
      expect(lastCallMethod, 'send');
      expect(lastCallArguments['bytes'], bytes);
    });

    test('events memakai channel event yang sama dengan plugin', () {
      expect(BluetoothSync.events, isA<Stream<BluetoothSyncEvent>>());
      // Stream broadcast di-cache: dua pemanggil mendapat instance sama.
      expect(identical(BluetoothSync.events, BluetoothSync.events), isTrue);
    });
  });

  group('Framing 4-byte big-endian (kontrak dengan Kotlin)', () {
    /// Implementasi referensi framing yang harus sama dengan
    /// `sendLocked()` di BluetoothSyncPlugin.kt dan `readLoop()`.
    Uint8List frame(Uint8List payload) {
      final len = payload.length;
      return Uint8List.fromList([
        (len >> 24) & 0xff,
        (len >> 16) & 0xff,
        (len >> 8) & 0xff,
        len & 0xff,
        ...payload,
      ]);
    }

    test('panjang payload kecil', () {
      expect(frame(Uint8List.fromList([7])), [0, 0, 0, 1, 7]);
    });

    test('panjang payload besar (big-endian benar)', () {
      final payload = Uint8List(0x01020304);
      final head = frame(payload).sublist(0, 4);
      expect(head, [1, 2, 3, 4]);
    });

    test('byte >127 tidak jadi negatif (mask 0xff)', () {
      final payload = Uint8List(200);
      final head = frame(payload).sublist(0, 4);
      expect(head, [0, 0, 0, 200]);
    });
  });
}
