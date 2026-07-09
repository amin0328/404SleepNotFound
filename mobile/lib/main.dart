import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/landing_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/navigation/navigator_key.dart';
import 'package:mobile/core/services/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init();
  final isLoggedIn = await ApiClient.hasToken();

  if (isLoggedIn) {
    PushService.instance.init();
  }

  runApp(ProviderScope(
    child: NusHubApp(isLoggedIn: isLoggedIn),
  ));
}

class NusHubApp extends StatelessWidget {
  final bool isLoggedIn;
  const NusHubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NUS Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003D7C)),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}