import 'package:flutter/material.dart';
import 'package:mobile/core/constants/nus_data.dart';
import 'package:mobile/shared/widgets/small_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';
import 'package:mobile/features/profile/screens/profile_setup3_screen.dart';

class ProfileSetup2Screen extends StatefulWidget {
  final int gradYear;
  final String major;

  const ProfileSetup2Screen({
    super.key,
    required this.gradYear,
    required this.major,
  });

  @override
  State<ProfileSetup2Screen> createState() => _ProfileSetup2ScreenState();
}

class _ProfileSetup2ScreenState extends State<ProfileSetup2Screen> {
  String? selectedType;
  String? selectedFaculty;
  String? selectedMajor;

  final List<String> types = ['Second Major', 'Minor', 'DDP'];

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
              child: Text('Anything\nelse?',
                style: TextStyle(fontFamily: "Jost", fontWeight: FontWeight.w600, fontSize: 48, color: Colors.white, height: 1.1),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 300) / 2, top: 290),
              child: Text('Add a second major, minor,\nor DDP if you have one.',
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      hint: Text('Type', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                      value: selectedType,
                      onChanged: (v) => setState(() => selectedType = v),
                      items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      decoration: _inputDecoration(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfileSetup3Screen(
                              gradYear: widget.gradYear,
                              major: widget.major,
                            ),
                          )),
                          child: Text('Skip', style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xff001743))),
                        ),
                        SmallButton(
                          label: "Next",
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfileSetup3Screen(
                              gradYear: widget.gradYear,
                              major: widget.major,
                            ),
                          )),
                        ),
                      ],
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