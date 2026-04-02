import 'package:get/get.dart';
import 'api_response.dart';
import 'base_client.dart';

class NotificationService extends BaseClient {
  final RxInt unreadCount = 0.obs;

  Future<ApiResponse<List<Map<String, dynamic>>>> getNotifications() =>
      getRequest<List<Map<String, dynamic>>>(
        'notifications/',
        decoder: (json) => (json as List).cast<Map<String, dynamic>>(),
      );

  Future<ApiResponse<void>> markAsRead(int notificationId) =>
      patchRequest<void>(
        'notifications/$notificationId/',
        {'is_read': true},
      );

  Future<ApiResponse<void>> markAllAsRead() =>
      postRequest<void>(
        'notifications/mark-all-read/',
        {},
      );

  void incrementUnread() => unreadCount.value++;
  void decrementUnread() {
    if (unreadCount.value > 0) unreadCount.value--;
  }
  void resetUnread() => unreadCount.value = 0;
}
