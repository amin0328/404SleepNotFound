import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/core/models/chat_message.dart';

class SocketMessageEvent {
  final ConversationType type;
  final String conversationId;
  final ChatMessage message;

  const SocketMessageEvent({
    required this.type,
    required this.conversationId,
    required this.message,
  });
}

class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();

  IO.Socket? _socket;

  final _messageController = StreamController<SocketMessageEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<SocketMessageEvent> get messages => _messageController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<bool> get connectionState => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await ApiClient.getToken();
    if (token == null) {
      _errorController.add('Cannot connect: no auth token.');
      return;
    }

    _socket?.dispose();
    _socket = IO.io(
      ApiClient.socketUrl,
      IO.OptionBuilder()
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) => _connectionController.add(true))
      ..onDisconnect((_) => _connectionController.add(false))
      ..onConnectError((err) => _errorController.add('Connection error: $err'))
      ..on('error', (data) {
        final msg = data is Map
            ? (data['message']?.toString() ?? 'Socket error')
            : data.toString();
        _errorController.add(msg);
      })
      ..on('message:new', (data) => _handleIncomingMessage(data));

    _socket!.connect();
  }

  void _handleIncomingMessage(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);
    final isGroup = data['group_conversation_id'] != null;
    final conversationId =
        (isGroup ? data['group_conversation_id'] : data['conversation_id']).toString();

    _messageController.add(SocketMessageEvent(
      type: isGroup ? ConversationType.group : ConversationType.direct,
      conversationId: conversationId,
      message: ChatMessage.fromJson(data),
    ));
  }

  void joinDirect(String conversationId) {
    _socket?.emit('join:direct', conversationId);
  }

  void joinGroup(String groupConversationId) {
    _socket?.emit('join:group', groupConversationId);
  }

  void sendDirectMessage(String conversationId, String body) {
    if (body.trim().isEmpty) return;
    _socket?.emit('message:direct', {
      'conversation_id': conversationId,
      'body': body.trim(),
    });
  }

  void sendGroupMessage(String groupConversationId, String body) {
    if (body.trim().isEmpty) return;
    _socket?.emit('message:group', {
      'group_conversation_id': groupConversationId,
      'body': body.trim(),
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}