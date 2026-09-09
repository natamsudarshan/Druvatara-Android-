import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated({
    required User user,
    required String accessToken,
    required String refreshToken,
    required String familyId,
  }) = Authenticated;

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.loading() = Loading;

  const factory AuthState.error(String message) = Error;
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required String country,
    required String timezone,
    required String language,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkStoredAuth();
    return const AuthState.loading();
  }

  Future<void> _checkStoredAuth() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final hasTokens = await authRepo.hasValidTokens();
      
      if (hasTokens) {
        final accessToken = await authRepo.getStoredAccessToken();
        final refreshToken = await authRepo.getStoredRefreshToken();
        final userId = await ref.read(secureStorageProvider).read(key: SecureStorageKeys.userId);
        final familyId = await ref.read(secureStorageProvider).read(key: SecureStorageKeys.familyId);
        
        if (accessToken != null && refreshToken != null && userId != null && familyId != null) {
          // Fetch current user profile
          final user = await _fetchUserProfile(authRepo, accessToken);
          if (user != null) {
            state = AuthState.authenticated(
              user: user,
              accessToken: accessToken,
              refreshToken: refreshToken,
              familyId: familyId,
            );
            return;
          }
        }
      }
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<User?> _fetchUserProfile(AuthRepository authRepo, String accessToken) async {
    try {
      // The authRepo doesn't have a direct getProfile method, but we can use the stored user data
      // For now, create a minimal user object - in real app you'd call an API
      final userId = await ref.read(secureStorageProvider).read(key: SecureStorageKeys.userId);
      if (userId != null) {
        return User(
          id: userId,
          email: '',
          name: '',
          country: 'IN',
          timezone: 'Asia/Kolkata',
          language: 'en',
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.login(LoginRequest(email: email, password: password));
      
      final user = User(
        id: response.user.id,
        email: response.user.email,
        name: response.user.name,
        country: response.user.country,
        timezone: response.user.timezone,
        language: response.user.language,
      );
      
      state = AuthState.authenticated(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        familyId: response.familyId,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String country,
    required String termsVersion,
    required String privacyVersion,
  }) async {
    state = const AuthState.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.register(RegisterRequest(
        name: name,
        email: email,
        password: password,
        country: country,
        termsVersion: termsVersion,
        privacyVersion: privacyVersion,
      ));
      
      final user = User(
        id: response.user.id,
        email: response.user.email,
        name: response.user.name,
        country: response.user.country,
        timezone: response.user.timezone,
        language: response.user.language,
      );
      
      state = AuthState.authenticated(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        familyId: response.familyId,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = const AuthState.unauthenticated();
  }

  Future<void> logoutAll() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logoutAll();
    state = const AuthState.unauthenticated();
  }

  Future<void> refreshToken() async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.refreshToken(currentState.refreshToken);
      
      state = AuthState.authenticated(
        user: currentState.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        familyId: currentState.familyId,
      );
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.forgotPassword(email);
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.resetPassword(token, newPassword);
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
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