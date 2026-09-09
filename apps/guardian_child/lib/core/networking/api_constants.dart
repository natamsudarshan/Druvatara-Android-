class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.10:3000/api/v1',
  );

  static const String deviceBaseUrl = String.fromEnvironment(
    'DEVICE_API_BASE_URL',
    defaultValue: 'http://192.168.1.10:3000/device/v1',
  );

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}