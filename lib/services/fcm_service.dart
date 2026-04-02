import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

/// Firebase Cloud Messaging service для push-уведомлений
/// 
/// Требует:
/// 1. google-services.json в android/app/
/// 2. Включенные зависимости в pubspec.yaml (firebase_core, firebase_messaging)
class FcmService {
  static final FcmService _instance = FcmService._();
  FcmService._();
  factory FcmService() => _instance;

  Future<void> init() async {
    try {
      // Инициализируем Firebase
      await Firebase.initializeApp();
      
      // Запрашиваем permission на уведомления
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carefullyProvisioned: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[FCM] User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('[FCM] Provisional notification permission granted');
      } else {
        print('[FCM] User declined or has not yet granted notification permission');
      }

      // Получаем FCM token
      final token = await FirebaseMessaging.instance.getToken();
      print('[FCM] Token: $token');

      // Обработчик сообщений в foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Обработчик при клике на уведомление
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Обработчик при холодном старте (notification открыт)
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Background handler (для Android)
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    } catch (e) {
      print('[FCM] Init error: $e');
    }
  }

  /// Обработчик foreground сообщений
  void _handleForegroundMessage(RemoteMessage message) {
    print('[FCM] Foreground message: ${message.messageId}');
    print('[FCM] Data: ${message.data}');

    if (message.notification != null) {
      final title = message.notification!.title ?? 'Oyno Sports';
      final body = message.notification!.body ?? '';
      
      // Увеличиваем counter уведомлений
      try {
        Get.find<NotificationService>().incrementUnread();
      } catch (e) {
        print('[FCM] NotificationService not found: $e');
      }

      // Показываем snackbar
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Обработчик клика на уведомление
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('[FCM] Message opened: ${message.messageId}');
    print('[FCM] Data: ${message.data}');

    // Здесь можно обработать deep linking
    // Например, открыть specific game или chat
    final data = message.data;
    
    if (data['type'] == 'game' && data['game_id'] != null) {
      // Get.to(() => GameDetailScreen(gameId: int.parse(data['game_id']!)));
    } else if (data['type'] == 'chat' && data['chat_id'] != null) {
      // Get.to(() => ChatDetailScreen(chatId: int.parse(data['chat_id']!)));
    }
  }

  /// Обработчик background сообщений (статический для Android)
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    print('[FCM] Background message: ${message.messageId}');
    print('[FCM] Data: ${message.data}');
  }
}

