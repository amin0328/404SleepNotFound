enum ConversationType { direct, group }

class Conversation {
  final String id;
  final ConversationType type;

  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;

  final String? orderId;
  final String? orderName;
  final String? store;

  final String? lastMessage;
  final DateTime? lastMessageAt;

  const Conversation({
    required this.id,
    required this.type,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.orderId,
    this.orderName,
    this.store,
    this.lastMessage,
    this.lastMessageAt,
  });

  String get displayTitle {
    if (type == ConversationType.direct) return otherUserName ?? 'Unknown';
    return orderName ?? store ?? 'Group Order';
  }

  factory Conversation.fromDirectJson(Map<String, dynamic> json) => Conversation(
        id: json['id'].toString(),
        type: ConversationType.direct,
        otherUserId: json['other_user_id']?.toString(),
        otherUserName: json['other_user_name'] as String?,
        otherUserAvatar: json['other_user_avatar'] as String?,
        lastMessage: json['last_message'] as String?,
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'])
            : null,
      );

  factory Conversation.fromGroupJson(Map<String, dynamic> json) => Conversation(
        id: json['id'].toString(),
        type: ConversationType.group,
        orderId: json['order_id']?.toString(),
        orderName: json['order_name'] as String?,
        store: json['store'] as String?,
        lastMessage: json['last_message'] as String?,
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'])
            : null,
      );

  Conversation copyWith({String? lastMessage, DateTime? lastMessageAt}) => Conversation(
        id: id,
        type: type,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
        orderId: orderId,
        orderName: orderName,
        store: store,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );
}