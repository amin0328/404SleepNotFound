import 'dart:io';
import 'package:dio/dio.dart';
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
      if (location != null && location != 'All') 'region': location,
      if (type != null) 'type': type,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    });
    return (res.data['listings'] as List)
        .map((json) => ListingModel.fromJson(json))
        .toList();
  }

  static Future<List<ListingModel>> getSavedListings() async {
    try {
      final res = await ApiClient.dio.get('/listings/saved');
      return (res.data['listings'] as List)
          .map((json) => ListingModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load saved listings.';
      throw Exception(message);
    }
  }

  static Future<ListingModel> getListingById(String id) async {
    try {
      final res = await ApiClient.dio.get('/listings/$id');
      return ListingModel.fromJson(res.data['listing']);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load listing.';
      throw Exception(message);
    }
  }

  /// Uploads an image file to the backend, which forwards it to Supabase
  /// Storage and returns a public URL. Call this BEFORE createListing if
  /// the user attached a photo.
  static Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });
      final res = await ApiClient.dio.post('/listings/upload-image', data: formData);
      return res.data['image_url'] as String;
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to upload image.';
      throw Exception(message);
    }
  }

  static Future<ListingModel> createListing({
    required String title,
    required double priceSgd,
    required String location,
    required String type,
    String? room,
    int? leaseMonths,
    String? url,
    String? availableFrom,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final res = await ApiClient.dio.post('/listings', data: {
        'title': title,
        'price_sgd': priceSgd,
        'location': location,
        'type': type,
        if (room != null) 'room': room,
        if (leaseMonths != null) 'lease_months': leaseMonths,
        if (url != null) 'url': url,
        if (availableFrom != null) 'available_from': availableFrom,
        if (notes != null) 'notes': notes,
        if (imageUrl != null) 'image_url': imageUrl,
      });
      return ListingModel.fromJson(res.data['listing']);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to create listing.';
      throw Exception(message);
    }
  }

  static Future<void> deleteListing(String id) async {
    try {
      await ApiClient.dio.delete('/listings/$id');
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to delete listing.';
      throw Exception(message);
    }
  }

  static Future<void> saveListing(String id) async {
    await ApiClient.dio.post('/listings/$id/save');
  }

  static Future<void> unsaveListing(String id) async {
    await ApiClient.dio.delete('/listings/$id/save');
  }
}