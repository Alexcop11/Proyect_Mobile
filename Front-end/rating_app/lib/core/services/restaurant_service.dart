import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/restaurant.dart';

class RestaurantService {
  final ApiServices _apiServices;

  RestaurantService(this._apiServices);

  /// Crear un nuevo restaurante
  Future<Restaurant> createRestaurant({
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
    try {
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
        return Restaurant.fromJson(responseData['result']);
      } else {
        throw Exception(responseData['text'] ?? 'Error al registrar restaurante');
      }
    } catch (e) {
      debugPrint('❌ Error en createRestaurant: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Actualizar restaurante existente
  Future<Restaurant> updateRestaurant(Restaurant restaurant) async {
    try {
      final response = await _apiServices.request(
        method: 'PUT',
        endpoint: Api_Constants.restaurantPoint,
        data: restaurant.toJson(),
      );

      debugPrint("📡 Actualización restaurante: ${jsonEncode(response.data)}");

      final responseData = response.data;
      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return Restaurant.fromJson(responseData['result']);
      } else {
        throw Exception(responseData['message'] ?? 'Error al actualizar restaurante');
      }
    } catch (e) {
      debugPrint('❌ Error en updateRestaurant: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Obtener restaurante por email del propietario
  Future<Restaurant?> getRestaurantByOwnerEmail(String email) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.restaurantPoint}owner/$email',
      );

      final responseData = response.data;
      debugPrint("📡 getRestaurantByOwnerEmail: ${jsonEncode(responseData)}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return Restaurant.fromJson(responseData['result']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error en getRestaurantByOwnerEmail: $e');
      return null;
    }
  }

  /// Obtener restaurante por ID
  Future<Restaurant?> getRestaurantById(int id) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.restaurantPoint}$id',
      );

      final responseData = response.data;
      debugPrint("📡 getRestaurantById: ${jsonEncode(responseData)}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return Restaurant.fromJson(responseData['result']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error en getRestaurantById: $e');
      return null;
    }
  }

  /// Obtener todos los restaurantes
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: Api_Constants.restaurantPoint,
      );

      final responseData = response.data;
      
      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> restaurantsJson = responseData['result'];
        debugPrint("📡 getAllRestaurants: Intentando parsear ${restaurantsJson.length} restaurantes");
        
        final List<Restaurant> restaurants = [];
        
        for (int i = 0; i < restaurantsJson.length; i++) {
          try {
            final restaurant = Restaurant.fromJson(restaurantsJson[i]);
            restaurants.add(restaurant);
            debugPrint("✅ Restaurante $i parseado: ${restaurant.nombre}");
          } catch (e) {
            debugPrint("❌ Error parseando restaurante $i: $e");
            debugPrint("📄 JSON del restaurante con error: ${restaurantsJson[i]}");
          }
        }
        
        debugPrint("✅ Total de restaurantes parseados correctamente: ${restaurants.length}");
        return restaurants;
      }
      
      debugPrint("⚠️ Respuesta no válida o sin resultados");
      return [];
    } catch (e) {
      debugPrint('❌ Error en getAllRestaurants: $e');
      return [];
    }
  }

  /// Buscar restaurantes por nombre
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: Api_Constants.restaurantPoint,
        queryParameters: {'search': query},
      );

      final responseData = response.data;
      debugPrint("📡 searchRestaurants: ${responseData['result']?.length ?? 0} resultados para '$query'");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> restaurantsJson = responseData['result'];
        return restaurantsJson
            .map((json) => Restaurant.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en searchRestaurants: $e');
      return [];
    }
  }

  /// Filtrar restaurantes por categoría
  Future<List<Restaurant>> getRestaurantsByCategory(String categoria) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: Api_Constants.restaurantPoint,
        queryParameters: {'categoria': categoria},
      );

      final responseData = response.data;
      debugPrint("📡 getRestaurantsByCategory: ${responseData['result']?.length ?? 0} restaurantes de '$categoria'");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> restaurantsJson = responseData['result'];
        return restaurantsJson
            .map((json) => Restaurant.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getRestaurantsByCategory: $e');
      return [];
    }
  }

  /// Obtener restaurantes cercanos (necesita coordenadas del usuario)
  Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.restaurantPoint}',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
        },
      );

      final responseData = response.data;
      debugPrint("📡 getNearbyRestaurants: ${responseData['result']?.length ?? 0} restaurantes cercanos");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> restaurantsJson = responseData['result'];
        return restaurantsJson
            .map((json) => Restaurant.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getNearbyRestaurants: $e');
      return [];
    }
  }

  /// Eliminar restaurante (desactivar)
  Future<bool> deleteRestaurant(int idRestaurante) async {
    try {
      final response = await _apiServices.request(
        method: 'DELETE',
        endpoint: '${Api_Constants.restaurantPoint}$idRestaurante',
      );

      final responseData = response.data;
      debugPrint("📡 deleteRestaurant: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en deleteRestaurant: $e');
      return false;
    }
  }
}