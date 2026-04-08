import 'base_client.dart';
import 'api_response.dart';

class AuthUser {
  final int id;
  final String username;
  final String email;

  AuthUser({required this.id, required this.username, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'],
        username: json['username'],
        email: json['email'] ?? '',
      );
}

class AuthResult {
  final AuthUser user;
  final String access;
  final String refresh;

  AuthResult({required this.user, required this.access, required this.refresh});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        user: AuthUser.fromJson(json['user']),
        access: json['access'],
        refresh: json['refresh'],
      );
}

class AuthService extends BaseClient {
  Future<ApiResponse<AuthResult>> register({
    required String username,
    required String email,
    required String password,
  }) =>
      postRequest<AuthResult>(
        'auth/register/',
        {'username': username, 'email': email, 'password': password},
        decoder: (json) => AuthResult.fromJson(json),
      );

  Future<ApiResponse<AuthResult>> login({
    required String username,
    required String password,
  }) =>
      postRequest<AuthResult>(
        'auth/login/',
        {'username': username, 'password': password},
        decoder: (json) => AuthResult.fromJson(json),
      );

  Future<ApiResponse<void>> sendOtp({
    required String phone,
    required String purpose, // 'register' | 'reset'
  }) =>
      postRequest<void>(
        'auth/send-otp/',
        {'phone': phone, 'purpose': purpose},
      );

  Future<ApiResponse<void>> verifyOtp({
    required String phone,
    required String code,
    required String purpose,
  }) =>
      postRequest<void>(
        'auth/verify-otp/',
        {'phone': phone, 'code': code, 'purpose': purpose},
      );

  Future<ApiResponse<AuthResult>> registerPhone({
    required String phone,
    required String code,
    required String username,
    required String password,
  }) =>
      postRequest<AuthResult>(
        'auth/register-phone/',
        {'phone': phone, 'code': code, 'username': username, 'password': password},
        decoder: (json) => AuthResult.fromJson(json),
      );

  Future<ApiResponse<void>> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) =>
      postRequest<void>(
        'auth/reset-password/',
        {'phone': phone, 'code': code, 'new_password': newPassword},
      );
}
