import 'package:flutter/material.dart';
import 'package:mobile/core/auth/auth_service.dart';
import 'package:mobile/features/profile/screens/profile_setup1_screen.dart';
import 'package:mobile/shared/widgets/auth_text_field.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nusnetIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AppBackground(),
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
              child: const Text(
                'Registration',
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
            top: MediaQuery.of(context).size.height * 0.32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: fullNameController,
                    hintText: 'Full name',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: nusnetIdController,
                    hintText: 'NUSNET ID (e.g. e0123456)',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 35),
                _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: "Register",
                      onPressed: signUp,
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    final nusnetId = nusnetIdController.text.trim().toLowerCase();
    final email = '$nusnetId@u.nus.edu';

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        nusnetId: nusnetId,
        name: fullNameController.text.trim(),
        email: email,
        password: passwordController.text.trim(),
      );
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetup1Screen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}