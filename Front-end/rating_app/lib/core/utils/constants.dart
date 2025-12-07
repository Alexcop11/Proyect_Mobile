

class Api_Constants {
  static const String url = "http://192.168.1.72:8000/api";
  static const String loginPoint = 'http://192.168.1.72:8000/api/auth/login';
  static const String registerPoint = 'http://192.168.1.72:8000/api/auth/register';
  static const String userPoint = 'http://192.168.1.72:8000/api/users/email/';
  static const String restaurantPoint = 'http://192.168.1.72:8000/api/restaurants/';
  static const String restaurantOwnerPoint = 'http://192.168.1.72:8000/api/restaurants/owner/';
  static const String favoritePoint = 'http://192.168.1.72:8000/api/favorites/';
  static const String ratingsPoint = 'http://192.168.1.72:8000/api/ratings/';
  static const String photosPoint = '/photos/';
  static const String tokenNotification = 'http://192.168.1.72:8000/api/users/push-token';
  static const String pushNotification = 'http://192.168.1.72:8000/api/notifications/send';
  static const String notificationPoint = 'http://192.168.1.72:8000/api/notifications/';

  static const Duration timeout = Duration(seconds: 10);
}

class StorageKeys {
  static const String token = "auth_token";
  static const String role = "auth_role";
  static const String email = "auth_email";
  static const String userEmail = 'user_email';      
  static const String userRole = 'user_role';
}