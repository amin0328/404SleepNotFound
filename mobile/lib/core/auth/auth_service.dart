import '../api/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    ApiClient.setToken(res.data['token']);
    return res.data;
  }

  static Future<Map<String, dynamic>> register({
    required String nusnetId,
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.dio.post('/auth/register', data: {
      'nusnet_id': nusnetId,
      'name': name,
      'email': email,
      'password': password,
    });
    ApiClient.setToken(res.data['token']);
    return res.data;
  }

  static Future<void> logout() {
    ApiClient.clearToken();
    return Future.value();
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    print('TOKEN: ${ApiClient.token}');
    await ApiClient.dio.put('/users/me', data: data);
  }
}