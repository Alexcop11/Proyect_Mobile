class Api_Constants {
  static const String url = "http://192.168.105.198:8000/api";
  static const String loginPoint = 'http://192.168.105.198:8000/api/auth/login';
  static const String registerPoint = 'http://192.168.105.198:8000/api/auth/register';
  static const String userPoint = 'http://192.168.105.198:8000/api/users/email/';
  static const String restaurantPoint = 'http://192.168.105.198:8000/api/restaurants/';
  static const String restaurantOwnerPoint = 'http://192.168.105.198:8000/api/restaurants/owner/';
  static const Duration timeout = Duration(seconds: 10);
}

class StorageKeys {
  static const String token = "auth_token";
  static const String role = "auth_role";
  static const String email = "auth_email";
}

