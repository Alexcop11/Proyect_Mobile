// lib/core/services/user_service.dart
import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/models/user.dart';
import '../utils/constants.dart';

class UserService {
  final ApiServices _apiServices;

  UserService(this._apiServices);

  // Obtener usuario por email
  Future<User?> getUserByEmail(String email) async {
    try {
      debugPrint('🔍 Buscando usuario por email: $email');
      
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: 'http://192.168.110.190:8000/api/users/email/$email',
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
        endpoint: 'http://192.168.110.190:8000/api/users/$id',
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
    String? apellido, // ⚠️ IMPORTANTE: Este parámetro debe estar aquí
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
        endpoint: 'http://192.168.110.190:8000/api/users/',
        data: {
          'idUsuario': idUsuario,
          'nombre': nombre,
          if (apellido != null) 'apellido': apellido, // ⚠️ Solo enviar si existe
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
        endpoint: 'http://192.168.110.190:8000/api/users/$idUsuario/change-password',
        data: {
          'password': newPassword,
        },
      );

      return response.data['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error cambiando contraseña: $e');
      throw Exception('Error al cambiar contraseña: ${e.toString()}');
    }
  }
}