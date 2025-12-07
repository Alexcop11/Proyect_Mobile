import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/services/notification_services.dart';
import 'package:rating_app/core/services/restaurant_service.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/favorite.dart';

class FavoriteService {
  final ApiServices _apiServices;

  FavoriteService(this._apiServices);

  /// Agregar restaurante a favoritos
 Future<Favorite> addFavorite({
  required int userId,
  required int restaurantId,
}) async {
  try {
    final response = await _apiServices.request(
      method: 'POST',
      endpoint: Api_Constants.favoritePoint,
      data: {'idUsuario': userId, 'idRestaurante': restaurantId},
    );
    
    final ownerId = await RestaurantService(_apiServices)
        .getOwnerIdByRestaurant(restaurantId);
    debugPrint("👤 Owner ID del restaurante: $ownerId");

    // ⭐ Agregar restaurantId aquí
    await NotificationService().sendNotification(
      userId: ownerId!,
      titulo: "Nuevo Favorito",
      mensaje: "Parece que alguien añadió tu restaurante como favorito",
      restaurantId: restaurantId, // ⭐ Pasar el restaurantId
    );

    final responseData = response.data;
    debugPrint("📤 Agregando favorito - Usuario: $userId, Restaurante: $restaurantId");
    debugPrint("📥 Respuesta: ${jsonEncode(responseData)}");

    if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
      final favorite = Favorite.fromJson(responseData['result']);
      return favorite;
    } else {
      throw Exception(responseData['text'] ?? 'Error al agregar favorito');
    }
  } catch (e) {
    debugPrint('❌ Error en addFavorite: $e');
    throw Exception(e.toString().replaceFirst('Exception: ', ''));
  }
}
  /// ✅ Método separado para enviar notificación (sin bloquear el flujo principal)
  void _sendFavoriteNotification(int userId, int restaurantId) async {
    try {
      final ownerId = await RestaurantService(_apiServices)
          .getOwnerIdByRestaurant(restaurantId);
      
      if (ownerId == null) {
        debugPrint("⚠️ No se encontró el dueño del restaurante $restaurantId");
        return;
      }

      debugPrint("👤 Dueño del restaurante: $ownerId");

      await NotificationService().sendNotification(
        userId: ownerId,
        titulo: "Nuevo Favorito",
        mensaje: "Alguien agregó tu restaurante a favoritos",
       );
      
      debugPrint("✅ Notificación de favorito enviada correctamente");
    } catch (e) {
      debugPrint("❌ Error enviando notificación de favorito: $e");
      // No propagamos el error para no afectar el flujo principal
    }
  }

  /// Eliminar favorito por ID
  Future<bool> removeFavoriteById(int favoriteId) async {
    try {
      final response = await _apiServices.request(
        method: 'DELETE',
        endpoint: '${Api_Constants.favoritePoint}$favoriteId',
      );

      final responseData = response.data;
      debugPrint("📡 removeFavoriteById: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en removeFavoriteById: $e');
      return false;
    }
  }

  /// Eliminar favorito por usuario y restaurante
  Future<bool> removeFavorite({
    required int userId,
    required int restaurantId,
  }) async {
    try {
      final response = await _apiServices.request(
        method: 'DELETE',
        endpoint:
            '${Api_Constants.favoritePoint}user/$userId/restaurant/$restaurantId',
      );

      final responseData = response.data;
      debugPrint("📡 removeFavorite: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en removeFavorite: $e');
      return false;
    }
  }

  /// Obtener favoritos del usuario
  Future<List<Favorite>> getUserFavorites(int userId) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.favoritePoint}user/$userId',
      );

      final responseData = response.data;
      debugPrint(
        "📡 getUserFavorites: ${responseData['result']?.length ?? 0} favoritos",
      );

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> favoritesJson = responseData['result'];
        return favoritesJson.map((json) => Favorite.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getUserFavorites: $e');
      return [];
    }
  }

  /// Obtener favoritos de un restaurante
  Future<List<Favorite>> getRestaurantFavorites(int restaurantId) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.favoritePoint}restaurant/$restaurantId',
      );

      final responseData = response.data;
      debugPrint(
        "📡 getRestaurantFavorites: ${responseData['result']?.length ?? 0} usuarios",
      );

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> favoritesJson = responseData['result'];
        return favoritesJson.map((json) => Favorite.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getRestaurantFavorites: $e');
      return [];
    }
  }

  /// Verificar si un restaurante está en favoritos
  Future<bool> isFavorite({
    required int userId,
    required int restaurantId,
  }) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint:
            '${Api_Constants.favoritePoint}user/$userId/restaurant/$restaurantId/exists',
      );

      final responseData = response.data;
      debugPrint("📡 isFavorite: ${jsonEncode(responseData)}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return responseData['result'] as bool;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error en isFavorite: $e');
      return false;
    }
  }

  /// Contar favoritos del usuario
  Future<int> countUserFavorites(int userId) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.favoritePoint}user/$userId/count',
      );

      final responseData = response.data;
      debugPrint("📡 countUserFavorites: ${responseData['result']}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return responseData['result'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Error en countUserFavorites: $e');
      return 0;
    }
  }

  /// Contar cuántos usuarios tienen un restaurante en favoritos
  Future<int> countRestaurantFavorites(int restaurantId) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint:
            '${Api_Constants.favoritePoint}restaurant/$restaurantId/count',
      );

      final responseData = response.data;
      debugPrint("📡 countRestaurantFavorites: ${responseData['result']}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return responseData['result'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Error en countRestaurantFavorites: $e');
      return 0;
    }
  }
}