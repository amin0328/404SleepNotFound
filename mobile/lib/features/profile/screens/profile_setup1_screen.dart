import 'package:flutter/material.dart';
import 'package:mobile/core/constants/nus_data.dart';
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
  String? selectedFaculty;
  String? selectedMajor;

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Color(0xffE4E4E4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          AppBackground(),
          Positioned(
            top: 90, left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              onPressed: () => Navigator.pop(context),
              child: Image.asset('assets/images/backbutton.png', width: 50),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 300) / 2, top: 160),
              child: Text('Glad to\nmeet you!',
                style: TextStyle(fontFamily: "Jost", fontWeight: FontWeight.w600, fontSize: 48, color: Colors.white, height: 1.1),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 300) / 2, top: 290),
              child: Text('Tell us a bit about yourself.',
                style: TextStyle(fontFamily: "Jost", fontWeight: FontWeight.w600, fontSize: 24, color: Color(0xff001743), height: 1.1),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32 + 72 + 16,
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthTextField(
                      controller: gradYearController,
                      hintText: 'Graduating Year (e.g. 2028)',
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      menuMaxHeight: 300,
                      hint: Text('Faculty', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                      value: selectedFaculty,
                      onChanged: (v) => setState(() {
                        selectedFaculty = v;
                        selectedMajor = null;
                      }),
                      items: facultyMajors.keys.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      decoration: _inputDecoration(),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      menuMaxHeight: 300,
                      hint: Text('Major', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                      value: selectedMajor,
                      onChanged: selectedFaculty == null ? null : (v) => setState(() => selectedMajor = v),
                      items: (selectedFaculty != null ? facultyMajors[selectedFaculty]! : <String>[])
                          .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      decoration: _inputDecoration(),
                    ),
                    SizedBox(height: 35),
                    PrimaryButton(
                      label: "Next",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileSetup2Screen(
                            gradYear: int.tryParse(gradYearController.text.trim()) ?? 0,
                            major: selectedMajor ?? '',
                          )),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}