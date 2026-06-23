import 'dart:convert';
import 'package:flutter/services.dart';

typedef CountryEntry = Map<String, String>;

Future<List<CountryEntry>> loadCountries() async {
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
      })
      .toList();
  parsed.sort((a, b) => a['name']!.compareTo(b['name']!));
  return List<CountryEntry>.from(parsed);
}

String? currencyForCountryName(List<CountryEntry> countries, String? countryName) {
  if (countryName == null || countryName.isEmpty) return null;
  for (final c in countries) {
    if (c['name'] == countryName) return c['currency'];
  }
  return null;
}