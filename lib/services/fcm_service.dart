/// Stub service while Firebase is disabled in pubspec/main.
///
/// Replace with real implementation after enabling `firebase_core`
/// and `firebase_messaging` dependencies.
class FcmService {
  static final FcmService _instance = FcmService._();
  FcmService._();
  factory FcmService() => _instance;

  Future<void> init() async {
    return;
  }
}
