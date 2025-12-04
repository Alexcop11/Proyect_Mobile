import 'package:flutter/material.dart';
import 'package:rating_app/core/services/restaurant_service.dart';
import 'package:rating_app/models/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Restaurant> _restaurants = [];
  Restaurant? _currentRestaurant;
  Restaurant? _ownerRestaurant;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get currentRestaurant => _currentRestaurant;
  Restaurant? get ownerRestaurant => _ownerRestaurant;

  RestaurantProvider(this._restaurantService);

  /// Crear nuevo restaurante
  Future<bool> createRestaurant({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🏪 Creando restaurante: $nombre');
      
      final restaurant = await _restaurantService.createRestaurant(
        idUsuarioPropietario: idUsuarioPropietario,
        nombre: nombre,
        descripcion: descripcion,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        telefono: telefono,
        horarioApertura: horarioApertura,
        horarioCierre: horarioCierre,
        precioPromedio: precioPromedio,
        categoria: categoria,
        menuUrl: menuUrl,
        fechaRegistro: fechaRegistro,
        activo: activo,
      );

      _ownerRestaurant = restaurant;
      debugPrint('✅ Restaurante creado: ${restaurant.idRestaurante}');
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al crear restaurante: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar restaurante
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔄 Actualizando restaurante: ${restaurant.nombre}');
      
      final updatedRestaurant = await _restaurantService.updateRestaurant(restaurant);
      
      _ownerRestaurant = updatedRestaurant;
      
      // Actualizar en la lista si existe
      final index = _restaurants.indexWhere(
        (r) => r.idRestaurante == updatedRestaurant.idRestaurante
      );
      if (index != -1) {
        _restaurants[index] = updatedRestaurant;
      }
      
      debugPrint('✅ Restaurante actualizado: ${updatedRestaurant.idRestaurante}');
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al actualizar restaurante: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener restaurante del propietario por email
  Future<Restaurant?> loadOwnerRestaurant(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Buscando restaurante del propietario: $email');
      
      _ownerRestaurant = await _restaurantService.getRestaurantByOwnerEmail(email);
      
      if (_ownerRestaurant != null) {
        debugPrint('✅ Restaurante encontrado: ${_ownerRestaurant!.nombre}');
      } else {
        debugPrint('ℹ️ El propietario no tiene restaurante registrado');
      }
      
      return _ownerRestaurant;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al cargar restaurante del propietario: $_errorMessage');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar todos los restaurantes
  Future<void> loadAllRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📋 Cargando todos los restaurantes...');
      
      _restaurants = await _restaurantService.getAllRestaurants();
      
      debugPrint('✅ ${_restaurants.length} restaurantes cargados');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al cargar restaurantes: $_errorMessage');
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buscar restaurantes
  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      await loadAllRestaurants();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Buscando restaurantes: $query');
      
      _restaurants = await _restaurantService.searchRestaurants(query);
      
      debugPrint('✅ ${_restaurants.length} resultados encontrados');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error en búsqueda: $_errorMessage');
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtrar por categoría
  Future<void> filterByCategory(String categoria) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🏷️ Filtrando por categoría: $categoria');
      
      _restaurants = await _restaurantService.getRestaurantsByCategory(categoria);
      
      debugPrint('✅ ${_restaurants.length} restaurantes de $categoria');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al filtrar: $_errorMessage');
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener restaurantes cercanos
  Future<void> loadNearbyRestaurants(
    double latitude,
    double longitude, [
    double radiusKm = 5.0,
  ]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📍 Cargando restaurantes cercanos...');
      
      _restaurants = await _restaurantService.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      debugPrint('✅ ${_restaurants.length} restaurantes cercanos');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al cargar restaurantes cercanos: $_errorMessage');
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener restaurante por ID
  Future<Restaurant?> getRestaurantById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Obteniendo restaurante ID: $id');
      
      _currentRestaurant = await _restaurantService.getRestaurantById(id);
      
      if (_currentRestaurant != null) {
        debugPrint('✅ Restaurante obtenido: ${_currentRestaurant!.nombre}');
      }
      
      return _currentRestaurant;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al obtener restaurante: $_errorMessage');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eliminar restaurante
  Future<bool> deleteRestaurant(int idRestaurante) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🗑️ Eliminando restaurante ID: $idRestaurante');
      
      final success = await _restaurantService.deleteRestaurant(idRestaurante);
      
      if (success) {
        _restaurants.removeWhere((r) => r.idRestaurante == idRestaurante);
        if (_ownerRestaurant?.idRestaurante == idRestaurante) {
          _ownerRestaurant = null;
        }
        debugPrint('✅ Restaurante eliminado');
      }
      
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al eliminar restaurante: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentRestaurant() {
    _currentRestaurant = null;
    notifyListeners();
  }
}