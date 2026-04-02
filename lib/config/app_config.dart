/// Централизованный конфиг URL.
///
/// Dev: используй adb reverse tcp:8000 tcp:8000 (USB) → host = 127.0.0.1
///      Или пропиши IP своего ПК в локальной сети (Settings → Wi-Fi)
/// Prod: поменяй [_prodHost] на свой домен и [_isProd] на true
class AppConfig {
  AppConfig._();

  /// true  → production-сервер
  /// false → локальный dev-сервер
  static const bool _isProd = false;

  // ── Dev ───────────────────────────────────────────────────────────────────
  // USB (adb reverse tcp:8000 tcp:8000): 127.0.0.1
  // Wi-Fi (та же сеть):                 твой IP, например 192.168.1.100
  static const String _devHost = '127.0.0.1';
  static const int    _devPort = 8000;

  // ── Production ────────────────────────────────────────────────────────────
  static const String _prodHost = 'yourdomain.com'; // ← сюда домен

  // ── Публичные геттеры ─────────────────────────────────────────────────────
  static String get apiBaseUrl => _isProd
      ? 'https://$_prodHost/api/'
      : 'http://$_devHost:$_devPort/api/';

  static String get wsBaseUrl => _isProd
      ? 'wss://$_prodHost/ws/'
      : 'ws://$_devHost:$_devPort/ws/';
}
