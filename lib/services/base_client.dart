import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'api_response.dart';

class BaseClient extends GetConnect {
  // TODO: вынести в конфиг/env
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/';

  @override
  void onInit() {
    httpClient.baseUrl = apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) {
      try {
        final ctrl = Get.find<AuthController>();
        if (ctrl.token.value.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${ctrl.token.value}';
        }
      } catch (_) {
        // AuthController ещё не зарегистрирован при первом запросе
      }
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (!response.isOk) {
        // ignore: avoid_print
        print('[API ERROR] ${response.statusCode} — ${request.url}');
      }
      return response;
    });
  }

  Future<ApiResponse<T>> getRequest<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final response = await get(endpoint, query: query, decoder: decoder);
      if (response.hasError) {
        return ApiResponse.failure(
          response.statusText ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.success(response.body);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<T>> postRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final response = await post(endpoint, body);
      if (response.hasError) {
        return ApiResponse.failure(
          _extractError(response.body, response.statusText),
          statusCode: response.statusCode,
        );
      }
      if (response.body == null) {
        return ApiResponse.failure('Пустой ответ от сервера');
      }
      // ignore: avoid_print
      print('[API RESPONSE] $endpoint → ${response.body}');
      return ApiResponse.success(
        decoder != null ? decoder(response.body) : response.body,
      );
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  String _extractError(dynamic body, String? fallback) {
    if (body is Map) {
      // {"detail": "..."} — стандартная DRF ошибка
      if (body['detail'] != null) return body['detail'].toString();
      // {"username": ["уже существует"]} — ошибки валидации
      for (final value in body.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String) return value;
      }
    }
    return fallback ?? 'Неизвестная ошибка';
  }

  Future<ApiResponse<T>> patchRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final response = await patch(endpoint, body);
      if (response.hasError) {
        return ApiResponse.failure(
          _extractError(response.body, response.statusText),
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.success(
        decoder != null ? decoder(response.body) : response.body,
      );
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<T>> putRequest<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final response = await put(endpoint, body, decoder: decoder);
      if (response.hasError) {
        return ApiResponse.failure(
          response.statusText ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.success(response.body);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<T>> deleteRequest<T>(
    String endpoint, {
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final response = await delete(endpoint, decoder: decoder);
      if (response.hasError) {
        return ApiResponse.failure(
          response.statusText ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse.success(response.body);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }
}
