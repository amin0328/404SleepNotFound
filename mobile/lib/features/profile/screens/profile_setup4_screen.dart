import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/auth/auth_service.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/app_background.dart';

class ProfileSetup4Screen extends StatefulWidget {
  final int gradYear;
  final String major;
  final String dorm;

  const ProfileSetup4Screen({
    super.key,
    required this.gradYear,
    required this.major,
    required this.dorm,
  });

  @override
  State<ProfileSetup4Screen> createState() => _ProfileSetup4ScreenState();
}

class _ProfileSetup4ScreenState extends State<ProfileSetup4Screen> {
  List<Map<String, String>> countries = [];
  bool isLoading = true;
  bool isSaving = false;
  String? selectedCountryCode;
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final String data = await rootBundle.loadString('assets/countries.json');
      final List raw = jsonDecode(data);
      final parsed = raw
          .where((c) => c['currencies'] != null && (c['currencies'] as Map).isNotEmpty)
          .map((c) {
            final name = c['name']['common'] as String;
            final code = c['cca2'] as String;
            final currencies = c['currencies'] as Map;
            final currency = currencies.keys.first as String;
            return {'name': name, 'code': code, 'currency': currency};
          }).toList();
      parsed.sort((a, b) => a['name']!.compareTo(b['name']!));
      setState(() {
        countries = List<Map<String, String>>.from(parsed);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<String> get currencyList {
    final list = countries.map((c) => c['currency']!).toSet().where((c) => c.isNotEmpty).toList();
    list.sort();
    return list;
  }

  Future<void> _saveProfile() async {
    if (selectedCountryCode == null || selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your nationality and currency.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await AuthService.updateProfile({
        'grad_year': widget.gradYear,
        'major': widget.major,
        'dorm': widget.dorm,
        'home_country': selectedCountryCode,
        'home_currency': selectedCurrency,
      });

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile. Please try again.')),
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
          AppBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    onPressed: () => Navigator.pop(context),
                    child: Image.asset('assets/images/backbutton.png', width: 50),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: 40),
                  child: Text('Almost\nDone.',
                    style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 48, color: Colors.white, height: 1.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: 12),
                  child: Text("We'd love to know where\nyou call home.",
                    style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 20, color: Color(0xff001743), height: 1.3),
                  ),
                ),
                SizedBox(height: 40),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            hint: Text('Nationality', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                            value: selectedCountryCode,
                            onChanged: (v) {
                              final country = countries.firstWhere((c) => c['code'] == v);
                              setState(() {
                                selectedCountryCode = v;
                                selectedCurrency = country['currency'];
                              });
                            },
                            items: countries.map((c) => DropdownMenuItem(value: c['code'], child: Text(c['name']!))).toList(),
                            decoration: _inputDecoration(),
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            hint: Text('Home Currency', style: TextStyle(fontFamily: 'Jost', fontSize: 18, color: Colors.grey)),
                            value: selectedCurrency,
                            onChanged: (v) => setState(() => selectedCurrency = v),
                            items: currencyList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            decoration: _inputDecoration(),
                          ),
                          SizedBox(height: 35),
                          isSaving
                            ? CircularProgressIndicator()
                            : PrimaryButton(label: 'Finish', onPressed: _saveProfile),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true, fillColor: Color(0xffE4E4E4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xffACACAC), width: 0.3)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    );
  }
}