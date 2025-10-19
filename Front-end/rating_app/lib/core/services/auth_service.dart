import 'dart:convert';

import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiServices _apiServices;
  AuthService(this._apiServices);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiServices.request(
      method: "POST",
      endpoint: Api_Constants.LoginPoint,
      data: {"email": email, "password": password},
    );

    final responseData = response.data;
    if (responseData['success']) {
      final user = User.fromJson(responseData["data"]["user"]);
      final token = responseData['data']['token'];

      await _saveAuthData(token, user);

      return {"user": user, "token": token};
    } else {
      throw Exception(responseData['error']['message']);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _apiServices.request(
      method: 'POST',
      endpoint: Api_Constants.RegisterPoint,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    
    final responseData = response.data;
    if (responseData['success']) {
      final user = User.fromJson(responseData['data']['user']);
      final token = responseData['data']['token'];
      
      await _saveAuthData(token, user);
      
      return {
        'user': user,
        'token': token,
      };
    } else {
      throw Exception(responseData['error']['message']);
    }
  }

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    final userData = prefs.getString(StorageKeys.userData);

    if (token != null && userData != null) {
      _apiServices.setToken(token);
      return true;
    }
    return false;
  }


  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
    await prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));
    _apiServices.setToken(token);
  }

  Future<User> getCurrentUser() async {
    final response = await _apiServices.request(
      method: 'GET',
      endpoint: Api_Constants.Url,
    );
    
    final responseData = response.data;
    if (responseData['success']) {
      return User.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['error']['message']);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.userData);
    _apiServices.cleanToken();
  }


}
