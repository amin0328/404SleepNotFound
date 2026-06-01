import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';
import 'package:mobile/features/profile/screens/profile_setup4_screen.dart';

class ProfileSetup3Screen extends StatefulWidget {
  final int gradYear;
  final String major;

  const ProfileSetup3Screen({
    super.key,
    required this.gradYear,
    required this.major,
  });

  @override
  State<ProfileSetup3Screen> createState() => _ProfileSetup3ScreenState();
}

class _ProfileSetup3ScreenState extends State<ProfileSetup3Screen> {
  String? selectedHousing;
  String? selectedDorm;

  final List<String> dorms = [
    'PGPR', 'Helix House', 'LightHouse', 'Pioneer House', 'Valour House',
    'UTown Residence', 'NUS College', 'Acacia College', 'CAPT', 'Tembusu College',
    'RC4', 'RVRC', 'Sheares Hall', 'Kent Ridge Hall', 'King Edward VII Hall',
    'Eusoff Hall', 'Raffles Hall', 'Temasek Hall',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final leftPadding = (screenWidth - 300) / 2;

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
            height: screenHeight * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: leftPadding, top: 160),
              child: Text('Got a place\nto stay?',
                style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 48, color: Colors.white, height: 1.1),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: screenHeight * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: leftPadding, top: 290),
              child: Text("Let us know where you're\nliving in Singapore.",
                style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 20, color: Color(0xff001743), height: 1.3),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.32 + 72 + 16,
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => selectedHousing = 'on-campus'),
                          child: Text('On-campus',
                            style: TextStyle(fontFamily: 'Jost', fontSize: 18,
                              fontWeight: selectedHousing == 'on-campus' ? FontWeight.w700 : FontWeight.w400,
                              color: selectedHousing == 'on-campus' ? Color(0xff001743) : Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() { selectedHousing = 'off-campus'; selectedDorm = null; }),
                          child: Text('Off-campus',
                            style: TextStyle(fontFamily: 'Jost', fontSize: 18,
                              fontWeight: selectedHousing == 'off-campus' ? FontWeight.w700 : FontWeight.w400,
                              color: selectedHousing == 'off-campus' ? Color(0xff001743) : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (selectedHousing == 'on-campus')
                      DropdownButtonFormField<String>(
                        hint: Text('Hostel', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                        value: selectedDorm,
                        onChanged: (v) => setState(() => selectedDorm = v),
                        items: dorms.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        decoration: InputDecoration(
                          filled: true, fillColor: Color(0xffE4E4E4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        ),
                      ),
                    SizedBox(height: 35),
                    PrimaryButton(
                      label: 'Next',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ProfileSetup4Screen(
                          gradYear: widget.gradYear,
                          major: widget.major,
                          dorm: selectedDorm ?? 'Off-campus',
                        ),
                      )),
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