import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/core/models/chat_message.dart';
import 'package:mobile/core/providers/user_provider.dart';
import 'package:mobile/core/services/socket_service.dart';
import 'package:mobile/features/chat/services/chat_service.dart';
import 'package:mobile/features/chat/widgets/chat_input_bar.dart';
import 'package:mobile/features/chat/widgets/message_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/shared/widgets/avatar_circle.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final Map<String, String> _senderNames = {};

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<SocketMessageEvent>? _messageSub;
  StreamSubscription<String>? _errorSub;

  bool get _isGroup => widget.conversation.type == ConversationType.group;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _connectAndJoin();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final messages = _isGroup
          ? await ChatService.getGroupMessages(widget.conversation.id)
          : await ChatService.getDirectMessages(widget.conversation.id);

      for (final m in messages) {
        if (m.senderName != null) _senderNames[m.senderId] = m.senderName!;
      }

      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom(animate: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _connectAndJoin() async {
    await SocketService.instance.connect();
    if (!mounted) return;

    if (_isGroup) {
      SocketService.instance.joinGroup(widget.conversation.id);
    } else {
      SocketService.instance.joinDirect(widget.conversation.id);
    }

    _messageSub = SocketService.instance.messages.listen((event) {
      if (event.conversationId != widget.conversation.id) return;
      if (event.type != widget.conversation.type) return;

      var message = event.message;
      if (message.senderName != null) {
        _senderNames[message.senderId] = message.senderName!;
      } else {
        final knownName = _senderNames[message.senderId] ??
            (message.senderId == widget.conversation.otherUserId
                ? widget.conversation.otherUserName
                : null);
        if (knownName != null) {
          message = message.copyWithSender(senderName: knownName);
        }
      }

      if (!mounted) return;
      setState(() => _messages = [..._messages, message]);
      _scrollToBottom();
    });

    _errorSub = SocketService.instance.errors.listen((err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    });
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _handleSend(String text) {
    if (_isGroup) {
      SocketService.instance.sendGroupMessage(widget.conversation.id, text);
    } else {
      SocketService.instance.sendDirectMessage(widget.conversation.id, text);
    }
  }

  Future<void> _handleImageSelected(XFile image, String caption) async {
    try {
      final imageUrl = await ChatService.uploadImage(image);
      if (_isGroup) {
        SocketService.instance.sendGroupMessage(widget.conversation.id, caption, imageUrl: imageUrl);
      } else {
        SocketService.instance.sendDirectMessage(widget.conversation.id, caption, imageUrl: imageUrl);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _errorSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userProvider).valueOrNull?['id']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        titleSpacing: 0,
        title: Row(
          children: [
            _isGroup
                ? const AvatarCircle(icon: Icons.groups, backgroundColor: Color(0xFF34D399), size: 36)
                : AvatarCircle(
                    name: widget.conversation.otherUserName,
                    imageUrl: widget.conversation.otherUserAvatar,
                    size: 36,
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.conversation.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(currentUserId)),
          ChatInputBar(onSend: _handleSend, onImageSelected: _handleImageSelected),
        ],
      ),
    );
  }

  Widget _buildBody(String? currentUserId) {
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
            TextButton(onPressed: _loadHistory, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text('No messages yet. Say hi!', style: TextStyle(color: Color(0xFF94A3B8))),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isMine = currentUserId != null && m.isMine(currentUserId);
        return MessageBubble(message: m, isMine: isMine, showSenderName: _isGroup);
      },
    );
  }
}
