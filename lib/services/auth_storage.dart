import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage._();

  static const _secure = FlutterSecureStorage();

  static Future<void> writeSession({
    required String access,
    required String refresh,
    required String username,
  }) async {
    await _secure.write(key: 'access_token', value: access);
    await _secure.write(key: 'refresh_token', value: refresh);
    await _secure.write(key: 'username', value: username);

    // Backward compatibility for older reads.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('username', username);
  }

  static Future<String> readAccessToken() async {
    final token = await _secure.read(key: 'access_token');
    if (token != null && token.isNotEmpty) return token;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  static Future<String> readRefreshToken() async {
    final token = await _secure.read(key: 'refresh_token');
    if (token != null && token.isNotEmpty) return token;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token') ?? '';
  }

  static Future<String> readUsername() async {
    final value = await _secure.read(key: 'username');
    if (value != null && value.isNotEmpty) return value;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Future<void> clearSession() async {
    await _secure.delete(key: 'access_token');
    await _secure.delete(key: 'refresh_token');
    await _secure.delete(key: 'username');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
  }
}
