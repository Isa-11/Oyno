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
}
