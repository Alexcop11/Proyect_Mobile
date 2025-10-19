class Api_Constants {
  static const String Url = "http://localhost:8000/api";
  static const String LoginPoint = "http://localhost:8000/api/auth/login";
  static const String RegisterPoint = "http://localhost:8000/api/auth/register";
  static const Duration timeout = Duration(seconds: 10);
}

class StorageKeys {
  static const String token = "auth_token";
  static const String userData = "user_data";
}
