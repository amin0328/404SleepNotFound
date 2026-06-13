import 'package:flutter/material.dart';
import 'package:mobile/shared/widgets/app_background.dart';
import 'package:mobile/features/profile/screens/profile_setup6_screen.dart';

class ProfileSetup5Screen extends StatefulWidget {
  final int gradYear;
  final String major;
  final String dorm;
  final String homeCountry;
  final String homeCurrency;

  const ProfileSetup5Screen({
    super.key,
    required this.gradYear,
    required this.major,
    required this.dorm,
    required this.homeCountry,
    required this.homeCurrency,
  });

  @override
  State<ProfileSetup5Screen> createState() => _ProfileSetup5ScreenState();
}

class _ProfileSetup5ScreenState extends State<ProfileSetup5Screen> {
  String _sleep = 'early';
  int _cleanliness = 3;
  String _noise = 'quiet';
  String _social = 'introvert';
  bool _cooking = false;
  String _diet = 'none';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPadding = (screenWidth - 300) / 2;

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          Positioned(
            top: 90, left: 20,
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
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: leftPadding, top: 160),
              child: const Text(
                'Your\nlifestyle.',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                  fontSize: 48,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Padding(
              padding: EdgeInsets.only(left: leftPadding, top: 310),
              child: const Text(
                'Help us find your perfect\nroommate match.',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xff001743),
                  height: 1.3,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.44,
            left: 0, right: 0, bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: leftPadding),
              child: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _LifestyleLabel(label: 'Sleep schedule'),
                    const SizedBox(height: 10),
                    _TwoChipToggle(
                      left: '🌅  Early bird',
                      right: '🌙  Night owl',
                      leftValue: 'early',
                      rightValue: 'late',
                      selected: _sleep,
                      onChanged: (v) => setState(() => _sleep = v),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const _LifestyleLabel(label: 'Cleanliness'),
                        const SizedBox(width: 8),
                        Text(
                          '$_cleanliness / 5',
                          style: const TextStyle(
                            fontFamily: 'Jost',
                            fontSize: 14,
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _CleanlinessRating(
                      value: _cleanliness,
                      onChanged: (v) => setState(() => _cleanliness = v),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Relaxed', style: TextStyle(fontSize: 11, color: Colors.black38, fontFamily: 'Jost')),
                        Text('Very tidy', style: TextStyle(fontSize: 11, color: Colors.black38, fontFamily: 'Jost')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _LifestyleLabel(label: 'Noise level'),
                    const SizedBox(height: 10),
                    _TwoChipToggle(
                      left: '🤫  Quiet',
                      right: '🔊  Lively',
                      leftValue: 'quiet',
                      rightValue: 'loud',
                      selected: _noise,
                      onChanged: (v) => setState(() => _noise = v),
                    ),
                    const SizedBox(height: 20),

                    _LifestyleLabel(label: 'Social style'),
                    const SizedBox(height: 10),
                    _TwoChipToggle(
                      left: '🎧  Introvert',
                      right: '🎉  Extrovert',
                      leftValue: 'introvert',
                      rightValue: 'extrovert',
                      selected: _social,
                      onChanged: (v) => setState(() => _social = v),
                    ),
                    const SizedBox(height: 20),

                    _CookingToggle(
                      value: _cooking,
                      onChanged: (v) => setState(() => _cooking = v),
                    ),
                    const SizedBox(height: 20),

                    _LifestyleLabel(label: 'Dietary preference'),
                    const SizedBox(height: 10),
                    _DietGrid(
                      selected: _diet,
                      onChanged: (v) => setState(() => _diet = v),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003D7C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    final lifestyle = {
      'sleep': _sleep,
      'cleanliness': _cleanliness,
      'noise': _noise,
      'social': _social,
      'cooking': _cooking,
      'diet': _diet,
    };

    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ProfileSetup6Screen(
        gradYear: widget.gradYear,
        major: widget.major,
        dorm: widget.dorm,
        homeCountry: widget.homeCountry,
        homeCurrency: widget.homeCurrency,
        lifestyle: lifestyle,
      ),
    ));
  }
}

class _LifestyleLabel extends StatelessWidget {
  final String label;
  const _LifestyleLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Jost',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xff001743),
      ),
    );
  }
}

class _TwoChipToggle extends StatelessWidget {
  final String left, right, leftValue, rightValue, selected;
  final ValueChanged<String> onChanged;

  const _TwoChipToggle({
    required this.left,
    required this.right,
    required this.leftValue,
    required this.rightValue,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(left, leftValue),
        const SizedBox(width: 8),
        _chip(right, rightValue),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final isActive = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEEDFE) : const Color(0xffE4E4E4),
            border: Border.all(
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xffACACAC),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 14,
                color: isActive ? const Color(0xFF3C3489) : Colors.black54,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CleanlinessRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _CleanlinessRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final isActive = n <= value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
              height: 44,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEEDFE) : const Color(0xffE4E4E4),
                border: Border.all(
                  color: isActive ? const Color(0xFF7C3AED) : const Color(0xffACACAC),
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF3C3489) : Colors.black38,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CookingToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CookingToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xffE4E4E4),
          border: Border.all(color: const Color(0xffACACAC), width: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '🍳  I cook at home',
                style: TextStyle(fontFamily: 'Jost', fontSize: 15),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF7C3AED) : const Color(0xFFBBBBBB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _DietGrid({required this.selected, required this.onChanged});

  static const _options = [
    ('No preference', 'none'),
    ('Halal', 'halal'),
    ('Vegetarian', 'vegetarian'),
    ('Vegan', 'vegan'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _options.map((opt) {
        final isActive = opt.$2 == selected;
        return GestureDetector(
          onTap: () => onChanged(opt.$2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEEEDFE) : const Color(0xffE4E4E4),
              border: Border.all(
                color: isActive ? const Color(0xFF7C3AED) : const Color(0xffACACAC),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                opt.$1,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 13,
                  color: isActive ? const Color(0xFF3C3489) : Colors.black54,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}