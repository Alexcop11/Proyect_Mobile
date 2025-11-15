import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiServices _apiServices;
  AuthService(this._apiServices);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiServices.request(
        method: "POST",
        endpoint: Api_Constants.loginPoint,
        data: {"email": email, "password": password},
      );

      final responseData = response.data;

      debugPrint("📤 Enviando login con: $email");
      debugPrint("📥 Respuesta: ${jsonEncode(responseData)}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final token = responseData['result'];
        await _saveAuthData(token);
        return {"token": token};
      } else {
        final errorMessage =
            responseData['message'] ?? 'Credenciales incorrectas';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _apiServices.request(
      method: 'POST',
      endpoint: Api_Constants.registerPoint,
      data: {'name': name, 'email': email, 'password': password},
    );

    final responseData = response.data;

    if (responseData['data']?['token'] != null) {
      final token = responseData['data']['token'];
      final user = User.fromJson(responseData['data']['user']);

      await _saveAuthData(token);
      return {'user': user, 'token': token};
    } else {
      final errorMessage = responseData['message'] ?? 'Error al registrar';
      throw Exception(errorMessage);
    }
  }

  Future<void> _saveAuthData(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
    _apiServices.setToken(token);
  }

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);

    if (token != null) {
      _apiServices.setToken(token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    _apiServices.cleanToken();
  }
}
