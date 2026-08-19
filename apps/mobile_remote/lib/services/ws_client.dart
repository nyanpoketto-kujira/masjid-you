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

  Future<bool> connect(String ipAddress, {int port = 8080}) async {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:$port');
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel?.ready;
      _isConnected = true;
      _channel?.stream.listen((message) {
        try {
          final String text =
              message is List<int> ? utf8.decode(message) : message.toString();
          onPacket?.call(SyncPacket.fromJson(text));
        } catch (_) {}
      });
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
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
