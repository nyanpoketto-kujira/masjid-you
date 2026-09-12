import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as init_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_models/shared_models.dart';

class LocalServer {
  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  final void Function(SyncPacket packet) onPacketReceived;

  LocalServer({required this.onPacketReceived});

  Future<int?> start({int port = 8080}) async {
    try {
      final handler = webSocketHandler((dynamic webSocket, [protocol]) {
        if (webSocket is WebSocketChannel) {
          _clients.add(webSocket);

          webSocket.stream.listen(
            (message) {
              try {
                final String text = message is List<int> ? utf8.decode(message) : message.toString();
                final packet = SyncPacket.fromJson(text);
                onPacketReceived(packet);
              } catch (_) {}
            },
            onDone: () => _clients.remove(webSocket),
            onError: (_) => _clients.remove(webSocket),
          );
        }
      });

      _server = await init_io.serve(handler, InternetAddress.anyIPv4, port);
      print('Local TV WebSocket server running on port ${_server?.port}');
      return _server?.port;
    } catch (e) {
      print('Failed to start local server: $e');
      return null;
    }
  }

  void broadcast(SyncPacket packet) {
    final jsonString = packet.toJson();
    for (final client in List.of(_clients)) {
      client.sink.add(jsonString);
    }
  }

  Future<void> stop() async {
    // Iterasi salinan: sink.close() memicu onDone yang menghapus klien dari
    // _clients, sehingga iterasi langsung atas _clients bisa melempar
    // ConcurrentModificationError saat ada klien aktif saat shutdown.
    for (final client in List.of(_clients)) {
      await client.sink.close();
    }
    _clients.clear();
    await _server?.close(force: true);
    _server = null;
  }
}
