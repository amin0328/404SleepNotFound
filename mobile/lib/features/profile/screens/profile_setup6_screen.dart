import 'package:flutter/material.dart';
import 'package:mobile/core/auth/auth_service.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';

class ProfileSetup6Screen extends StatefulWidget {
  final int gradYear;
  final String major;
  final String dorm;
  final String homeCountry;
  final String homeCurrency;
  final Map<String, dynamic> lifestyle;

  const ProfileSetup6Screen({
    super.key,
    required this.gradYear,
    required this.major,
    required this.dorm,
    required this.homeCountry,
    required this.homeCurrency,
    required this.lifestyle,
  });

  @override
  State<ProfileSetup6Screen> createState() => _ProfileSetup6ScreenState();
}

class _ProfileSetup6ScreenState extends State<ProfileSetup6Screen> {
  bool isSaving = false;

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      await AuthService.updateProfile({
        'grad_year': widget.gradYear,
        'major': widget.major,
        'dorm': widget.dorm,
        'home_country': widget.homeCountry,
        'home_currency': widget.homeCurrency,
        'lifestyle': widget.lifestyle,
      });
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPadding = (screenWidth - 300) / 2;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Image.asset('assets/images/backbutton.png', width: 50),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: 60),
                  child: const Text(
                    'All set! 🎉',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      fontSize: 48,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: 16),
                  child: const Text(
                    "Your profile is ready.\nLet's get you settled in.",
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xff001743),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(label: 'Finish', onPressed: _saveProfile),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}