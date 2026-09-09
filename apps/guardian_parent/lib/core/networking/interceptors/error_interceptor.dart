import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final error = _mapError(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: error,
      message: error.message,
    ));
  }

  ApiException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          code: 'TIMEOUT',
          message: 'Request timed out. Please check your connection.',
          retryable: true,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          code: 'NETWORK_ERROR',
          message: 'Unable to connect to the server. Please check your internet connection.',
          retryable: true,
        );

      case DioExceptionType.badResponse:
        return _mapHttpError(err);

      case DioExceptionType.cancel:
        return ApiException(
          code: 'CANCELLED',
          message: 'Request was cancelled.',
          retryable: false,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred. Please try again.',
          retryable: true,
        );
    }
  }

  ApiException _mapHttpError(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      final errorData = data['error'] as Map<String, dynamic>?;
      if (errorData != null) {
        return ApiException(
          code: errorData['code'] as String? ?? 'ERROR_$statusCode',
          message: errorData['message'] as String? ?? 'An error occurred',
          retryable: errorData['retryable'] as bool? ?? _isRetryableStatus(statusCode),
          details: errorData['details'] as Map<String, dynamic>?,
        );
      }
    }

    return ApiException(
      code: 'HTTP_$statusCode',
      message: _getDefaultMessage(statusCode),
      retryable: _isRetryableStatus(statusCode),
    );
  }

  bool _isRetryableStatus(int statusCode) {
    return [408, 429, 500, 502, 503, 504].contains(statusCode);
  }

  String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'A conflict occurred. The resource may have been modified.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class ApiException implements Exception {
  final String code;
  final String message;
  final bool retryable;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.code,
    required this.message,
    required this.retryable,
    this.details,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message, retryable: $retryable)';
}