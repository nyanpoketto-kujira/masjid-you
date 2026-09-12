import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

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

class P2pHostService {
  FlutterP2pHost? _host;
  final _stateController = StreamController<HotspotHostState?>.broadcast();
  StreamSubscription<HotspotHostState?>? _subscription;
  bool _started = false;

  HotspotHostState? _currentState;
  HotspotHostState? get currentState => _currentState;

  Stream<HotspotHostState?> get stateStream => _stateController.stream;

  bool get isRunning => _started;

  int _androidSdkVersion() {
    if (!Platform.isAndroid) return 0;
    final match = RegExp(r'SDK\s+(\d+)')
        .firstMatch(Platform.operatingSystemVersion);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  Future<P2pPrerequisites> checkPrerequisites() async {
    if (_host == null) {
      _host = FlutterP2pHost();
      await _host!.initialize();
    }
    // `checkP2pPermissions` plugin menuntut NEARBY_WIFI_DEVICES sejak Android 12,
    // padahal izin itu baru berlaku Android 13+ dan di beberapa ROM Android 12
    // bahkan tidak terdaftar. Untuk Android < 13, P2P cukup FINE_LOCATION yang
    // sudah tercakup oleh checkBluetoothPermissions.
    final bluetoothPermissionsGranted =
        await _host!.checkBluetoothPermissions();
    final sdkVersion = _androidSdkVersion();
    final p2pPermissionsGranted = sdkVersion >= 33
        ? await _host!.checkP2pPermissions()
        : bluetoothPermissionsGranted;
    return P2pPrerequisites(
      wifiEnabled: await _host!.checkWifiEnabled(),
      bluetoothEnabled: await _host!.checkBluetoothEnabled(),
      locationEnabled: await _host!.checkLocationEnabled(),
      p2pPermissionsGranted: p2pPermissionsGranted,
      bluetoothPermissionsGranted: bluetoothPermissionsGranted,
    );
  }

  Future<void> enableWifiIfNeeded() async {
    if (_host == null) return;
    if (!await _host!.checkWifiEnabled()) {
      await _host!.enableWifiServices();
    }
  }

  Future<void> enableBluetoothIfNeeded() async {
    if (_host == null) return;
    if (!await _host!.checkBluetoothEnabled()) {
      await _host!.enableBluetoothServices();
    }
  }

  Future<void> enableLocationIfNeeded() async {
    if (_host == null) return;
    if (!await _host!.checkLocationEnabled()) {
      await _host!.enableLocationServices();
    }
  }

  Future<void> askPermissionsIfNeeded() async {
    if (_host == null) return;
    // NEARBY_WIFI_DEVICES hanya relevan Android 13+; hindari minta izin yang
    // tidak dikenal ROM Android 12 (dapat gagal/no-op).
    if (_androidSdkVersion() >= 33 && !await _host!.checkP2pPermissions()) {
      await _host!.askP2pPermissions();
    }
    if (!await _host!.checkBluetoothPermissions()) {
      await _host!.askBluetoothPermissions();
    }
  }

  Future<void> start() async {
    if (_started || !Platform.isAndroid) return;
    _started = true;
    try {
      if (_host == null) {
        _host = FlutterP2pHost();
        await _host!.initialize();
      }

      _subscription = _host!.streamHotspotState().listen((state) {
        _currentState = state;
        if (!_stateController.isClosed) {
          _stateController.add(state);
        }
      });

      if (!await _host!.checkP2pPermissions()) {
        await _host!.askP2pPermissions();
      }
      if (!await _host!.checkBluetoothPermissions()) {
        await _host!.askBluetoothPermissions();
      }

      await _host!.createGroup(advertise: true);
      debugPrint('P2P Host: Group created successfully');
    } catch (e) {
      _started = false;
      debugPrint('P2P host start failed: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    _started = false;
    try {
      await _subscription?.cancel();
      _subscription = null;
      await _host?.removeGroup();
      await _host?.dispose();
    } catch (_) {}
    _host = null;
    _currentState = null;
  }
}
