import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
    headers: ApiConstants.defaultHeaders,
  ));

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(ref),
    ErrorInterceptor(),
  ]);

  if (const bool.fromEnvironment('DEBUG', defaultValue: true)) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  return dio;
});

final deviceDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.deviceBaseUrl,
    connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
    headers: ApiConstants.defaultHeaders,
  ));

  dio.interceptors.addAll([
    LoggingInterceptor(),
    DeviceAuthInterceptor(ref),
    ErrorInterceptor(),
  ]);

  if (const bool.fromEnvironment('DEBUG', defaultValue: true)) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  return dio;
});