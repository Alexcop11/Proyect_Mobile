import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/services/notification_services.dart';
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
      debugPrint("📥 Respuesta completa: ${jsonEncode(responseData)}");

      if (responseData['status'] == 'OK' && responseData['data'] != null) {
        final data = responseData['data'];
        final token = data['token'];
        final role = data['role'];
        final savedEmail = data['email'] ?? email;

        await _saveAuthData(token, role, savedEmail);
        return {"token": token, "role": role, "email": savedEmail};
      } else {
        final errorMessage =
            responseData['message'] ?? 'Credenciales incorrectas';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
    required String tipousuario,
  }) async {
    final response = await _apiServices.request(
      method: 'POST',
      endpoint: Api_Constants.registerPoint,
      data: {
        'email': email,
        'passwordHash': password,
        'tipoUsuario': tipousuario,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'activo': true,
      },
    );

    final responseData = response.data;
    debugPrint("📤 Registrando con: $tipousuario");
    debugPrint("📥 Respuesta: ${jsonEncode(responseData)}");

    if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
      final userJson = responseData['result'];
      final user = User.fromJson(userJson);
      final role = userJson['tipoUsuario'] ?? 'NORMAL';
      final token = responseData['token'] ?? '';
      await _saveAuthData(token, role, email);

      return {'user': user, 'token': token, 'role': role};
    } else {
      final errorMessage = responseData['text'] ?? 'Error al registrar';
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> getUser(String email) async {
    try {
      final response = await _apiServices.request(
        method: "GET",
        endpoint: "${Api_Constants.userPoint}$email",
      );

      final responseData = response.data;
      debugPrint("📥 getUser response: ${jsonEncode(responseData)}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final result = responseData['result'];
        return {
          "idUsuario": result['idUsuario'],
          "email": result['email'],
          "tipousuario": result['tipousuario'],
          "nombre": result['nombre'],
          "apellido": result['apellido'],
          "telefono": result['telefono'],
          "fechaRegistro": result['fechaRegistro'],
          "activo": result['activo'],
          "ultimoLogin": result['ultimoLogin'],
        };
      } else {
        throw Exception(responseData['text'] ?? 'Usuario no encontrado');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _saveAuthData(String token, String role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
    await prefs.setString(StorageKeys.role, role);
    await prefs.setString(StorageKeys.email, email);
    await prefs.setString(StorageKeys.userEmail, email);
    await prefs.setString(StorageKeys.userRole, role);
    _apiServices.setToken(token);
    _apiServices.setRole(role);
    _apiServices.setEmail(email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.userEmail) ??
        prefs.getString(StorageKeys.email);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.userRole) ??
        prefs.getString(StorageKeys.role);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.role);
    await prefs.remove(StorageKeys.email);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userRole);

    _apiServices.cleanToken();
    _apiServices.cleanRole();
    _apiServices.cleanEmail();
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  Future<String?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.role);
  }

  Future<bool> hasActiveSession() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> updateUser({
    required int idUsuario,
    required String email,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final payload = {
      "idUsuario": idUsuario,
      "email": email,
      "nombre": nombre,
      "apellido": apellido,
      "telefono": telefono,
    };

    final response = await _apiServices.request(
      method: 'PUT',
      endpoint: 'http://192.168.0.6:8000/api/users/',
      data: payload,
    );

    debugPrint("Actualización usuario: ${jsonEncode(response.data)}");

    if (response.data['type'] == 'SUCCESS') {
      return response.data['result'];
    } else {
      throw Exception(response.data['message'] ?? 'Error desconocido');
    }
  }

  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.email);
  }
}
