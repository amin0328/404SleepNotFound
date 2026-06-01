import 'package:mobile/core/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/auth_text_field.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppBackground(),
          Positioned(
            top: 90,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/backbutton.png',
                width: 50,
              ),
            )
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(
                left: (MediaQuery.of(context).size.width - 300) / 2, 
                top: 160
              ),
              child: Text(
                'Welcome\nback!',
                style: TextStyle(
                  fontFamily: "Jost",
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: emailController,
                    hintText: 'Enter your NUSNET ID',
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 35),
                PrimaryButton(
                  label: "Login",
                  onPressed: () async {
                    try {
                      await AuthService.login(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed. Check your credentials.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}