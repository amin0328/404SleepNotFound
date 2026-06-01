import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/v1';
  static String? _token;
  static String? get token => _token;

  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static void init() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
  }

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Dio get dio => _dio;
}