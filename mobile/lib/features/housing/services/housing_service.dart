import 'package:mobile/core/api/api_client.dart';
import '../models/listing_model.dart';

class HousingService {
  static Future<List<ListingModel>> getListings({
    String? location,
    String? type,
    int? minPrice,
    int? maxPrice,
  }) async {
    final res = await ApiClient.dio.get('/listings', queryParameters: {
      if (location != null && location != 'All') 'location': location,
      if (type != null) 'type': type,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    });
    return (res.data['listings'] as List)
        .map((json) => ListingModel.fromJson(json))
        .toList();
  }

  static Future<void> saveListing(String id) async {
    await ApiClient.dio.post('/listings/$id/save');
  }

  static Future<void> unsaveListing(String id) async {
    await ApiClient.dio.delete('/listings/$id/save');
  }
}