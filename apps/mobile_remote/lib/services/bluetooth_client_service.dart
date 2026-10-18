import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_sync/bluetooth_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

/// Status Mode Bluetooth di sisi Remote.
enum BluetoothClientStatus {
  idle,
  discovering,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Snapshot state untuk UI (diteruskan lewat `stateStream`).
class BluetoothClientState {
  final BluetoothClientStatus status;
  final bool isScanning;
  final bool isConnected;
  final List<BluetoothDeviceInfo> devices;
  final String? peerName;
  final String? error;

  const BluetoothClientState({
    required this.status,
    this.isScanning = false,
    this.isConnected = false,
    this.devices = const [],
    this.peerName,
    this.error,
  });
}

/// Client Bluetooth Classic (RFCOMM) untuk Remote.
///
/// Mencari TV via discovery, menyambung ke perangkat terpilih, lalu
/// menukar [SyncPacket] dengan TV — mirror dari `BluetoothHostService`
/// di sisi TV.
class BluetoothClientService {
  /// Jumlah percobaan sambung ulang otomatis setelah koneksi putus.
  final int maxReconnectAttempts;

  /// Jeda sebelum percobaan sambung ulang.
  final Duration reconnectDelay;

  final _stateController = StreamController<BluetoothClientState>.broadcast();
  StreamSubscription<BluetoothSyncEvent>? _subscription;
  Timer? _reconnectTimer;
  Timer? _connectWatchdog;
  bool _discovering = false;
  bool _connected = false;
  bool _connecting = false;
  bool _reconnecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  List<BluetoothDeviceInfo> _devices = const [];
  String? _peerName;
  String? _error;

  /// Perangkat tujuan sambung ulang (diisi setelah connect berhasil).
  BluetoothDeviceInfo? _lastDevice;

  /// Dipanggil setiap kali [SyncPacket] masuk dari TV.
  void Function(SyncPacket packet)? onPacket;

  BluetoothClientService({
    this.maxReconnectAttempts = 3,
    this.reconnectDelay = const Duration(seconds: 3),
  });

  BluetoothClientState get currentState => BluetoothClientState(
        status: _statusFromFlags(),
        isScanning: _discovering,
        isConnected: _connected,
        devices: _devices,
        peerName: _peerName,
        error: _error,
      );

  Stream<BluetoothClientState> get stateStream => _stateController.stream;

  bool get isConnected => _connected;

  BluetoothClientStatus _statusFromFlags() {
    if (_connected) return BluetoothClientStatus.connected;
    if (_reconnecting) return BluetoothClientStatus.reconnecting;
    if (_connecting) return BluetoothClientStatus.connecting;
    if (_discovering) return BluetoothClientStatus.discovering;
    if (_error != null) return BluetoothClientStatus.error;
    return BluetoothClientStatus.idle;
  }

  void _emit() {
    if (_disposed || _stateController.isClosed) return;
    _stateController.add(currentState);
  }

  void _setError(String message) {
    _error = message;
    _emit();
  }

  /// Mulai discovery Bluetooth. Perangkat baru masuk lewat event
  /// `discovered`, lalu scan diakhiri event `discoveryFinished`.
  Future<void> startDiscovery() async {
    if (_disposed || _discovering || _connected || _connecting) return;

    _cancelReconnect();
    _error = null;
    _devices = const [];
    _discovering = true;
    _emit();

    try {
      if (!await BluetoothSync.hasPermission()) {
        final ok = await BluetoothSync.requestPermission();
        if (!ok) {
          _discovering = false;
          _setError('Izin Bluetooth / Lokasi belum diberikan.');
          return;
        }
      }
      if (!await BluetoothSync.isEnabled()) {
        final ok = await BluetoothSync.enable();
        if (!ok) {
          _discovering = false;
          _setError('Bluetooth mati — aktifkan dari Pengaturan.');
          return;
        }
      }
      _subscribeEvents();
      await BluetoothSync.startDiscovery();
    } catch (e) {
      _discovering = false;
      _setError('Gagal memulai scan Bluetooth: $e');
      debugPrint('BT discovery start failed: $e');
    }
  }

