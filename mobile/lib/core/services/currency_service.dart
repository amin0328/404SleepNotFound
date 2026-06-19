import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';

class CurrencyService {
  static Map<String, double>? _cachedRates;
  static DateTime? _cachedAt;

  static Future<Map<String, double>> getRates() async {
    if (_cachedRates != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!).inMinutes < 10) {
      return _cachedRates!;
    }

    try {
      final res = await ApiClient.dio.get('/currency/rates');
      final rates = Map<String, double>.from(
        (res.data['rates'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      );
      _cachedRates = rates;
      _cachedAt = DateTime.now();
      return rates;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load exchange rates.';
      throw Exception(message);
    }
  }

  static Future<double?> getRate(String currencyCode) async {
    if (currencyCode.toUpperCase() == 'SGD') return 1.0;
    try {
      final rates = await getRates();
      return rates[currencyCode.toUpperCase()];
    } catch (_) {
      return null;
    }
  }

  static Future<double?> convertFromSgd(double sgdAmount, String targetCurrency) async {
    final rate = await getRate(targetCurrency);
    if (rate == null) return null;
    return sgdAmount * rate;
  }
}