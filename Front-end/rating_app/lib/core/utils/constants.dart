class Api_Constants {
  static const String url = "http://192.168.109.226:8000/api";
  static const String loginPoint = '/auth/login';
  static const String registerPoint = '/auth/register';
  static const Duration timeout = Duration(seconds: 10);
}

class StorageKeys {
  static const String token = "auth_token";
}
