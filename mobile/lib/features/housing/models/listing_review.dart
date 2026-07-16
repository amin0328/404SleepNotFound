class ListingReview {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final String createdAt;

  const ListingReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ListingReview.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['created_at'] != null) {
      final raw = json['created_at'].toString();
      formattedDate = raw.length >= 10 ? raw.substring(0, 10) : raw;
    }

    return ListingReview(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'],
      rating: int.tryParse((json['rating'] ?? 0).toString()) ?? 0,
      comment: json['comment'],
      createdAt: formattedDate,
    );
  }
}