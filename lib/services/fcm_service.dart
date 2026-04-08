// Firebase временно отключён (нет google-services.json)
// ignore_for_file: unused_import

/// Firebase Cloud Messaging service (заглушка без Firebase)
class FcmService {
  static final FcmService _instance = FcmService._();
  FcmService._();
  factory FcmService() => _instance;

  Future<void> init() async {
    // Firebase не настроен — пропускаем инициализацию
    print('[FCM] Firebase disabled (no google-services.json)');
  }
}

