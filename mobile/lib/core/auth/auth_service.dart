import 'package:dio/dio.dart';
import '../api/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      print('Login response: ${res.data}');
      ApiClient.setToken(res.data['token']);
      return res.data;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Login failed. Please try again.';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nusnetId,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await ApiClient.dio.post('/auth/register', data: {
        'nusnet_id': nusnetId,
        'name': name,
        'email': email,
        'password': password,
      });
      ApiClient.setToken(res.data['token']);
      return res.data;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Registration failed. Please try again.';
      throw Exception(message);
    }
  }

  static Future<void> logout() {
    ApiClient.clearToken();
    return Future.value();
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('/users/me', data: data);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to update profile.';
      throw Exception(message);
    }
  }
}