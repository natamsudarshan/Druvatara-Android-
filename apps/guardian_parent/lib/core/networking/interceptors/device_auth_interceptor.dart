import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
DeviceAuthInterceptor deviceAuthInterceptor(DeviceAuthInterceptorRef ref) {
  return DeviceAuthInterceptor(ref);
}

class DeviceAuthInterceptor extends Interceptor {
  final Ref _ref;
  String? _deviceToken;

  DeviceAuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getDeviceToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Device $token';
    }
    options.headers['X-Request-ID'] = _generateRequestId();
    options.headers['X-Client-Version'] = '1.0.0';
    options.headers['X-Platform'] = 'flutter-child';
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

  String? _getDeviceToken() {
    return _deviceToken;
  }

  Future<void> _handleUnauthorized(DioException err) async {
    _deviceToken = null;
    await _ref.read(secureStorageProvider).delete(key: 'device_token');
  }

  String _generateRequestId() {
    return 'dev_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  void setDeviceToken(String token) {
    _deviceToken = token;
  }

  void clearDeviceToken() {
    _deviceToken = null;
  }
}