import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: 'AES/GCM/NoPadding',
      storageCipherAlgorithm: 'AES/GCM/NoPadding',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    wOptions: WindowsOptions(
      dbName: 'guardian_storage.db',
    ),
  );
}

class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String deviceToken = 'device_token';
  static const String userId = 'user_id';
  static const String familyId = 'family_id';
  static const String deviceId = 'device_id';
  static const String deviceCredentialVersion = 'device_credential_version';
  static const String pairingCode = 'pairing_code';
  static const String biometricEnabled = 'biometric_enabled';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String fcmToken = 'fcm_token';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
}

extension SecureStorageExtensions on FlutterSecureStorage {
  Future<String?> getStringOrNull(String key) async {
    try {
      return await read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    await write(key: key, value: value);
  }

  Future<void> deleteKey(String key) async {
    await delete(key: key);
  }

  Future<bool> hasKey(String key) async {
    return containsKey(key: key);
  }

  Future<void> clearAll() async {
    await deleteAll();
  }
}