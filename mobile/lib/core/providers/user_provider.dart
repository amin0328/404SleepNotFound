import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/auth/auth_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return AuthService.getMe();
});