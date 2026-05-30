import '../../core/api/api_client.dart';

class NotificationService {
  final _client = ApiClient();

  /// GET /api/notifications
  Future<List<dynamic>> getNotifications() async {
    final res = await _client.dio.get('/notifications');
    return res.data['data'] as List;
  }

  /// GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    final res = await _client.dio.get('/notifications/unread-count');
    return res.data['data']['unread_count'] as int;
  }

  /// PATCH /api/notifications/:id/read
  Future<void> markAsRead(int id) async {
    await _client.dio.patch('/notifications/$id/read');
  }

  /// PATCH /api/notifications/read-all
  Future<void> markAllAsRead() async {
    await _client.dio.patch('/notifications/read-all');
  }
}
