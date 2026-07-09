import 'package:flutter/material.dart';
import 'package:mobile/core/models/conversation.dart';
import 'package:mobile/shared/widgets/avatar_circle.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = conversation.type == ConversationType.group;
    final hasMessage = conversation.lastMessage != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isGroup
                ? const AvatarCircle(icon: Icons.groups, backgroundColor: Color(0xFF34D399))
                : AvatarCircle(
                    name: conversation.otherUserName,
                    imageUrl: conversation.otherUserAvatar,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessage ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasMessage ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                      fontSize: 13,
                      fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (conversation.lastMessageAt != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatTime(conversation.lastMessageAt!),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final isToday = local.year == now.year && local.month == now.month && local.day == now.day;
    if (isToday) {
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${local.month}/${local.day}';
  }
}