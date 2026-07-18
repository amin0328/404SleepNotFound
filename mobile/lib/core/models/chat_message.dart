class ChatMessage {
  final String id;
  final String body;
  final DateTime createdAt;
  final String senderId;

  final String? senderName;
  final String? senderAvatar;
  final String? imageUrl;

  const ChatMessage({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    this.imageUrl,
  });

  bool isMine(String currentUserId) => senderId == currentUserId;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'].toString(),
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at']),
        senderId: json['sender_id'].toString(),
        senderName: json['sender_name'] as String?,
        senderAvatar: json['sender_avatar'] as String?,
        imageUrl: json['image_url'] as String?,
      );

  ChatMessage copyWithSender({String? senderName, String? senderAvatar}) => ChatMessage(
        id: id,
        body: body,
        createdAt: createdAt,
        senderId: senderId,
        senderName: senderName ?? this.senderName,
        senderAvatar: senderAvatar ?? this.senderAvatar,
        imageUrl: imageUrl,
      );
}
