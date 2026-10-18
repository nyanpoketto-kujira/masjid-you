import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Info satu perangkat Bluetooth yang ditemukan saat discovery.
class BluetoothDeviceInfo {
  final String name;
  final String address;
  final bool bonded;

  const BluetoothDeviceInfo({
    required this.name,
    required this.address,
    required this.bonded,
  });

  factory BluetoothDeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    final rawName = map['name'] as String?;
    return BluetoothDeviceInfo(
      name: (rawName == null || rawName.isEmpty) ? '?' : rawName,
      address: (map['address'] as String?) ?? '',
      bonded: (map['bonded'] as bool?) ?? false,
    );
  }

  @override
  String toString() => 'BluetoothDeviceInfo($name, $address, bonded=$bonded)';
}

enum BluetoothSyncEventType {
  /// Server/listener siap menerima koneksi (hanya sisi host).
  listening,

  /// Ada koneksi masuk/keluar berhasil terbentuk.
  connected,

  /// Pesan bingkai (frame) diterima.
  data,

  /// Koneksi terputus.
  disconnected,

  /// Ada error (lihat [BluetoothSyncEvent.error]).
  error,

  /// Perangkat baru ditemukan saat discovery (sisi client).
  discovered,

  /// Discovery selesai / timeout.
  discoveryFinished,
}

class BluetoothSyncEvent {
  final BluetoothSyncEventType type;
  final String? deviceAddress;
  final String? deviceName;
  final Uint8List? data;
  final String? error;

  /// Perangkat hasil discovery sudah ter-pair/ter-bond dengan HP ini.
  final bool bonded;

  const BluetoothSyncEvent({
    required this.type,
    this.deviceAddress,
    this.deviceName,
    this.data,
    this.error,
    this.bonded = false,
  });

  factory BluetoothSyncEvent.fromMap(Map<dynamic, dynamic> map) {
    final raw = (map['type'] as String?) ?? '';
    final type = BluetoothSyncEventType.values
        .where((e) => e.name == raw)
        .firstOrNull;
    return BluetoothSyncEvent(
      type: type ?? BluetoothSyncEventType.error,
      deviceAddress: map['address'] as String?,
      deviceName: map['name'] as String?,
      data: _asBytes(map['bytes']),
      error: map['error'] as String? ??
          (type == null ? 'Event Bluetooth tidak dikenal: $raw' : null),
      bonded: (map['bonded'] as bool?) ?? false,
    );
  }

  /// Plugin mengirim `ByteArray`; lewat platform channel bisa tiba sebagai
  /// `Uint8List` (StandarMethodCodec) atau `List<int>` (codec lain).
  static Uint8List? _asBytes(Object? raw) {
    if (raw is Uint8List) return raw;
    if (raw is List) {
      return raw is List<int> ? Uint8List.fromList(raw) : null;
    }
    return null;
  }
}

/// Transport Bluetooth Classic (RFCOMM) untuk Masjid You.
///
/// Satu instance melayani dua peran:
/// - [startHost]/[stopHost] untuk sisi TV (menerima koneksi Remote).
/// - [startDiscovery]/[connect]/[disconnect] untuk sisi Remote.
///
/// Semua pesan memakai framing: 4 byte big-endian panjang + payload.
class BluetoothSync {
  BluetoothSync._();

  static const MethodChannel _channel =
      MethodChannel('com.masjidyou/bluetooth_sync');
  static const EventChannel _eventsChannel =
      EventChannel('com.masjidyou/bluetooth_sync/events');

  static StreamController<BluetoothSyncEvent>? _cachedController;
  static Stream<BluetoothSyncEvent>? _cachedStream;
  static StreamSubscription<dynamic>? _nativeSubscription;