  Future<void> stopDiscovery() async {
    _discovering = false;
    try {
      await BluetoothSync.stopDiscovery();
    } catch (_) {}
    _emit();
  }

  /// Sambungkan ke perangkat [device] (TV) via insecure RFCOMM.
  Future<void> connectTo(BluetoothDeviceInfo device) async {
    if (_disposed || _connected || _connecting) return;
    _cancelReconnect();
    _reconnectAttempts = 0;
    _discovering = false;
    _connecting = true;
    _error = null;
    _emit();

    try {
      if (!await BluetoothSync.hasPermission()) {
        final ok = await BluetoothSync.requestPermission();
        if (!ok) {
          _connecting = false;
          _setError('Izin Bluetooth / Lokasi belum diberikan.');
          return;
        }
      }
      if (!await BluetoothSync.isEnabled()) {
        final ok = await BluetoothSync.enable();
        if (!ok) {
          _connecting = false;
          _setError('Bluetooth mati — aktifkan dari Pengaturan.');
          return;
        }
      }
      _lastDevice = device;
      _subscribeEvents();
      await BluetoothSync.connect(device.address);
      // Watchdog: jika tidak ada event connected/error/disconnect dalam
      // 20 detik, anggap TV tidak merespons.
      if (_connecting && !_reconnecting && !_disposed) {
        _connectWatchdog?.cancel();
        _connectWatchdog = Timer(const Duration(seconds: 20), () {
          if (_connecting && !_reconnecting && !_disposed) {
            _connecting = false;
            _setError('Tidak ada respons dari TV.');
          }
        });
      }
      // Sambung ulang otomatis menunggu event `connected`; connect pertama
      // diperlakukan selesai di sini (kegagalan datang lewat event `error`).
      // Status `connected` ditetapkan lewat event, bukan di sini —
      // karena RFCOMM connect bisa gagal setelah method call sukses.
    } catch (e) {
      _connecting = false;
      _setError('Gagal menyambung ke ${device.name}: $e');
      debugPrint('BT connect failed: $e');
    }
  }

  /// Kirim [packet] ke TV (jika ada koneksi aktif).
  Future<void> sendPacket(SyncPacket packet) async {
    if (!_connected) return;
    final bytes = Uint8List.fromList(utf8.encode(packet.toJson()));
    try {
      await BluetoothSync.send(bytes);
    } catch (e) {
      debugPrint('BT send failed: $e');
    }
  }

  void _onEvent(BluetoothSyncEvent event) {
    switch (event.type) {
      case BluetoothSyncEventType.discovered:
        final address = event.deviceAddress ?? '';
        if (address.isEmpty) break;
        // Perangkat tanpa nama tetap ditampilkan sebagai "?" (di plugin
        // namanya bisa belum terlihat saat discovery berjalan).
        final info = BluetoothDeviceInfo.fromMap({
          'name': event.deviceName,
          'address': address,
          'bonded': event.bonded,
        });
        final exists = _devices.any((d) => d.address == address);
        if (!exists) {
          _devices = [..._devices, info];
          _emit();
        }
        break;
      case BluetoothSyncEventType.discoveryFinished:
        _discovering = false;
        _emit();
        break;
      case BluetoothSyncEventType.connected:
        _connectWatchdog?.cancel();
        _connectWatchdog = null;
        _connected = true;
        _connecting = false;
        _reconnecting = false;
        _reconnectAttempts = 0;
        _cancelReconnect();
        _peerName = event.deviceName ?? _lastDevice?.name;
        _error = null;
        if (_lastDevice == null && event.deviceAddress != null) {
          _lastDevice = BluetoothDeviceInfo(
            name: _peerName ?? '?',
            address: event.deviceAddress!,
            bonded: false,
          );
        }
        _emit();
        break;
      case BluetoothSyncEventType.disconnected:
        _handleDisconnected();
        break;
      case BluetoothSyncEventType.data:
        final bytes = event.data;
        if (bytes != null) {
          try {
            onPacket?.call(SyncPacket.fromJson(utf8.decode(bytes)));
          } catch (_) {
            // Paket tidak valid; abaikan.
          }
        }
        break;
      case BluetoothSyncEventType.error:
        // Error apa pun berarti transport putus; jangan biarkan UI
        // menampilkan "connected".
        final wasConnected = _connected;
        final wasDiscovering = _discovering;
        _connectWatchdog?.cancel();
        _connectWatchdog = null;
        final message = event.error ?? 'Error Bluetooth tidak diketahui.';
        _connected = false;
        _connecting = false;
        _discovering = false;
        _setError(message);
        if (!wasDiscovering && (wasConnected || _lastDevice != null)) {
          _scheduleReconnect(message: message, fromError: true);
        }
        break;
      case BluetoothSyncEventType.listening:
        break;
    }
  }

