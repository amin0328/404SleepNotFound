import 'package:mobile/core/api/api_client.dart';
import '../models/deadline_model.dart';
import '../models/nus_calendar_event.dart';

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

  static Future<List<NusCalendarEvent>> getNusCalendar({String? category, String? semester}) async {
    final res = await ApiClient.dio.get('/deadlines/nus-calendar', queryParameters: {
      if (category != null && category != 'all') 'category': category,
      if (semester != null && semester != 'all') 'semester': semester,
    });
    return (res.data['data'] as List)
        .map((json) => NusCalendarEvent.fromJson(json))
        .toList();
  }

  static Future<DeadlineModel> importNusDeadline(String eventId) async {
    final res = await ApiClient.dio.post('/deadlines/nus-calendar/$eventId/import');
    // This endpoint returns the deadline object directly, unlike createDeadline
    // which wraps it as { deadline: ... }.
    return DeadlineModel.fromJson(res.data);
  }
}