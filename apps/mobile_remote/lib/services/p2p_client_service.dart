import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

/// Status kesiapan perangkat untuk menjalankan mode WiFi Direct.
///
/// Mirror dari `P2pPrerequisites` di `tv_display` (server/p2p_host_service.dart).
class P2pPrerequisites {
  final bool wifiEnabled;
  final bool bluetoothEnabled;
  final bool locationEnabled;
  final bool p2pPermissionsGranted;
  final bool bluetoothPermissionsGranted;

  const P2pPrerequisites({
    required this.wifiEnabled,
    required this.bluetoothEnabled,
    required this.locationEnabled,
    required this.p2pPermissionsGranted,
    required this.bluetoothPermissionsGranted,
  });

  bool get allPermissionsGranted =>
      p2pPermissionsGranted && bluetoothPermissionsGranted;

  /// Location is required for Android < 12.
  bool isReady({required bool locationRequired}) =>
      wifiEnabled &&
      bluetoothEnabled &&
      allPermissionsGranted &&
      (!locationRequired || locationEnabled);
}

class P2pClientService {
  FlutterP2pClient? _client;
  final _stateController = StreamController<HotspotClientState?>.broadcast();
  bool _initialized = false;

  Stream<HotspotClientState?> get stateStream => _stateController.stream;

  int _androidSdkVersion() {
    if (!Platform.isAndroid) return 0;
    final match = RegExp(r'SDK\s+(\d+)')
        .firstMatch(Platform.operatingSystemVersion);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  Future<void> _ensureClient() async {
    if (_initialized || !Platform.isAndroid) return;
    _client = FlutterP2pClient();
    await _client!.initialize();
    _client!.streamHotspotState().listen((state) {
      _stateController.add(state);
    });
    _initialized = true;
  }

  /// Evaluasi kesiapan hardware & perizinan untuk mode WiFi Direct.
  Future<P2pPrerequisites> checkPrerequisites() async {
    await _ensureClient();
    if (_client == null) {
      // Bukan Android (mis. test/desktop) -> anggap siap agar tidak memblokir.
      return const P2pPrerequisites(
        wifiEnabled: true,
        bluetoothEnabled: true,
        locationEnabled: true,
        p2pPermissionsGranted: true,
        bluetoothPermissionsGranted: true,
      );
    }
    // `checkP2pPermissions` plugin menuntut NEARBY_WIFI_DEVICES sejak Android 12,
    // padahal izin itu baru berlaku Android 13+ dan di beberapa ROM Android 12
    // bahkan tidak terdaftar. Untuk Android < 13, P2P cukup FINE_LOCATION yang
    // sudah tercakup oleh checkBluetoothPermissions.
    final bluetoothPermissionsGranted =
        await _client!.checkBluetoothPermissions();
    final sdkVersion = _androidSdkVersion();
    final p2pPermissionsGranted = sdkVersion >= 33
        ? await _client!.checkP2pPermissions()
        : bluetoothPermissionsGranted;
    return P2pPrerequisites(
      wifiEnabled: await _client!.checkWifiEnabled(),
      bluetoothEnabled: await _client!.checkBluetoothEnabled(),
      locationEnabled: await _client!.checkLocationEnabled(),
      p2pPermissionsGranted: p2pPermissionsGranted,
      bluetoothPermissionsGranted: bluetoothPermissionsGranted,
    );
  }

  Future<void> askPermissionsIfNeeded() async {
    if (_client == null) return;
    // NEARBY_WIFI_DEVICES hanya relevan Android 13+; hindari minta izin yang
    // tidak dikenal ROM Android 12 (dapat gagal/no-op).
    if (_androidSdkVersion() >= 33 && !await _client!.checkP2pPermissions()) {
      await _client!.askP2pPermissions();
    }
    if (!await _client!.checkBluetoothPermissions()) {
      await _client!.askBluetoothPermissions();
    }
  }

  Future<void> enableWifiIfNeeded() async {
    if (_client == null) return;
    if (!await _client!.checkWifiEnabled()) {
      await _client!.enableWifiServices();
    }
  }

  Future<void> enableBluetoothIfNeeded() async {
    if (_client == null) return;
    if (!await _client!.checkBluetoothEnabled()) {
      await _client!.enableBluetoothServices();
    }
  }

  Future<void> enableLocationIfNeeded() async {
    if (_client == null) return;
    if (!await _client!.checkLocationEnabled()) {
      await _client!.enableLocationServices();
    }
  }

  Future<void> startScan(
    void Function(List<BleDiscoveredDevice>) onDevices, {
    void Function()? onDone,
  }) async {
    await _ensureClient();
    if (_client == null) return;
    try {
      await askPermissionsIfNeeded();
      // Location services are required for BLE scan on Android 6-11 (and recommended for 12+)
      await enableLocationIfNeeded();
      await enableWifiIfNeeded();
      await enableBluetoothIfNeeded();
      await _client!.startScan(onDevices, onDone: onDone);
    } catch (e) {
      debugPrint('P2P scan failed: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await _client?.stopScan();
    } catch (_) {}
  }

  Future<bool> connectTo(BleDiscoveredDevice device) async {
    await _ensureClient();
    if (_client == null) return false;
    try {
      await _client!.connectWithDevice(device);
      return true;
    } catch (e) {
      debugPrint('P2P connect failed: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _client?.disconnect();
      await stopScan();
    } catch (_) {}
  }
}
