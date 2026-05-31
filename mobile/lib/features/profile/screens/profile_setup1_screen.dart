import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/auth_text_field.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';
import 'package:mobile/features/profile/screens/profile_setup2_screen.dart';

class ProfileSetup1Screen extends StatefulWidget {
  const ProfileSetup1Screen({super.key});
  
  @override
  State<ProfileSetup1Screen> createState() => _ProfileSetup1ScreenState();
}

class _ProfileSetup1ScreenState extends State<ProfileSetup1Screen> {
  final TextEditingController gradYearController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

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
                'Glad to\nmeet you!',
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
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(
                left: (MediaQuery.of(context).size.width - 300) / 2, 
                top: 290
              ),
              child: Text(
                'Tell us a bit about yourself.',
                style: TextStyle(
                  fontFamily: "Jost",
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Color(0xff001743),
                  height: 1.1,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32 + 72 + 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: gradYearController,
                    hintText: 'Graduating Year (e.g. 2028)',
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: facultyController,
                    hintText: 'Faculty',
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: AuthTextField(
                    controller: majorController,
                    hintText: 'Major',
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 35),
                PrimaryButton(
                  label: "Next",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileSetup2Screen()),
                    );
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