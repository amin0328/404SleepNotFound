import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/landing_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/core/api/api_client.dart';

void main() {
  ApiClient.init();
  runApp(
    const ProviderScope(
      child: NusHubApp(),
    ),
  );
}

class NusHubApp extends StatelessWidget {
  const NusHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUS Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003D7C)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}