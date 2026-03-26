class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse.success(this.data)
      : error = null,
        statusCode = 200;

  const ApiResponse.failure(this.error, {this.statusCode}) : data = null;

  bool get isSuccess => error == null;
}