  /// Aliran event global (satu broadcast stream untuk seluruh app).
  ///
  /// `receiveBroadcastStream()` hanya mengirim `listen` ke plugin saat
  /// listener pertama aktif dan `cancel` saat listener terakhir pergi.
  /// Karena itu subscription native ditahan seumur app, supaya modul yang
  /// berhenti mendengarkan sesaat (mis. service di-dispose) tidak mematikan
  /// event untuk modul lain.
  ///
  /// Stream-nya di-cache sebagai objek (bukan hanya controller-nya) supaya
  /// [identical] pada dua pemanggilan `events` tetap benar — beberapa kode
  /// memperlakukan getter ini sebagai channel tunggal yang stabil.
  static Stream<BluetoothSyncEvent> get events =>
      _cachedStream ??= _createEventsController().stream;

  static StreamController<BluetoothSyncEvent> _createEventsController() {
    final controller = StreamController<BluetoothSyncEvent>.broadcast(
      onListen: _ensureNativeSubscription,
    );
    _cachedController = controller;
    return controller;
  }

  static void _ensureNativeSubscription() {
    if (_nativeSubscription != null) return;
    _nativeSubscription = _eventsChannel.receiveBroadcastStream().listen(
      (event) {
        final controller = _cachedController;
        if (controller == null || controller.isClosed) return;
        controller.add(BluetoothSyncEvent.fromMap(event as Map));
      },
      onError: (Object error) {
        final controller = _cachedController;
        if (controller == null || controller.isClosed) return;
        controller.addError(error);
      },
    );
  }

  @visibleForTesting
  static void debugResetEvents() {
    _nativeSubscription?.cancel();
    _nativeSubscription = null;
    _cachedController?.close();
    _cachedController = null;
    _cachedStream = null;
  }

  // ---- Status & izin -------------------------------------------------

  static Future<bool> isSupported() async =>
      await _channel.invokeMethod<bool>('isSupported') ?? false;

  static Future<bool> isEnabled() async =>
      await _channel.invokeMethod<bool>('isEnabled') ?? false;

  /// Pastikan Bluetooth menyala. Mengembalikan `false` jika tetap mati
  /// (mis. Android 12+ yang butuh izin pengguna — app menampilkan pesan).
  static Future<bool> enable() async =>
      await _channel.invokeMethod<bool>('enable') ?? false;

  static Future<bool> hasPermission({String mode = 'client'}) async =>
      await _channel.invokeMethod<bool>('hasPermission', {'mode': mode}) ??
          false;

  static Future<bool> requestPermission({String mode = 'client'}) async =>
      await _channel.invokeMethod<bool>('requestPermission', {'mode': mode}) ??
      false;

  /// Memunculkan dialog sistem "buat perangkat terlihat" untuk [seconds].
  ///
  /// `true` hanya bila user menyetujui; `false` bila menolak. Melempar
  /// [PlatformException] bila dialog tidak bisa ditampilkan.
  static Future<bool> makeDiscoverable(int seconds) async =>
      await _channel.invokeMethod<bool>('makeDiscoverable', {
        'seconds': seconds,
      }) ??
      false;

  // ---- Sisi HOST (TV) -------------------------------------------------

  /// Mulai mendengarkan koneksi RFCOMM dengan nama layanan [serviceName].
  static Future<void> startHost(String serviceName) =>
      _channel.invokeMethod('startHost', {'serviceName': serviceName});

  static Future<void> stopHost() => _channel.invokeMethod('stopHost');

  // ---- Sisi CLIENT (Remote) ------------------------------------------

  /// Mulai discovery Bluetooth Classic. Hasil perangkat lewat event
  /// `discovered`, dan diakhiri event `discoveryFinished`.
  static Future<void> startDiscovery({int timeoutMs = 15000}) =>
      _channel.invokeMethod('startDiscovery', {'timeoutMs': timeoutMs});

  static Future<void> stopDiscovery() =>
      _channel.invokeMethod('stopDiscovery');

  /// Hubungkan ke perangkat [address] via insecure RFCOMM (tanpa pairing).
  static Future<void> connect(String address) =>
      _channel.invokeMethod('connect', {'address': address});

  static Future<void> disconnect() => _channel.invokeMethod('disconnect');

  // ---- Kirim data (host & client) ------------------------------------

  /// Kirim satu bingkai (frame) dengan framing panjang 4 byte.
  static Future<void> send(Uint8List bytes) =>
      _channel.invokeMethod('send', {'bytes': bytes});
}
