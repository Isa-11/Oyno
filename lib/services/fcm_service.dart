import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'base_client.dart';

/// Обрабатывает push-уведомления через Firebase Cloud Messaging.
///
/// Инициализируется в main() после Firebase.initializeApp().
class FcmService extends BaseClient {
  static final FcmService _instance = FcmService._();
  FcmService._();
  factory FcmService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Запрашиваем разрешение (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Отправляем FCM-токен на backend
    final token = await _fcm.getToken();
    if (token != null) await _sendTokenToBackend(token);

    // Обновление токена (токен может меняться)
    _fcm.onTokenRefresh.listen(_sendTokenToBackend);

    // Foreground: уведомления когда приложение открыто
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated: тап по уведомлению открывает приложение
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated: если приложение было убито, проверяем начальное сообщение
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  Future<void> _sendTokenToBackend(String token) async {
    await patchRequest<void>('auth/profile/', {'fcm_token': token});
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    Get.snackbar(
      notification.title ?? 'Oyno',
      notification.body ?? '',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      onTap: (_) => _handleNotificationTap(message),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type == null) return;

    switch (type) {
      case 'game_join':
      case 'game_full':
        // Переходим на экран игр (таб 1)
        if (id != null) {
          Get.toNamed('/game/$id');
        }
        break;
      case 'message':
        // Переходим в чат
        if (id != null) {
          Get.toNamed('/chat/$id');
        }
        break;
      case 'booking':
        // Переходим на экран бронирований
        Get.toNamed('/bookings');
        break;
    }
  }
}
