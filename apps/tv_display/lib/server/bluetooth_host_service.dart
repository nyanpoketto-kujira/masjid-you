import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

/// Status Mode Bluetooth di sisi TV.
enum BluetoothHostStatus {
  idle,
  listening,
  connected,
  error,
}

class BluetoothHostState {
  final BluetoothHostStatus status;
  final String? peerName;
  final String? error;

  const BluetoothHostState({
    required this.status,
    this.peerName,
    this.error,
  });

  bool get isActive => status == BluetoothHostStatus.connected;
}

/// Host Bluetooth Classic (RFCOMM) untuk sync TV.
///
/// Menerima satu koneksi Remote, lalu meneruskan paket [SyncPacket] yang
/// masuk ke [onPacketReceived] — sama seperti `LocalServer` (WebSocket).
class BluetoothHostService {
  final void Function(SyncPacket packet) onPacketReceived;

  /// Interval re-arm discoverable (Android membatasi maksimal 300 detik).
  final Duration discoverableRefresh;

  /// Durasi yang diminta tiap kali dialog discoverable dibuka.
  final int discoverableSeconds;

  final _stateController = StreamController<BluetoothHostState>.broadcast();
  StreamSubscription<BluetoothSyncEvent>? _subscription;
  Timer? _discoverableTimer;
  bool _started = false;
  bool _connected = false;
  String? _peerName;
  int _discoverableFailures = 0;
  bool _discoverableRequestInFlight = false;

  BluetoothHostService({
    required this.onPacketReceived,
    this.discoverableRefresh = const Duration(seconds: 110),
    this.discoverableSeconds = 120,
  });

  BluetoothHostState _currentState =
      const BluetoothHostState(status: BluetoothHostStatus.idle);
  BluetoothHostState get currentState => _currentState;

  Stream<BluetoothHostState> get stateStream => _stateController.stream;

  bool get isRunning => _started;
  bool get isConnected => _connected;

