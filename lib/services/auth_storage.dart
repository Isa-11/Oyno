import 'package:shared_preferences/shared_preferences.dart';

// flutter_secure_storage removed — its Keystore I/O blocks the Android main
// thread even with encryptedSharedPreferences:true, causing ANR dialogs.
// SharedPreferences is async-safe and sufficient for JWT tokens on-device.
class AuthStorage {
  AuthStorage._();

  static Future<void> writeSession({
    required String access,
    required String refresh,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('username', username);
  }

  static Future<String> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  static Future<String> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token') ?? '';
  }

  static Future<String> readUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
  }
}
