import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rating_app/models/photo.dart';

class PhotoService {
  final ApiServices _apiServices;

  PhotoService(this._apiServices);

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.token);
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No se encontró token');
        return null;
      }
      
      return token;
    } catch (e) {
      debugPrint('❌ Error al obtener token: $e');
      return null;
    }
  }

  Future<Photo> uploadPhoto({
    required File imageFile,
    required int idRestaurante,
    String? descripcion,
    bool esPortada = false,
  }) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa. Por favor inicia sesión.');
      }

      debugPrint('📤 Subiendo foto del restaurante $idRestaurante...');

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Accept'] = 'application/json';

      final url = '${Api_Constants.url}${Api_Constants.photosPoint}upload';

      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'idRestaurante': idRestaurante.toString(),
        'esPortada': esPortada.toString(),
        if (descripcion != null && descripcion.isNotEmpty)
          'descripcion': descripcion,
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      final responseData = response.data;
      debugPrint('📥 Respuesta upload: ${jsonEncode(responseData)}');

      Map<String, dynamic>? photoData;
      
      if (responseData is Map<String, dynamic>) {
        // Intentar obtener los datos de diferentes campos posibles
        if (responseData.containsKey('result') && responseData['result'] != null) {
          photoData = responseData['result'];
        } else if (responseData.containsKey('data') && responseData['data'] != null) {
          photoData = responseData['data'];
        } else if (responseData['type'] == 'SUCCESS' || 
                   responseData['typeResponse'] == 'SUCCESS') {
          photoData = responseData;
        }
      }

      if (photoData != null && photoData.isNotEmpty) {
        debugPrint('✅ Foto subida exitosamente');
        return Photo.fromJson(photoData);
      } else {
        throw Exception('No se recibieron datos de la foto');
      }

    } on DioException catch (e) {
      debugPrint('❌ Error al subir foto: ${e.response?.data?['message'] ?? e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para realizar esta acción');
      } else if (e.response?.statusCode == 413) {
        throw Exception('El archivo es demasiado grande');
      } else if (e.response?.statusCode == 415) {
        throw Exception('Formato de archivo no soportado');
      } else {
        final errorMsg = e.response?.data?['message'] ?? 
                        e.response?.data?['error'] ?? 
                        e.message ?? 
                        'Error al subir la foto';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error en uploadPhoto: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Photo>> getPhotosByRestaurant(int idRestaurante) async {
    try {
      debugPrint('📥 Obteniendo fotos del restaurante $idRestaurante...');
      
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.photosPoint}restaurant/$idRestaurante',
      );

      final responseData = response.data;
      debugPrint('📥 Respuesta getPhotos: ${jsonEncode(responseData)}');

      List<dynamic>? photosJson;
      
      // Tu servidor usa 'result' y 'type': 'SUCCESS'
      if (responseData['type'] == 'SUCCESS' || 
          responseData['typeResponse'] == 'SUCCESS') {
        photosJson = responseData['result'] ?? responseData['data'];
      }

      if (photosJson != null && photosJson.isNotEmpty) {
        final photos = photosJson.map((json) => Photo.fromJson(json)).toList();
        debugPrint('✅ Se cargaron ${photos.length} fotos');
        return photos;
      }
      
      debugPrint('ℹ️ No hay fotos para el restaurante $idRestaurante');
      return [];
    } catch (e) {
      debugPrint('❌ Error al obtener fotos: $e');
      return [];
    }
  }

  Future<Photo> setAsPortada(int idFoto) async {
    try {
      final response = await _apiServices.request(
        method: 'PUT',
        endpoint: '${Api_Constants.photosPoint}$idFoto/portada',
      );

      final responseData = response.data;

      Map<String, dynamic>? photoData;
      
      if (responseData['type'] == 'SUCCESS' || 
          responseData['typeResponse'] == 'SUCCESS') {
        photoData = responseData['result'] ?? responseData['data'];
      }

      if (photoData != null) {
        return Photo.fromJson(photoData);
      } else {
        throw Exception(responseData['message'] ?? 'Error al establecer portada');
      }
    } catch (e) {
      debugPrint('❌ Error al establecer portada: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> deletePhoto(int idFoto) async {
    try {
      debugPrint('🗑️ Eliminando foto $idFoto...');
      
      final response = await _apiServices.request(
        method: 'DELETE',
        endpoint: '${Api_Constants.photosPoint}$idFoto',
      );

      final responseData = response.data;
      debugPrint('📥 Respuesta delete: ${jsonEncode(responseData)}');

      final success = responseData['type'] == 'SUCCESS' || 
                     responseData['typeResponse'] == 'SUCCESS';
      
      if (success) {
        debugPrint('✅ Foto eliminada correctamente');
      } else {
        debugPrint('⚠️ No se pudo eliminar la foto');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error al eliminar foto: $e');
      return false;
    }
  }

  Future<Photo?> getPortadaByRestaurant(int idRestaurante) async {
    try {
      final photos = await getPhotosByRestaurant(idRestaurante);
      return photos.firstWhere(
        (photo) => photo.esPortada,
        orElse: () => photos.isNotEmpty ? photos.first : throw Exception('Sin fotos'),
      );
    } catch (e) {
      debugPrint('ℹ️ No hay foto de portada para el restaurante $idRestaurante');
      return null;
    }
  }
}