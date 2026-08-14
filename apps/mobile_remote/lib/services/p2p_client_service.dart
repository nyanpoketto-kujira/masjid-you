import 'dart:async';
import 'dart:io';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2pClientService {
  FlutterP2pClient? _client;
  final _stateController = StreamController<HotspotClientState?>.broadcast();
  bool _initialized = false;

  Stream<HotspotClientState?> get stateStream => _stateController.stream;

  Future<void> _ensureClient() async {
    if (_initialized || !Platform.isAndroid) return;
    _client = FlutterP2pClient();
    await _client!.initialize();
    _client!.streamHotspotState().listen((state) {
      _stateController.add(state);
    });
    _initialized = true;
  }

  Future<void> startScan(
      void Function(List<BleDiscoveredDevice>) onDevices) async {
    await _ensureClient();
    if (_client == null) return;
    try {
      if (!await _client!.checkP2pPermissions()) {
        await _client!.askP2pPermissions();
      }
      if (!await _client!.checkBluetoothPermissions()) {
        await _client!.askBluetoothPermissions();
      }
      if (!await _client!.checkWifiEnabled()) {
        await _client!.enableWifiServices();
      }
      if (!await _client!.checkBluetoothEnabled()) {
        await _client!.enableBluetoothServices();
      }
      await _client!.startScan(onDevices);
    } catch (e) {
      print('P2P scan failed: $e');
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
      print('P2P connect failed: $e');
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
