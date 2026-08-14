import 'dart:async';
import 'dart:io';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2pHostService {
  FlutterP2pHost? _host;
  final _stateController = StreamController<HotspotHostState?>.broadcast();
  bool _started = false;

  HotspotHostState? _currentState;
  HotspotHostState? get currentState => _currentState;

  Stream<HotspotHostState?> get stateStream => _stateController.stream;

  Future<void> start() async {
    if (_started || !Platform.isAndroid) return;
    _started = true;
    try {
      _host = FlutterP2pHost();
      await _host!.initialize();

      _host!.streamHotspotState().listen((state) {
        _currentState = state;
        _stateController.add(state);
      });

      if (!await _host!.checkP2pPermissions()) {
        await _host!.askP2pPermissions();
      }
      if (!await _host!.checkBluetoothPermissions()) {
        await _host!.askBluetoothPermissions();
      }

      await _host!.createGroup(advertise: true);
    } catch (e) {
      print('P2P host start failed: $e');
    }
  }

  Future<void> stop() async {
    _started = false;
    try {
      await _host?.removeGroup();
      await _host?.dispose();
    } catch (_) {}
    _host = null;
    _currentState = null;
  }
}
