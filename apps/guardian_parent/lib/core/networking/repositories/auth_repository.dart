import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';
import '../interceptors/auth_interceptor.dart';
import '../../storage/secure_storage.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, secureStorage, ref);
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Ref _ref;

  AuthRepository(this._dio, this._secureStorage, this._ref);

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());
    final authResponse = AuthResponse.fromJson(response.data);
    
    await _storeTokens(authResponse);
    _updateAuthInterceptor(authResponse.accessToken);
    
    return authResponse;
  }

  Future<TokenResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    return TokenResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _clearTokens();
    _updateAuthInterceptor(null);
  }

  Future<void> logoutAll() async {
    await _dio.post('/auth/logout-all');
    await _clearTokens();
    _updateAuthInterceptor(null);
  }

  Future<SessionListResponse> getSessions() async {
    final response = await _dio.get('/auth/sessions');
    return SessionListResponse.fromJson(response.data);
  }

  Future<void> revokeSession(String sessionId) async {
    await _dio.delete('/auth/sessions/$sessionId');
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/password/forgot', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post('/auth/password/reset', data: {'token': token, 'password': newPassword});
  }

  Future<void> _storeTokens(AuthResponse response) async {
    await _secureStorage.write(key: SecureStorageKeys.accessToken, value: response.accessToken);
    await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: response.refreshToken);
    await _secureStorage.write(key: SecureStorageKeys.userId, value: response.user.id);
    await _secureStorage.write(key: SecureStorageKeys.familyId, value: response.familyId);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
    await _secureStorage.delete(key: SecureStorageKeys.userId);
    await _secureStorage.delete(key: SecureStorageKeys.familyId);
  }

  void _updateAuthInterceptor(String? token) {
    final authInterceptor = _ref.read(authInterceptorProvider);
    if (token != null) {
      authInterceptor.setAccessToken(token);
    } else {
      authInterceptor.clearAccessToken();
    }
  }

  Future<String?> getStoredAccessToken() async {
    return _secureStorage.read(key: SecureStorageKeys.accessToken);
  }

  Future<String?> getStoredRefreshToken() async {
    return _secureStorage.read(key: SecureStorageKeys.refreshToken);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getStoredAccessToken();
    final refreshToken = await getStoredRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String country;
  final String termsVersion;
  final String privacyVersion;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.country,
    required this.termsVersion,
    required this.privacyVersion,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'country': country,
    'termsVersion': termsVersion,
    'privacyVersion': privacyVersion,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class AuthResponse {
  final User user;
  final String familyId;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.familyId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? json['data']?['user'] ?? {}),
      familyId: json['familyId'] ?? json['data']?['familyId'] ?? '',
      accessToken: json['accessToken'] ?? json['data']?['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? json['data']?['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? json['data']?['expiresIn'] ?? 900,
    );
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? json['data']?['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? json['data']?['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? json['data']?['expiresIn'] ?? 900,
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String country;
  final String timezone;
  final String language;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.country,
    required this.timezone,
    required this.language,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? 'IN',
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      language: json['language'] ?? 'en',
    );
  }
}

class SessionListResponse {
  final List<Session> sessions;

  SessionListResponse({required this.sessions});

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? json['sessions'] as List<dynamic>? ?? [];
    return SessionListResponse(
      sessions: data.map((e) => Session.fromJson(e)).toList(),
    );
  }
}

class Session {
  final String id;
  final String? deviceName;
  final String? devicePlatform;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;
  final DateTime expiresAt;

  Session({
    required this.id,
    this.deviceName,
    this.devicePlatform,
    this.ipAddress,
    required this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
    required this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      deviceName: json['deviceName'],
      devicePlatform: json['devicePlatform'],
      ipAddress: json['ipAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt']) : null,
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt']) : null,
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}