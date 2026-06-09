import 'dart:math';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final _starData = const [
    (48.68, 85.68, 14.64),
    (206.15, 110.15, 13.69),
    (131.20, 161.20, 9.61),
    (309.69, 94.69, 10.62),
    (356.15, 181.15, 9.69),
    (80.10, 200.10, 9.81),
    (260.99, 200.99, 14.01),
    (19.65, 299.65, 10.70),
    (339.52, 309.52, 10.95),
    (170.14, 280.14, 11.72),
  ];

  @override
  void initState() {
    super.initState();
    final random = Random();
    _controllers = List.generate(_starData.length, (i) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1200 + random.nextInt(1500)),
      );
      Future.delayed(Duration(milliseconds: random.nextInt(2000)), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });

    _animations = _controllers.map((c) =>
      Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      ),
    ).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A006E),
              Color(0xFF3B18B0),
              Color(0xFF7C4FD4),
              Color(0xFFC9B8F0),
              Color(0xFFF0ECFF),
            ],
            stops: [0.0, 0.30, 0.60, 0.85, 1.0],
          ),
        ),
        child: Stack(
          children: [
            ..._starData.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Positioned(
                left: s.$1,
                top: s.$2,
                child: FadeTransition(
                  opacity: _animations[i],
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: s.$3 * 1.5,
                  ),
                ),
              );
            }),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'assets/images/NUSphere_logo2.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A0F5C),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A0F5C),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Jost',
                                color: Color(0xFF1A0F5C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 130,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}