import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../controllers/auth_controller.dart';
import 'api_response.dart';

class BaseClient extends GetConnect {
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  @override
  void onInit() {
    httpClient.baseUrl = AppConfig.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) {
      try {
        final ctrl = Get.find<AuthController>();
        if (ctrl.token.value.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${ctrl.token.value}';
        }
      } catch (_) {}
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      return request;
    });
  }

  // ── Public request methods ──────────────────────────────────────────────────

  Future<ApiResponse<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    T Function(dynamic json)? decoder,
  }) =>
      _withRefresh(() async {
        final r = await get(endpoint, query: query, decoder: decoder);
        return _fromResponse<T>(r, decoder);
      });

  Future<ApiResponse<T>> postRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) =>
      _withRefresh(() async {
        final r = await post(endpoint, body);
        return _fromResponse<T>(r, decoder);
      });

  Future<ApiResponse<T>> patchRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) =>
      _withRefresh(() async {
        final r = await patch(endpoint, body);
        return _fromResponse<T>(r, decoder);
      });

  Future<ApiResponse<T>> putRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) =>
      _withRefresh(() async {
        final r = await put(endpoint, body, decoder: decoder);
        return _fromResponse<T>(r, decoder);
      });

  Future<ApiResponse<T>> deleteRequest<T>(
    String endpoint, {
    T Function(dynamic json)? decoder,
  }) =>
      _withRefresh(() async {
        final r = await delete(endpoint, decoder: decoder);
        return _fromResponse<T>(r, decoder);
      });

  // ── Internal helpers ────────────────────────────────────────────────────────

  ApiResponse<T> _fromResponse<T>(Response r, T Function(dynamic)? decoder) {
    if (r.statusCode == 401) {
      return ApiResponse.failure('Unauthorized', statusCode: 401);
    }
    if (r.hasError) {
      final msg = _extractError(r.body, r.statusText);
      _showErrorSnackbar(r.statusCode, msg);
      return ApiResponse.failure(msg, statusCode: r.statusCode);
    }
    if (r.body == null) return ApiResponse.failure('Пустой ответ от сервера');
    final data = decoder != null ? decoder(r.body) : r.body as T;
    return ApiResponse.success(data);
  }

  /// Выполняет запрос. При 401 пробует обновить токен и повторяет запрос один раз.
  Future<ApiResponse<T>> _withRefresh<T>(
    Future<ApiResponse<T>> Function() request,
  ) async {
    try {
      final result = await request();
      if (result.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return await request();
        } else {
          _forceLogout();
          return ApiResponse.failure('Сессия истекла. Войдите снова.', statusCode: 401);
        }
      }
      return result;
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token') ?? '';
      if (refreshToken.isEmpty) return false;

      final response = await post(
        'auth/token/refresh/',
        {'refresh': refreshToken},
      );
      if (response.statusCode == 200 && response.body != null) {
        final newAccess = response.body['access'] as String?;
        if (newAccess == null || newAccess.isEmpty) return false;

        await prefs.setString('access_token', newAccess);
        try {
          Get.find<AuthController>().token.value = newAccess;
        } catch (_) {}
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _forceLogout() {
    try {
      Get.find<AuthController>().logout();
    } catch (_) {}
    Get.offAllNamed('/');
  }

  void _showErrorSnackbar(int? statusCode, String message) {
    if (statusCode == null) return;
    // 401 обрабатывается через refresh — не показываем snackbar
    if (statusCode == 401) return;

    String title;
    if (statusCode >= 500) {
      title = 'Ошибка сервера ($statusCode)';
    } else if (statusCode == 404) {
      title = 'Не найдено';
    } else if (statusCode == 400) {
      return; // validation errors показываются в UI
    } else {
      title = 'Ошибка ($statusCode)';
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  String _extractError(dynamic body, String? fallback) {
    if (body is Map) {
      if (body['detail'] != null) return body['detail'].toString();
      for (final value in body.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String) return value;
      }
    }
    return fallback ?? 'Неизвестная ошибка';
  }
}
