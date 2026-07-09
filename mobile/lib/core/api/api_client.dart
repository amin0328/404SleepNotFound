import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://nusphere-backend.onrender.com/v1';
  static const _storage = FlutterSecureStorage();
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<void> init() async {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
        }
        handler.next(error);
      },
    ));
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  static String get socketUrl => '${baseUrl.replaceFirst('/v1', '')}:443';

  static Dio get dio => _dio;
}