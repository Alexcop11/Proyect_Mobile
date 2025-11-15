class Api_Constants {
  static const String url = "http://192.168.0.11:8000/api";
  static const String loginPoint = 'http://192.168.0.11:8000/api/auth/login';
  static const String registerPoint = 'http://192.168.0.11:8000/api/auth/register';
  static const Duration timeout = Duration(seconds: 10);
}

class StorageKeys {
  static const String token = "auth_token";
}
