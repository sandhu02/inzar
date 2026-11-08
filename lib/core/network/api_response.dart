/// Standard API Response envelope model per Section 2 of FLUTTER_INTEGRATION_GUIDE.md.
/// Resilient to both wrapped envelopes `{"status": true, "data": ...}` and
/// direct JSON payloads returned by FastAPI.
class ApiResponse<T> {
  final bool status;
  final bool success;
  final int statusCode;
  final String? message;
  final T? data;
  final ApiError? error;

  ApiResponse({
    required this.status,
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic json)? fromJsonT, {
    int defaultStatusCode = 200,
  }) {
    if (json is Map<String, dynamic>) {
      final isEnveloped = json.containsKey('status') || json.containsKey('success');

      if (isEnveloped) {
        return ApiResponse<T>(
          status: json['status'] ?? json['success'] ?? false,
          success: json['success'] ?? json['status'] ?? false,
          statusCode: json['status_code'] ?? defaultStatusCode,
          message: json['message'] as String?,
          data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
          error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
        );
      } else {
        // Direct object payload without outer envelope
        return ApiResponse<T>(
          status: true,
          success: true,
          statusCode: defaultStatusCode,
          data: fromJsonT != null ? fromJsonT(json) : null,
        );
      }
    } else if (json is List) {
      // Direct array payload
      return ApiResponse<T>(
        status: true,
        success: true,
        statusCode: defaultStatusCode,
        data: fromJsonT != null ? fromJsonT(json) : null,
      );
    }

    return ApiResponse<T>(
      status: true,
      success: true,
      statusCode: defaultStatusCode,
      data: null,
    );
  }

  bool get isSuccess => (status || success) && error == null;
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic> details;

  ApiError({
    required this.code,
    required this.message,
    this.details = const {},
  });

  factory ApiError.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ApiError(
        code: json['code']?.toString() ?? 'unknown_error',
        message: json['message']?.toString() ?? 'An error occurred',
        details: json['details'] is Map<String, dynamic> ? json['details'] as Map<String, dynamic> : {},
      );
    } else if (json is String) {
      return ApiError(code: 'error', message: json);
    }
    return ApiError(code: 'unknown_error', message: 'An error occurred');
  }

  @override
  String toString() => '[$code] $message';
}

