import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_models/shared_models.dart';

class RemoteWsClient {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<bool> connect(String ipAddress, {int port = 8080}) async {
    try {
      final wsUrl = Uri.parse('ws://$ipAddress:$port');
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel?.ready;
      _isConnected = true;
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

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