  void _emit(BluetoothHostState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// Jalankan host: minta izin, mulai RFCOMM, dan buat perangkat terlihat.
  Future<void> start() async {
    if (_started) return;
    if (!kIsWeb && !Platform.isAndroid) return;

    _started = true;
    _peerName = null;
    _connected = false;

    try {
      if (!await BluetoothSync.isSupported()) {
        _fail('Bluetooth tidak didukung di perangkat ini.');
        return;
      }

      if (!await BluetoothSync.hasPermission(mode: 'host')) {
        final granted = await _requestPermission();
        if (!granted) {
          _fail('Izin Bluetooth (Sekitar perangkat) ditolak — '
              'beri izin di Pengaturan aplikasi.');
          return;
        }
      }

      if (!await BluetoothSync.isEnabled()) {
        final ok = await BluetoothSync.enable();
        if (!ok) {
          _fail('Bluetooth mati — aktifkan dari Pengaturan.');
          return;
        }
      }

      _subscription = BluetoothSync.events.listen(
        _onEvent,
        onError: (Object e) {
          debugPrint('Bluetooth host event error: $e');
        },
      );

      await BluetoothSync.startHost('Masjid You TV');
      if (!_started) return;

      _emit(const BluetoothHostState(status: BluetoothHostStatus.listening));

      // TV harus terlihat di discovery Remote; ulangi sebelum durasi habis.
      await _makeDiscoverable();
      if (!_started) return;
      if (_discoverableFailures < 2) {
        _discoverableTimer =
            Timer.periodic(discoverableRefresh, (_) => _makeDiscoverable());
      }
    } catch (e) {
      _fail('Gagal mulai Bluetooth: $e');
      debugPrint('Bluetooth host start failed: $e');
    }
  }

  Future<bool> _requestPermission() async {
    try {
      return await BluetoothSync.requestPermission(mode: 'host');
    } on PlatformException catch (e) {
      debugPrint('Bluetooth host permission request failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Bluetooth host permission request error: $e');
      return false;
    }
  }

  /// Minta TV terlihat. Tidak pernah melempar: kegagalan (user menolak atau
  /// Activity belum siap) hanya dicatat, host tetap menerima koneksi.
  ///
  /// Bila ditolak 2x berturut-turut, timer discoverable dihentikan — host
  /// tetap listening dan dapat menerima koneksi yang sudah paired.
  Future<bool> _makeDiscoverable() async {
    if (!_started) return false;
    if (_discoverableRequestInFlight) return false;
    _discoverableRequestInFlight = true;
    try {
      final ok = await BluetoothSync.makeDiscoverable(discoverableSeconds);
      if (ok) {
        _discoverableFailures = 0;
      } else {
        _discoverableFailures++;
        debugPrint('Bluetooth makeDiscoverable ditolak '
            '($_discoverableFailures kali).');
        if (_discoverableFailures >= 2) {
          _discoverableTimer?.cancel();
          _discoverableTimer = null;
          debugPrint('Bluetooth discoverable ditolak 2x — timer dihentikan; '
              'host tetap listening.');
        }
      }
      return ok;
    } catch (e) {
      _discoverableFailures++;
      debugPrint('Bluetooth makeDiscoverable failed: $e '
          '($_discoverableFailures kali).');
      if (_discoverableFailures >= 2) {
        _discoverableTimer?.cancel();
        _discoverableTimer = null;
        debugPrint('Bluetooth discoverable gagal 2x — timer dihentikan; '
            'host tetap listening.');
      }
      return false;
    } finally {
      _discoverableRequestInFlight = false;
    }
  }

  void _fail(String message) {
    _started = false;
    _connected = false;
    _peerName = null;
    _discoverableTimer?.cancel();
    _discoverableTimer = null;
    _discoverableFailures = 0;
    _discoverableRequestInFlight = false;
    _emit(BluetoothHostState(status: BluetoothHostStatus.error, error: message));
  }

  void _onEvent(BluetoothSyncEvent event) {
    switch (event.type) {
      case BluetoothSyncEventType.connected:
        _connected = true;
        _peerName = event.deviceName;
        _emit(BluetoothHostState(
          status: BluetoothHostStatus.connected,
          peerName: _peerName,
        ));
        break;
      case BluetoothSyncEventType.disconnected:
        _connected = false;
        _peerName = null;
        _emit(const BluetoothHostState(
          status: BluetoothHostStatus.listening,
        ));
        break;
      case BluetoothSyncEventType.data:
        final bytes = event.data;
        if (bytes != null) {
          try {
            final packet = SyncPacket.fromJson(utf8.decode(bytes));
            onPacketReceived(packet);
          } catch (_) {
            // Paket tidak valid; abaikan.
          }
        }
        break;
      case BluetoothSyncEventType.error:
        // Setelah stop, jangan emit apa-apa (hindari chip error palsu).
        if (!_started) break;
        // Error saat koneksi aktif / saat listening = gangguan jalur, bukan
        // kegagalan setup: kembali ke listening dan jangan timpa status chip
        // dengan error yang tidak bisa dipulihkan tanpa restart.
        if (_connected ||
            _currentState.status == BluetoothHostStatus.listening) {
          _connected = false;
          _peerName = null;
          _emit(const BluetoothHostState(
            status: BluetoothHostStatus.listening,
          ));
        } else {
          _fail(event.error ?? 'Error Bluetooth tidak diketahui.');
        }
        break;
      case BluetoothSyncEventType.listening:
      case BluetoothSyncEventType.discovered:
      case BluetoothSyncEventType.discoveryFinished:
        break;
    }
  }

  /// Kirim [packet] ke Remote (jika ada koneksi aktif).
  Future<void> broadcast(SyncPacket packet) async {
    if (!_connected) return;
    final bytes = Uint8List.fromList(utf8.encode(packet.toJson()));
    try {
      await BluetoothSync.send(bytes);
    } catch (e) {
      debugPrint('Bluetooth broadcast failed: $e');
    }
  }

  Future<void> stop() async {
    _started = false;
    _connected = false;
    _peerName = null;
    _discoverableTimer?.cancel();
    _discoverableTimer = null;
    _discoverableFailures = 0;
    _discoverableRequestInFlight = false;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await BluetoothSync.stopHost();
    } catch (_) {}
    _emit(const BluetoothHostState(status: BluetoothHostStatus.idle));
  }
}