  void _handleDisconnected() {
    final wasConnected = _connected;
    _connectWatchdog?.cancel();
    _connectWatchdog = null;
    _connected = false;
    _connecting = false;
    _peerName = null;
    if (wasConnected || _lastDevice != null) {
      _setError('Koneksi ke TV terputus.');
      _scheduleReconnect();
    } else {
      _emit();
    }
  }

  void _scheduleReconnect({bool fromError = false, String? message}) {
    if (_disposed || _lastDevice == null) return;
    // Error/disconnect lanjutan saat reconnect berjalan tidak boleh keluar
    // lebih awal: anggaran percobaan tetap harus habis, dan pesan error asli
    // tetap tersimpan selama masih ada jadwal reconnect.
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('BT reconnect menyerah: ${(message ?? '').trim()}');
      _reconnecting = false;
      _cancelReconnectTimer();
      // Error asli dipertahankan apa adanya selama tidak ada anggaran
      // reconnect sama sekali (pemanggil/UI tahu sebab putusnya). Kalau
      // percobaan reconnect sudah dijalankan lalu habis, beri tahu bahwa
      // sambung ulang otomatis berhenti dan aksi manual tersedia.
      if (_reconnectAttempts == 0) {
        // Belum pernah ada percobaan (maxReconnectAttempts 0): status harus
        // menampilkan error, jadi emit ulang snapshot yang sama.
        _emit();
        return;
      }
      _setError(
        'Koneksi ke TV terputus. Tekan sambung untuk mencoba lagi.',
      );
      return;
    }
    _reconnectAttempts++;
    _reconnecting = true;
    _error = message;
    _emit();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, _attemptReconnect);
  }

  Future<void> _attemptReconnect() async {
    final device = _lastDevice;
    if (_disposed || device == null) return;
    if (_connected || _connecting) {
      _reconnecting = false;
      _emit();
      return;
    }
    try {
      await BluetoothSync.connect(device.address);
    } catch (e) {
      debugPrint('BT reconnect failed: $e');
      _reconnecting = false;
      _scheduleReconnect(message: e.toString(), fromError: true);
    }
  }

  void _cancelReconnect() {
    _cancelReconnectTimer();
    _reconnecting = false;
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _subscribeEvents() {
    _subscription ??= BluetoothSync.events.listen(
      _onEvent,
      onError: (Object e) {
        debugPrint('BT client event error: $e');
      },
    );
  }

  /// Putuskan koneksi. Sambung ulang otomatis dan discovery dihentikan.
  Future<void> disconnect() async {
    _cancelReconnect();
    _connectWatchdog?.cancel();
    _connectWatchdog = null;
    _reconnectAttempts = 0;
    _lastDevice = null;
    _discovering = false;
    _connecting = false;
    _connected = false;
    _peerName = null;
    _devices = const [];
    _error = null;
    try {
      await BluetoothSync.disconnect();
    } catch (_) {}
    _emit();
  }

  Future<void> dispose() async {
    await disconnect();
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    await _stateController.close();
  }
}

