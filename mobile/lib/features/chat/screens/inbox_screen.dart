import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/core/services/socket_service.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/chat/screens/chat_screen.dart';
import 'package:mobile/features/chat/widgets/conversation_tile.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<SocketMessageEvent>? _messageSub;

  @override
  void initState() {
    super.initState();
    _load();
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    await SocketService.instance.connect();
    if (!mounted) return;
    _messageSub = SocketService.instance.messages.listen(_onIncomingMessage);
  }

  void _onIncomingMessage(SocketMessageEvent event) {
    final idx = _conversations.indexWhere(
      (c) => c.id == event.conversationId && c.type == event.type,
    );

    if (idx == -1) {
      _load();
      return;
    }

    setState(() {
      final updated = _conversations[idx].copyWith(
        lastMessage: event.message.body,
        lastMessageAt: event.message.createdAt,
      );
      _conversations.removeAt(idx);
      _conversations.insert(0, updated);
    });
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ChatService.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No conversations yet.\nMessage a buddy or open a group order chat to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF7C3AED),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, i) {
          final c = _conversations[i];
          return ConversationTile(
            conversation: c,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
              );
              if (mounted) _load();
            },
          );
        },
      ),
    );
  }
}