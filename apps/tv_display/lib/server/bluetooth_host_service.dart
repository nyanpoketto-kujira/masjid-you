import 'dart:async';
import 'dart:convert';
import 'dart:math';
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

  /// `true` bila Remote sudah melewati autentikasi PIN. State `connected`
  /// sebelum autentikasi dianggap belum aman (data belum boleh dikirim).
  final bool authenticated;

  const BluetoothHostState({
    required this.status,
    this.peerName,
    this.error,
    this.authenticated = false,
  });

  bool get isActive => status == BluetoothHostStatus.connected;

  /// `true` bila Remote sudah melewati autentikasi PIN dan status connected.
  bool get isAuthenticated => isActive && authenticated;
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

  /// PIN 4 digit yang ditampilkan di menu admin. Di-regenerate tiap kali
  /// koneksi dimulai (toggle ON), supaya PIN lama kedaluwarsa.
  String? _pin;
  String? get pin => _pin;

  /// Nonce acak untuk challenge auth. Di-regenerate tiap koneksi baru.
  String? _nonce;

  /// `true` bila Remote yang tersambung sudah menjawab PIN dengan benar.
  bool _authenticated = false;

  /// Jumlah percobaan PIN salah yang masih diizinkan sebelum koneksi ditutup.
  static const int _maxAuthAttempts = 3;
  int _authAttempts = 0;

  /// Jumlah percobaan PIN salah dari koneksi sebelumnya (reset tiap koneksi).
  static const int _pinLength = 4;
  final Random _random = Random.secure();

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
    if (kIsWeb) return;

    _started = true;
    _peerName = null;
    _connected = false;
    _authenticated = false;
    _authAttempts = 0;

    // Regenerate PIN setiap koneksi dimulai agar PIN lama tidak dipakai ulang.
    _pin = _generatePin();

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
    _authenticated = false;
    _nonce = null;
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
        _authenticated = false;
        _authAttempts = 0;
        // Nonce baru tiap koneksi: challenge tidak bisa di-replay dari
        // koneksi sebelumnya (PIN bisa saja bocor di layar).
        _nonce = _generateNonce();
        _emit(BluetoothHostState(
          status: BluetoothHostStatus.connected,
          peerName: _peerName,
          authenticated: false,
        ));
        // Challenge dikirim segera setelah koneksi terbentuk. Remote yang
        // tidak mengirim authResponse tidak pernah bisa memakai jalur ini.
        unawaited(_sendAuthChallenge());
        break;
      case BluetoothSyncEventType.disconnected:
        _connected = false;
        _peerName = null;
        _authenticated = false;
        _nonce = null;
        _emit(const BluetoothHostState(
          status: BluetoothHostStatus.listening,
        ));
        break;
      case BluetoothSyncEventType.data:
        final bytes = event.data;
        if (bytes != null) {
          try {
            final packet = SyncPacket.fromJson(utf8.decode(bytes));
            _handlePacket(packet);
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
          _authenticated = false;
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

  /// Rute paket masuk: paket auth diproses di sini, paket data hanya
  /// diteruskan ke [onPacketReceived] setelah Remote ter-autentikasi.
  void _handlePacket(SyncPacket packet) {
    switch (packet.action) {
      case SyncAction.authResponse:
        _handleAuthResponse(packet);
        break;
      case SyncAction.authChallenge:
      case SyncAction.authSuccess:
      case SyncAction.authFailure:
        // Paket auth yang tidak seharusnya datang dari Remote; abaikan.
        break;
      default:
        if (!_authenticated) {
          debugPrint('Bluetooth paket ${packet.action} ditolak: belum '
              'autentikasi.');
          return;
        }
        onPacketReceived(packet);
        break;
    }
  }

  /// Verifikasi jawaban PIN Remote terhadap challenge aktif.
  void _handleAuthResponse(SyncPacket packet) {
    final pin = packet.payload['pin'] as String?;
    final nonce = packet.payload['nonce'] as String?;
    if (!_connected) return;

    if (_authenticated) {
      // Sudah berhasil; ulangi jawaban tidak berbahaya, cukup abaikan.
      return;
    }
    if (_nonce == null || nonce != _nonce || pin == null || pin.isEmpty) {
      _registerAuthFailure('Sesi autentikasi tidak valid (nonce salah).');
      return;
    }
    if (pin == _pin) {
      _authenticated = true;
      _emit(BluetoothHostState(
        status: BluetoothHostStatus.connected,
        peerName: _peerName,
        authenticated: true,
      ));
      unawaited(_sendPacket(const SyncPacket(
        action: SyncAction.authSuccess,
        payload: {},
      )));
    } else {
      _registerAuthFailure('PIN salah.');
    }
  }

  void _registerAuthFailure(String reason) {
    _authAttempts++;
    debugPrint('Bluetooth auth gagal ($_authAttempts/$_maxAuthAttempts): '
        '$reason');
    if (_authAttempts >= _maxAuthAttempts) {
      // Kunci koneksi setelah 3x salah; putus agar Remote harus connect ulang.
      unawaited(_sendPacket(SyncPacket(
        action: SyncAction.authFailure,
        payload: {'error': 'PIN salah 3 kali. Sambungkan kembali.'},
      )));
      _connected = false;
      _peerName = null;
      _authenticated = false;
      _nonce = null;
      // Buka koneksi di sisi native; host kembali listening.
      unawaited(BluetoothSync.disconnect());
      _emit(const BluetoothHostState(
        status: BluetoothHostStatus.listening,
      ));
      return;
    }
    unawaited(_sendPacket(SyncPacket(
      action: SyncAction.authFailure,
      payload: {'error': '$reason Percobaan ke-${_authAttempts + 1}.'},
    )));
  }

  Future<void> _sendAuthChallenge() async {
    final nonce = _nonce;
    if (nonce == null) return;
    await _sendPacket(SyncPacket(
      action: SyncAction.authChallenge,
      payload: {'nonce': nonce},
    ));
  }

  Future<void> _sendPacket(SyncPacket packet) async {
    if (!_connected) return;
    final bytes = Uint8List.fromList(utf8.encode(packet.toJson()));
    try {
      await BluetoothSync.send(bytes);
    } catch (e) {
      debugPrint('Bluetooth send failed: $e');
    }
  }

  /// Generate PIN 4 digit acak (0000-9999), leading zero dipertahankan.
  String _generatePin() {
    final value = _random.nextInt(10000);
    return value.toString().padLeft(_pinLength, '0');
  }

  /// Generate nonce hex acak 128-bit (32 hex chars).
  String _generateNonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Kirim [packet] ke Remote (hanya bila koneksi aktif & sudah autentikasi).
  Future<void> broadcast(SyncPacket packet) async {
    if (!_connected || !_authenticated) return;
    await _sendPacket(packet);
  }

  Future<void> stop() async {
    _started = false;
    _connected = false;
    _peerName = null;
    _authenticated = false;
    _nonce = null;
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
