// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
      home: const Scaffold(
        body: Center(
          child: Text('NUS International Student Hub'),
        ),
      ),
    );
  }
}