import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rating_app/models/photo.dart';
import 'package:rating_app/core/services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  final PhotoService _photoService;

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor que recibe el servicio
  PhotoProvider(this._photoService);

  /// Subir foto
  Future<bool> uploadPhoto({
    required File imageFile,
    required int idRestaurante,
    String? descripcion,
    bool esPortada = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photo = await _photoService.uploadPhoto(
        imageFile: imageFile,
        idRestaurante: idRestaurante,
        descripcion: descripcion,
        esPortada: esPortada,
      );

      _photos.add(photo);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error en PhotoProvider.uploadPhoto: $e');
      return false;
    }
  }

  /// Obtener fotos de un restaurante
  Future<void> loadPhotosByRestaurant(int idRestaurante) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _photos = await _photoService.getPhotosByRestaurant(idRestaurante);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar fotos: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error en PhotoProvider.loadPhotosByRestaurant: $e');
    }
  }

  /// Establecer como portada
  Future<bool> setAsPortada(int idFoto) async {
    try {
      final updatedPhoto = await _photoService.setAsPortada(idFoto);
      
      // Actualizar localmente: poner todas en false y la seleccionada en true
      for (var i = 0; i < _photos.length; i++) {
        if (_photos[i].idFoto == idFoto) {
          _photos[i] = updatedPhoto;
        } else if (_photos[i].esPortada) {
          // Crear nueva instancia con esPortada en false
          _photos[i] = Photo(
            idFoto: _photos[i].idFoto,
            urlFoto: _photos[i].urlFoto,
            descripcion: _photos[i].descripcion,
            esPortada: false,
            fechaSubida: _photos[i].fechaSubida,
            idRestaurante: _photos[i].idRestaurante,
          );
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('❌ Error en PhotoProvider.setAsPortada: $e');
      return false;
    }
  }

  /// Eliminar foto
  Future<bool> deletePhoto(int idFoto) async {
    try {
      final success = await _photoService.deletePhoto(idFoto);
      if (success) {
        _photos.removeWhere((photo) => photo.idFoto == idFoto);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar foto: $e';
      notifyListeners();
      debugPrint('❌ Error en PhotoProvider.deletePhoto: $e');
      return false;
    }
  }

  /// Obtener foto de portada
  Photo? get portada {
    try {
      return _photos.firstWhere((photo) => photo.esPortada);
    } catch (e) {
      return _photos.isNotEmpty ? _photos.first : null;
    }
  }

  /// Limpiar fotos
  void clearPhotos() {
    _photos = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar solo el error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}