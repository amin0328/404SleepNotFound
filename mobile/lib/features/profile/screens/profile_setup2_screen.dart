import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/auth_text_field.dart';
import 'package:mobile/shared/widgets/small_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';
import 'package:mobile/features/profile/screens/profile_setup3_screen.dart';

class ProfileSetup2Screen extends StatefulWidget {
  const ProfileSetup2Screen({super.key});
  
  @override
  State<ProfileSetup2Screen> createState() => _ProfileSetup2ScreenState();
}

class _ProfileSetup2ScreenState extends State<ProfileSetup2Screen> {
  final TextEditingController typeController = TextEditingController();
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
                'Anything\nelse?',
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
                'Add a second major, minor,\nor DDP if you have one.',
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
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AuthTextField(
                      controller: typeController,
                      hintText: 'Type',
                    ),
                    SizedBox(height: 16),
                    AuthTextField(
                      controller: facultyController,
                      hintText: 'Faculty',
                    ),
                    SizedBox(height: 16),
                    AuthTextField(
                      controller: majorController,
                      hintText: 'Major',
                    ),
                    SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileSetup3Screen()),
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xff001743),
                            ),
                          ),
                        ),
                        SmallButton(
                          label: "Next",
                          onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileSetup3Screen()),
                    );
                  },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}