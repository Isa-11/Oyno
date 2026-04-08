import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const _secure = FlutterSecureStorage();

  static Future<void> writeSession({
    required String access,
    required String refresh,
    required String username,
    int userId = 0,
  }) async {
    await _secure.write(key: 'access_token', value: access);
    await _secure.write(key: 'refresh_token', value: refresh);
    await _secure.write(key: 'username', value: username);
    await _secure.write(key: 'user_id', value: userId.toString());
  }

  static Future<String> readAccessToken() async {
    return await _secure.read(key: 'access_token') ?? '';
  }

  static Future<String> readRefreshToken() async {
    return await _secure.read(key: 'refresh_token') ?? '';
  }

  static Future<String> readUsername() async {
    return await _secure.read(key: 'username') ?? '';
  }

  static Future<int> readUserId() async {
    final value = await _secure.read(key: 'user_id');
    return int.tryParse(value ?? '') ?? 0;
  }

  static Future<void> clearSession() async {
    await _secure.delete(key: 'access_token');
    await _secure.delete(key: 'refresh_token');
    await _secure.delete(key: 'username');
    await _secure.delete(key: 'user_id');
  }
}
