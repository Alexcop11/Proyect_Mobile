import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserService {
  final ApiServices _apiServices;

  UserService(this._apiServices);

  // Obtener usuario por email
  Future<User?> getUserByEmail(String email) async {
    try {
      debugPrint('🔍 Buscando usuario por email: $email');
      
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.url}/users/email/$email',
      );

      debugPrint('📥 Respuesta getUserByEmail: ${response.data}');

      if (response.data['type'] == 'SUCCESS' && response.data['result'] != null) {
        final user = User.fromJson(response.data['result']);
        debugPrint('✅ Usuario encontrado: ${user.nombre} ${user.apellido ?? ""}');
        return user;
      }
      
      debugPrint('⚠️ Usuario no encontrado en respuesta');
      return null;
    } on Exception catch (e) {
      debugPrint('❌ Error obteniendo usuario por email: $e');
      
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        throw Exception('El servidor está tardando demasiado. Verifica tu conexión o intenta más tarde.');
      }
      
      return null;
    }
  }

  
  // Obtener usuario por ID
  Future<User?> getUserById(int id) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.url}/users/$id',
      );

      if (response.data['type'] == 'SUCCESS' && response.data['result'] != null) {
        return User.fromJson(response.data['result']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Actualizar perfil de usuario
  Future<User?> updateProfile({
    required int idUsuario,
    required String nombre,
    String? apellido,
    required String email,
    String? telefono,
    String? tipoUsuario,
    bool? activo,
  }) async {
    try {
      debugPrint('📤 Actualizando perfil:');
      debugPrint('  - ID: $idUsuario');
      debugPrint('  - Nombre: $nombre');
      debugPrint('  - Apellido: $apellido');
      debugPrint('  - Email: $email');
      debugPrint('  - Teléfono: $telefono');
      
      final response = await _apiServices.request(
        method: 'PUT',
        endpoint: '${Api_Constants.url}/users/',
        data: {
          'idUsuario': idUsuario,
          'nombre': nombre,
          if (apellido != null) 'apellido': apellido,
          'email': email,
          'telefono': telefono,
          'tipoUsuario': tipoUsuario ?? 'NORMAL',
          'activo': activo ?? true,
        },
      );

      debugPrint('📥 Respuesta updateProfile: ${response.data}');

      if (response.data['type'] == 'SUCCESS' && response.data['result'] != null) {
        final updatedUser = User.fromJson(response.data['result']);
        debugPrint('✅ Perfil actualizado: ${updatedUser.nombre} ${updatedUser.apellido ?? ""}');
        return updatedUser;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error actualizando perfil: $e');
      throw Exception('Error al actualizar perfil: ${e.toString()}');
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword({
    required int idUsuario,
    required String newPassword,
  }) async {
    try {
      final response = await _apiServices.request(
        method: 'PATCH',
        endpoint: '${Api_Constants.url}/users/change-password',
        data: {
          'id': idUsuario,
          'password': newPassword,
        },
      );

      return response.data['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error cambiando contraseña: $e');
      throw Exception('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  //Token para las notificaciones
  Future<void> registerPushToken(String userId) async {
    final messaging = FirebaseMessaging.instance;

    final token = await messaging.getToken();
    debugPrint("✅ Token FCM real: $token");

    if (token != null) {
      final url = Uri.parse("${Api_Constants.url}/users/push-token");
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": int.parse(userId), "pushToken": token}),
      );

      if (response.statusCode == 200) {
        debugPrint("🎯 Token enviado al backend");
      } else {
        debugPrint("❌ Error al enviar token: ${response.body}");
      }
    }

    // Escucha cambios de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 Token FCM refrescado: $newToken");
      final url = Uri.parse("${Api_Constants.url}/users/push-token");
      await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": int.parse(userId), "pushToken": newToken}),
      );
    });
  }
}