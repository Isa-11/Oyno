/// Централизованный конфиг URL.
///
/// Для разработки поменяй [_devApiBase] на IP своего компьютера в локальной сети.
/// Для production поменяй [_prodApiBase] на свой домен.
///
/// Переключение dev/prod: измени [_isProd] на true перед сборкой релиза.
class AppConfig {
  AppConfig._();

  /// true  → production-сервер
  /// false → локальный dev-сервер
  static const bool _isProd = false;

  // ── Dev (локальная сеть) ───────────────────────────────────────────────────
  // Замени на IP своего ПК: Settings → Wi-Fi → свойства сети
  // Android-эмулятор: используй 10.0.2.2 вместо 127.0.0.1
  static const String _devHost = '192.168.1.100'; // ← поменяй на свой IP
  static const String _devApiBase = 'http://$_devHost:8000/api/';
  static const String _devWsBase  = 'ws://$_devHost:8000/ws/';

  // ── Production ─────────────────────────────────────────────────────────────
  static const String _prodApiBase = 'https://yourdomain.com/api/'; // ← домен
  static const String _prodWsBase  = 'wss://yourdomain.com/ws/';

  // ── Публичные геттеры ──────────────────────────────────────────────────────
  static String get apiBaseUrl => _isProd ? _prodApiBase : _devApiBase;
  static String get wsBaseUrl  => _isProd ? _prodWsBase  : _devWsBase;
}
