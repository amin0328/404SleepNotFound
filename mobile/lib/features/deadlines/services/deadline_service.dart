import 'package:mobile/core/api/api_client.dart';
import '../models/deadline_model.dart';

class DeadlineService {
  static Future<List<DeadlineModel>> getDeadlines() async {
    final res = await ApiClient.dio.get('/deadlines');
    return (res.data['deadlines'] as List)
        .map((json) => DeadlineModel.fromJson(json))
        .toList();
  }

  static Future<DeadlineModel> createDeadline(DeadlineModel deadline) async {
    final res = await ApiClient.dio.post('/deadlines', data: deadline.toJson());
    return DeadlineModel.fromJson(res.data['deadline']);
  }

  static Future<DeadlineModel> updateDeadline(DeadlineModel deadline) async {
    final res = await ApiClient.dio.patch('/deadlines/${deadline.id}', data: deadline.toJson());
    return DeadlineModel.fromJson(res.data['deadline']);
  }

  static Future<void> deleteDeadline(String id) async {
    await ApiClient.dio.delete('/deadlines/$id');
  }
}