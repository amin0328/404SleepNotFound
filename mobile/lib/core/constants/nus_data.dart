import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, String>>> fetchCountries() async {
  final response = await http.get(
    Uri.parse('https://restcountries.com/v3.1/all?fields=name,cca2,currencies'),
  );
  
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    final countries = data.map((c) {
      final name = c['name']['common'] as String;
      final code = c['cca2'] as String;
      final currencies = c['currencies'] as Map?;
      final currency = currencies?.keys.first ?? '';
      return {'name': name, 'code': code, 'currency': currency};
    }).toList();
    
    countries.sort((a, b) => a['name']!.compareTo(b['name']!));
    return List<Map<String, String>>.from(countries);
  }
  throw Exception('Failed to load countries');
}

const Map<String, List<String>> facultyMajors = {
  'FASS': [
    'Not declared yet',
    'Anthropology',
    'Language Studies',
    'Chinese Languages and Cultures',
    'Chinese Studies (Bilingual)',
    'Communications & New Media',
    'Economics',
    'English Language & Linguistics',
    'English Literature',
    'Geography',
    'Global Studies',
    'History',
    'Japanese Studies',
    'Malay Studies',
    'Philosophy',
    'Political Science',
    'Psychology',
    'Social Work',
    'Sociology',
    'South Asian Studies',
    'Southeast Asian Studies',
    'Theatre & Performance Studies',
  ],
  'BIZ': [
    'Not declared yet',
    'Accountancy',
    'Applied Business Analytics',
    'Business Economics',
    'Finance',
    'Innovation and Entrepreneurship',
    'Leadership and Human Capital Management',
    'Marketing',
    'Operations and Supply Chain Management',
    'Real Estate',
  ],
  'CDE': [
    'Not Declared Yet',
    'Architecture',
    'Biomedical Engineering',
    'Chemical Engineering',
    'Civil Engineering',
    'Computer Engineering',
    'Electrical Engineering',
    'Engineering Science',
    'Environmental & Sustainability Engineering',
    'Industrial Design',
    'Industrial & Systems Engineering',
    'Infrastructure & Project Management',
    'Landscape Architecture',
    'Materials Science & Engineering',
    'Mechanical Engineering',
    'Robotics & Machine Intelligence',
  ],
  'Dentistry': [
    'Dentistry (BDS)',
  ],
  'FoS': [
    'Not Declared Yet',
    'Chemistry',
    'Data Science & Analytics',
    'Data Science & Economics',
    'Environmental Studies',
    'Food Science & Technology',
    'Life Sciences',
    'Mathematics',
    'Pharmaceutical Science',
    'Pharmacy',
    'Physics',
    'Quantitative Finance',
    'Statistics',
  ],
  'Law': [
    'Law (LLB)',
  ],
  'Medicine': [
    'Medicine (MBBS)',
  ],
  'Music': [
    'Audio Arts & Sciences',
    'Brass',
    'Composition',
    'Music & Society / Music, Collaboration & Production',
    'Piano',
    'Strings & Harp',
    'Percussion',
    'Voice',
    'Woodwinds',
  ],
  'Nursing': [
    'Nursing',
  ],
  'SCALE': [
    'Not Declared Yet',
    'Information Technology',
    'Technology in Engineering',
    'Certificate Courses',
  ],
  'SoC': [
    'Not Declared Yet',
    'Artificial Intelligence',
    'Business Analytics',
    'Business Artificial Intelligence System',
    'Computer Science',
    'Information Security',
    'GeoSpatial Intelligence',
  ],
};