import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../models/chat_models.dart';

/// Тип события из сокета.
enum SocketEventType { message, error, pong, unknown }

class SocketEvent {
  const SocketEvent(this.type, {this.message, this.detail});

  final SocketEventType type;
  final ChatMessage? message;
  final String? detail;
}

/// Управляет одним WebSocket-соединением для чата.
///
/// Автоматически переподключается при разрыве.
/// Публикует события через [stream].
class ChatSocket {
  ChatSocket({
    required this.chatId,
    required String accessToken,
  }) : _token = accessToken;

  final int chatId;
  final String _token;

  WebSocketChannel? _channel;
  final _controller = StreamController<SocketEvent>.broadcast();
  bool _disposed = false;
  Timer? _reconnectTimer;

  Stream<SocketEvent> get stream => _controller.stream;

  /// Открыть соединение (вызывать один раз).
  void connect() {
    _connect();
  }

  void _connect() {
    if (_disposed) return;
    try {
      final wsBase = ApiConfig.baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final uri = Uri.parse('$wsBase/ws/chat/$chatId?token=$_token');
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';
      switch (type) {
        case 'message':
          final msg = ChatMessage.fromJson(data);
          _controller.add(SocketEvent(SocketEventType.message, message: msg));
        case 'pong':
          _controller.add(const SocketEvent(SocketEventType.pong));
        case 'error':
          _controller.add(
            SocketEvent(SocketEventType.error,
                detail: data['detail'] as String?),
          );
        default:
          _controller.add(const SocketEvent(SocketEventType.unknown));
      }
    } catch (_) {}
  }

  void _onError(Object err) {
    _scheduleReconnect();
  }

  void _onDone() {
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) _connect();
    });
  }

  /// Отправить сообщение через сокет.
  void sendMessage(String text) {
    _channel?.sink.add(jsonEncode({'type': 'message', 'text': text}));
  }

  /// Закрыть навсегда.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}
