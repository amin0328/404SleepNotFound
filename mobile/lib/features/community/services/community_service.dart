import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';

class CommunityService {
  static Future<List<Map<String, dynamic>>> getPosts({String? category}) async {
    try {
      final res = await ApiClient.dio.get('/posts', queryParameters: {
        if (category != null && category != 'all') 'category': category,
      });
      return List<Map<String, dynamic>>.from(res.data['posts'] ?? []);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load posts.';
      throw Exception(message);
    }
  }

  static Future<bool> toggleFavorite(String postId) async {
    try {
      final res = await ApiClient.dio.post('/posts/$postId/favorite');
      return res.data['favorited'] as bool;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to toggle favorite.';
      throw Exception(message);
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      await ApiClient.dio.delete('/posts/$postId');
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to delete post.';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> expressInterest(String postId) async {
    try {
      final res = await ApiClient.dio.post('/posts/$postId/interest');
      return res.data;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to express interest.';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String category,
    required String title,
    String? body,
    List<String>? tags,
    int? groupSize,
    String? moveInDate,
  }) async {
    try {
      final res = await ApiClient.dio.post('/posts', data: {
        'category': category,
        'title': title,
        if (body != null) 'body': body,
        if (tags != null) 'tags': tags,
        if (groupSize != null) 'group_size': groupSize,
        if (moveInDate != null) 'move_in_date': moveInDate,
      });
      return res.data['post'];
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to create post.';
      throw Exception(message);
    }
  }
}