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

      if (responseData['status'] == 'OK' && responseData['data'] != null) {
        final token = responseData['data']['token'];
        final role = responseData['data']['role'];
        final email = responseData['data']['email'];
        await _saveAuthData(token, role, email);
        return {"token": token, "role": role, "email": email};
      } else {
        final errorMessage =
            responseData['message'] ?? 'Credenciales incorrectas';
        throw Exception(errorMessage);
      }
    } catch (e) {
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
      await _saveAuthData(token, role, "");

      return {'user': user, 'token': token, 'role': role};
    } else {
      final errorMessage = responseData['text'] ?? 'Error al registrar';
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> createRestaurant({
    required int idUsuarioPropietario,
    required String nombre,
    required String descripcion,
    required String direccion,
    required double latitud,
    required double longitud,
    required String telefono,
    required String horarioApertura,
    required String horarioCierre,
    required double precioPromedio,
    required String categoria,
    required String menuUrl,
    required String fechaRegistro,
    required bool activo,
  }) async {
    final response = await _apiServices.request(
      method: 'POST',
      endpoint: Api_Constants.restaurantPoint,
      data: {
        'idUsuarioPropietario': idUsuarioPropietario,
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'telefono': telefono,
        'horarioApertura': horarioApertura,
        'horarioCierre': horarioCierre,
        'precioPromedio': precioPromedio,
        'categoria': categoria,
        'menuUrl': menuUrl,
        'fechaRegistro': fechaRegistro,
        'activo': activo,
      },
    );

    final responseData = response.data;
    debugPrint("📤 Creando restaurante: $nombre");
    debugPrint("📥 Respuesta: ${jsonEncode(responseData)}");

    if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
      final result = responseData['result'];
      final idRestaurante = result['idRestaurante'];
      final propietario = result['usuarioPropietario'];
      return {'idRestaurante': idRestaurante, 'propietario': propietario};
    } else {
      final errorMessage =
          responseData['text'] ?? 'Error al registrar restaurante';
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

  Future<Map<String, dynamic>?> getRestaurantByEmail(String email) async {
    final response = await _apiServices.request(
      method: 'GET',
      endpoint: 'http://192.168.107.81:8000/api/restaurants/owner/$email',
    );

    final data = response.data;
    debugPrint("📡 Backend: ${jsonEncode(data)}");

    if (data['type'] == 'SUCCESS' && data['result'] != null) {
      return data['result'];
    }
    return null;
  }

  Future<void> _saveAuthData(String token, String role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
    await prefs.setString(StorageKeys.role, role);
    await prefs.setString(StorageKeys.email, email);
    _apiServices.setToken(token);
    _apiServices.setRole(role);
    _apiServices.setEmail(email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.role);

    _apiServices.cleanToken();
    _apiServices.cleanRole();
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

  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.email);
  }
}
