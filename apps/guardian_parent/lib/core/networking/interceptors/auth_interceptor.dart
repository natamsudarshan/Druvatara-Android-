import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../storage/secure_storage.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
AuthInterceptor authInterceptor(AuthInterceptorRef ref) {
  return AuthInterceptor(ref);
}

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  String? _accessToken;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Request-ID'] = _generateRequestId();
    options.headers['X-Client-Version'] = '1.0.0';
    options.headers['X-Platform'] = 'flutter-parent';
    options.headers['X-Timezone'] = DateTime.now().timeZoneName;
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleUnauthorized(err);
    }
    super.onError(err, handler);
  }

  String? _getAccessToken() {
    return _accessToken;
  }

  Future<void> _handleUnauthorized(DioException err) async {
    // Token refresh logic would go here
    // For now, just clear the token
    _accessToken = null;
    await _ref.read(secureStorageProvider).delete(key: 'access_token');
  }

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }
}