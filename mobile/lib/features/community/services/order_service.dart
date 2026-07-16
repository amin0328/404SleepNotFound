import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';

class OrderService {
  static Future<List<Map<String, dynamic>>> getOrders({String? status, String? search}) async {
    try {
      final res = await ApiClient.dio.get('/orders', queryParameters: {
        if (status != null && status != 'all') 'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      });
      return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load orders.';
      throw Exception(message);
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      await ApiClient.dio.delete('/orders/$orderId');
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to delete order.';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String store,
    required String country,
    required String category,
    required String orderName,
    required int minParticipants,
    required String deadline,
    required String pickupSpot,
    required double shippingCostSgd,
  }) async {
    try {
      final res = await ApiClient.dio.post('/orders', data: {
        'store': store,
        'country': country,
        'category': category,
        'order_name': orderName,
        'min_participants': minParticipants,
        'deadline': deadline,
        'pickup_spot': pickupSpot,
        'shipping_cost_sgd': shippingCostSgd,
      });
      return res.data['order'];
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to create order.';
      throw Exception(message);
    }
  }

  static Future<void> joinOrder(String orderId, List<Map<String, dynamic>> items) async {
    try {
      await ApiClient.dio.post('/orders/$orderId/join', data: {'items': items});
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to join order.';
      throw Exception(message);
    }
  }

  static Future<void> leaveOrder(String orderId) async {
    try {
      await ApiClient.dio.post('/orders/$orderId/leave');
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to leave order.';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> updateStatus(String orderId, String status, {String? trackingNumber}) async {
    try {
      final res = await ApiClient.dio.patch('/orders/$orderId/status', data: {
        'status': status,
        if (trackingNumber != null) 'tracking_number': trackingNumber,
      });
      return res.data['order'];
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to update order status.';
      throw Exception(message);
    }
  }

  static Future<List<Map<String, dynamic>>> getCostSplit(String orderId) async {
    try {
      final res = await ApiClient.dio.get('/orders/$orderId/split');
      return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Failed to load cost split.';
      throw Exception(message);
    }
  }
}