import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_models/shared_models.dart';

class RemoteWsClient {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  /// Dipanggil setiap kali paket masuk diterima dari TV
  /// (misal `SyncAction.stateUpdate` berisi fase siklus waktu shalat).
  void Function(SyncPacket packet)? onPacket;

  bool get isConnected => _isConnected;

  static final RegExp _ipv4 = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$');

  /// Validasi format alamat IPv4. Mengembalikan `true` bila `ipAddress`
  /// adalah IPv4 yang valid (mis. `192.168.1.10`).
  static bool isValidIp(String ipAddress) => _ipv4.hasMatch(ipAddress);

  Future<bool> connect(String ipAddress, {int port = 8080}) async {
    if (!isValidIp(ipAddress) || port <= 0 || port > 65535) {
      _disconnectChannel();
      return false;
    }
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:$port');
      final channel = WebSocketChannel.connect(wsUrl);
      // `WebSocketChannel.connect` bersifat lazy: `ready` baru benar-benar
      // terpenuhi setelah handshake WebSocket berhasil dengan TV. Tanpa ini,
      // _isConnected akan true walaupun alamat tidak punya server aktif.
      await channel.ready.timeout(const Duration(seconds: 5));
      _channel = channel;
      _isConnected = true;
      channel.stream.listen((message) {
        try {
          final String text =
              message is List<int> ? utf8.decode(message) : message.toString();
          onPacket?.call(SyncPacket.fromJson(text));
        } catch (_) {}
      });
      return true;
    } catch (e) {
      _disconnectChannel();
      return false;
    }
  }

  void _disconnectChannel() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void sendPacket(SyncPacket packet) {
    if (_isConnected && _channel != null) {
      _channel?.sink.add(packet.toJson());
    }
  }

  void sendConfigUpdate(MosqueConfig config) {
    sendPacket(SyncPacket(
      action: SyncAction.updateConfig,
      payload: config.toMap(),
    ));
  }

  void sendRunningTextsUpdate(List<RunningTextMessage> messages) {
    sendPacket(SyncPacket(
      action: SyncAction.updateRunningText,
      payload: {
        'messages': messages.map((m) => m.toMap()).toList(),
      },
    ));
  }

  void sendBannersUpdate(List<MediaBanner> banners) {
    sendPacket(SyncPacket(
      action: SyncAction.updateBanners,
      payload: {
        'banners': banners.map((b) => b.toMap()).toList(),
      },
    ));
  }

  void sendKasUpdate(List<KasTransaction> transactions) {
    sendPacket(SyncPacket(
      action: SyncAction.updateKas,
      payload: {
        'transactions': transactions.map((t) => t.toMap()).toList(),
      },
    ));
  }

  /// Skip Azan di TV (ADHAN -> PRE_IQOMAH).
  void sendSkipAdhan() {
    sendPacket(const SyncPacket(action: SyncAction.skipAdhan, payload: {}));
  }

  /// Skip Ikamah / Mulai Shalat (PRE_IQOMAH -> SHALAT).
  void sendStartShalat() {
    sendPacket(const SyncPacket(action: SyncAction.startShalat, payload: {}));
  }

  /// Selesai Khutbah -> mulai Jeda Ikamah (KHUTBAH -> PRE_IQOMAH, hari Jumat).
  void sendStartIqomah() {
    sendPacket(const SyncPacket(action: SyncAction.startIqomah, payload: {}));
  }

  /// Selesaikan mode shalat (SHALAT -> NORMAL).
  void sendFinishShalat() {
    sendPacket(const SyncPacket(action: SyncAction.finishShalat, payload: {}));
  }

  /// Paksa TV masuk fase tertentu (dari Menu Tes).
  void sendForcePhase(PrayerPhase phase) {
    sendPacket(SyncPacket(
      action: SyncAction.forcePhase,
      payload: {'phase': phase.name},
    ));
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
