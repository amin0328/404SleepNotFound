import 'package:flutter/material.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AppBackground(),
          Center(
            child: Image.asset('assets/images/NUSphere_shadow3.png', width: 300,
            ),
          ),
          Positioned(
            bottom: 300,
            child: PrimaryButton(
              label: "Login",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),// login button
          Positioned(
            bottom: 200,
            child: PrimaryButton(
              label: "Register",
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff001743),
              borderColor: const Color(0xff001743),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
            ),
          ),
          Positioned(
            top: 90,
            child: Image.asset(
              'assets/images/stars2.png',
              width: 330,
              fit: BoxFit.fitWidth,)
          )
        ],
      ),
    );
  }
}