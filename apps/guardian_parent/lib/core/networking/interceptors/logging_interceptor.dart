import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 2,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('🚀 REQUEST[${options.method}] ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('✅ RESPONSE[${response.statusCode}] ${response.requestOptions.uri}');
    _logger.d('Response: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('❌ ERROR[${err.response?.statusCode ?? 'N/A'}] ${err.requestOptions.uri}');
    _logger.e('Error: ${err.message}');
    if (err.response?.data != null) {
      _logger.d('Error Response: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}