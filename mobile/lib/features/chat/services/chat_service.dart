import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/core/models/chat_message.dart';

class ChatService {
  static Future<List<Conversation>> getConversations() async {
    try {
      final res = await ApiClient.dio.get('/chat');

      final direct = List<Map<String, dynamic>>.from(res.data['direct'] ?? [])
          .map(Conversation.fromDirectJson);
      final group = List<Map<String, dynamic>>.from(res.data['group'] ?? [])
          .map(Conversation.fromGroupJson);

      final all = [...direct, ...group];
      all.sort((a, b) {
        if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });
      return all;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load conversations.';
      throw Exception(message);
    }
  }

  static Future<String> startDirectChat(String targetUserId) async {
    try {
      final res = await ApiClient.dio.post('/chat/direct', data: {
        'target_user_id': targetUserId,
      });
      return res.data['conversation_id'].toString();
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to start chat.';
      throw Exception(message);
    }
  }

  static Future<String> startGroupChat(String orderId) async {
    try {
      final res = await ApiClient.dio.post('/chat/group-order', data: {
        'order_id': orderId,
      });
      return res.data['group_conversation_id'].toString();
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to open group chat.';
      throw Exception(message);
    }
  }

  static Future<List<ChatMessage>> getDirectMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/chat/direct/$conversationId/messages',
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before.toIso8601String(),
        },
      );
      return List<Map<String, dynamic>>.from(res.data['messages'] ?? [])
          .map(ChatMessage.fromJson)
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load messages.';
      throw Exception(message);
    }
  }

  static Future<List<ChatMessage>> getGroupMessages(
    String groupConversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/chat/group/$groupConversationId/messages',
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before.toIso8601String(),
        },
      );
      return List<Map<String, dynamic>>.from(res.data['messages'] ?? [])
          .map(ChatMessage.fromJson)
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load messages.';
      throw Exception(message);
    }
  }
}