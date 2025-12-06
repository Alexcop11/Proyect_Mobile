import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rating_app/models/photo.dart';
import 'package:rating_app/core/services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  final PhotoService _photoService;

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // 🆕 Caché de fotos de portada por restaurante
  final Map<int, String?> _portadaCache = {};
  final Map<int, bool> _loadingCache = {};

  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PhotoProvider(this._photoService);

  /// Obtener URL de portada desde caché (sin cargar de nuevo)
  String? getPortadaUrl(int idRestaurante) {
    return _portadaCache[idRestaurante];
  }

  /// Verificar si ya se está cargando la foto de un restaurante
  bool isLoadingRestaurant(int idRestaurante) {
    return _loadingCache[idRestaurante] ?? false;
  }

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
      
      // Actualizar caché si es portada
      if (esPortada) {
        _portadaCache[idRestaurante] = photo.urlFoto;
      }
      
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
    // Si ya está en caché, no recargar
    if (_portadaCache.containsKey(idRestaurante)) {
      debugPrint('✅ Foto ya en caché para restaurante $idRestaurante');
      return;
    }

    // Si ya se está cargando, no hacer otra petición
    if (_loadingCache[idRestaurante] == true) {
      debugPrint('⏳ Ya se está cargando foto para restaurante $idRestaurante');
      return;
    }

    _loadingCache[idRestaurante] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photos = await _photoService.getPhotosByRestaurant(idRestaurante);
      _photos = photos;
      
      // Guardar URL de portada en caché
      final portada = photos.firstWhere(
        (photo) => photo.esPortada,
        orElse: () => photos.isNotEmpty ? photos.first : 
                      Photo(
                        urlFoto: '',
                        esPortada: false,
                        fechaSubida: DateTime.now().toIso8601String(),
                        idRestaurante: idRestaurante,
                      ),
      );
      
      _portadaCache[idRestaurante] = portada.urlFoto.isNotEmpty ? portada.urlFoto : null;
      _loadingCache[idRestaurante] = false;
      
      notifyListeners();
      
      debugPrint('✅ Foto cargada y guardada en caché para restaurante $idRestaurante');
    } catch (e) {
      _errorMessage = 'Error al cargar fotos: $e';
      _loadingCache[idRestaurante] = false;
      _portadaCache[idRestaurante] = null; // Marcar como sin foto
      notifyListeners();
      debugPrint('❌ Error en PhotoProvider.loadPhotosByRestaurant: $e');
    }
  }

  /// Cargar fotos de múltiples restaurantes en paralelo (optimizado)
  Future<void> loadMultipleRestaurantPhotos(List<int> restaurantIds) async {
    final idsToLoad = restaurantIds
        .where((id) => !_portadaCache.containsKey(id) && 
                      _loadingCache[id] != true)
        .toList();

    if (idsToLoad.isEmpty) {
      debugPrint('✅ Todas las fotos ya están en caché');
      return;
    }

    debugPrint('📸 Cargando fotos para ${idsToLoad.length} restaurantes...');

    // Marcar todos como cargando
    for (final id in idsToLoad) {
      _loadingCache[id] = true;
    }
    notifyListeners();

    // Cargar en paralelo (máximo 5 a la vez para no sobrecargar)
    final futures = <Future>[];
    for (var i = 0; i < idsToLoad.length; i += 5) {
      final batch = idsToLoad.skip(i).take(5);
      for (final id in batch) {
        futures.add(_loadSingleRestaurantPhoto(id));
      }
      
      // Esperar este lote antes de continuar
      await Future.wait(futures);
      futures.clear();
    }

    debugPrint('✅ Todas las fotos cargadas');
    notifyListeners();
  }

  /// Cargar foto de un solo restaurante (método interno)
  Future<void> _loadSingleRestaurantPhoto(int idRestaurante) async {
    try {
      final photos = await _photoService.getPhotosByRestaurant(idRestaurante);
      
      final portada = photos.firstWhere(
        (photo) => photo.esPortada,
        orElse: () => photos.isNotEmpty ? photos.first : 
                      Photo(
                        urlFoto: '',
                        esPortada: false,
                        fechaSubida: DateTime.now().toIso8601String(),
                        idRestaurante: idRestaurante,
                      ),
      );
      
      _portadaCache[idRestaurante] = portada.urlFoto.isNotEmpty ? portada.urlFoto : null;
    } catch (e) {
      debugPrint('❌ Error cargando foto restaurante $idRestaurante: $e');
      _portadaCache[idRestaurante] = null;
    } finally {
      _loadingCache[idRestaurante] = false;
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
          // Actualizar caché
          _portadaCache[updatedPhoto.idRestaurante] = updatedPhoto.urlFoto;
        } else if (_photos[i].esPortada) {
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
        final deletedPhoto = _photos.firstWhere(
          (photo) => photo.idFoto == idFoto,
          orElse: () => Photo(
            urlFoto: '',
            esPortada: false,
            fechaSubida: DateTime.now().toIso8601String(),
            idRestaurante: 0,
          ),
        );
        
        _photos.removeWhere((photo) => photo.idFoto == idFoto);
        
        // Actualizar caché
        if (deletedPhoto.idRestaurante > 0) {
          _portadaCache.remove(deletedPhoto.idRestaurante);
        }
        
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

  /// Limpiar fotos y caché
  void clearPhotos() {
    _photos = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar toda la caché (útil al cerrar sesión)
  void clearCache() {
    _portadaCache.clear();
    _loadingCache.clear();
    _photos = [];
    _errorMessage = null;
    notifyListeners();
    debugPrint('🗑️ Caché de fotos limpiada');
  }

  /// Limpiar solo el error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}