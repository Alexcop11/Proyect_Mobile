import 'package:flutter/material.dart';
import 'package:rating_app/core/services/restaurant_service.dart';
import 'package:rating_app/models/restaurant.dart';
import 'package:rating_app/models/review.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Restaurant> _restaurants = [];
  Restaurant? _currentRestaurant;
  Restaurant? _ownerRestaurant;
  List<Review> _reviews = [];
  int _favoritesCount = 0;
  int _totalReviews = 0;
  double _averageRating = 0.0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get currentRestaurant => _currentRestaurant;
  Restaurant? get ownerRestaurant => _ownerRestaurant;
  List<Review> get reviews => _reviews;
  int get favoritesCount => _favoritesCount;
  int get totalReviews => _totalReviews;
  double get averageRating => _averageRating;

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
        
        // Cargar datos adicionales del restaurante
        await _loadRestaurantStats(_ownerRestaurant!.idRestaurante!);
      } else {
        debugPrint('ℹ️ El propietario no tiene restaurante registrado');
        _resetStats();
      }
      
      return _ownerRestaurant;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al cargar restaurante del propietario: $_errorMessage');
      _resetStats();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

/// Cargar estadísticas del restaurante (favoritos, reseñas, calificación)
Future<void> _loadRestaurantStats(int idRestaurante) async {
  try {
    debugPrint('📊 Cargando estadísticas del restaurante ID: $idRestaurante');
    
    // Cargar favoritos
    _favoritesCount = await _restaurantService.getFavoritesCount(idRestaurante);
    
    // Cargar reseñas
    _reviews = await _restaurantService.getReviews(idRestaurante);
    _totalReviews = _reviews.length;
    
    // Calcular calificación promedio
    if (_reviews.isNotEmpty) {
      double totalRating = 0;
      for (var review in _reviews) {
        final comida = review.puntuacionComida ?? 0;
        final servicio = review.puntuacionServicio ?? 0;
        final ambiente = review.puntuacionAmbiente ?? 0;
        totalRating += (comida + servicio + ambiente) / 3;
      }
      _averageRating = totalRating / _reviews.length;
    } else {
      _averageRating = 0.0;
    }
    
    debugPrint('✅ Stats: $_favoritesCount favoritos, $_totalReviews reseñas, $_averageRating★');
    
    // ✅ ESTO ES LO QUE FALTABA - Notificar a los listeners
    notifyListeners();
    
  } catch (e) {
    debugPrint('⚠️ Error cargando stats: $e');
    _resetStats();
    notifyListeners(); // También notificar en caso de error
  }
}
  /// Resetear estadísticas
  void _resetStats() {
    _favoritesCount = 0;
    _totalReviews = 0;
    _averageRating = 0.0;
    _reviews = [];
  }

  /// Obtener detalles completos del restaurante del propietario
  Future<Map<String, dynamic>?> getOwnerRestaurantDetails(String email) async {
    try {
      debugPrint('🔍 Obteniendo detalles completos del restaurante');
      
      final restaurant = await _restaurantService.getRestaurantByOwnerEmail(email);
      
      if (restaurant == null) {
        return null;
      }

      final idRestaurante = restaurant.idRestaurante!;
      
      // Cargar todos los datos
      final favorites = await _restaurantService.getFavoritesCount(idRestaurante);
      final reviews = await _restaurantService.getReviews(idRestaurante);
      
      // Calcular resumen de reseñas
      double averageRating = 0.0;
      if (reviews.isNotEmpty) {
        double total = 0;
        for (var review in reviews) {
          total += ((review.puntuacionComida ?? 0) +
                   (review.puntuacionServicio ?? 0) +
                   (review.puntuacionAmbiente ?? 0)) / 3;
        }
        averageRating = total / reviews.length;
      }

      return {
        'restaurante': restaurant,
        'favoritesCount': favorites,
        'reviewsCount': reviews.length,
        'reviewsSummary': {
          'average': averageRating,
          'count': reviews.length,
        },
        'reviews': reviews.map((r) => {
          'usuario': {
            'nombre': r.usuario?.nombre ?? 'Anónimo',
          },
          'comentario': r.comentario,
          'puntuacionComida': r.puntuacionComida,
          'puntuacionServicio': r.puntuacionServicio,
          'puntuacionAmbiente': r.puntuacionAmbiente,
        }).toList(),
        // Campos del restaurante
        'idRestaurante': restaurant.idRestaurante,
        'nombre': restaurant.nombre,
        'descripcion': restaurant.descripcion,
        'direccion': restaurant.direccion,
        'latitud': restaurant.latitud,
        'longitud': restaurant.longitud,
        'telefono': restaurant.telefono,
        'horarioApertura': restaurant.horarioApertura,
        'horarioCierre': restaurant.horarioCierre,
        'precioPromedio': restaurant.precioPromedio,
        'categoria': restaurant.categoria,
        'menuUrl': restaurant.menuUrl,
        'fechaRegistro': restaurant.fechaRegistro,
        'activo': restaurant.activo,
      };
    } catch (e) {
      debugPrint('❌ Error obteniendo detalles: $e');
      _errorMessage = e.toString();
      return null;
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
          _resetStats();
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
  
  /// Cargar estadísticas del restaurante (versión pública)
  /// Este método se puede llamar desde widgets externos
  Future<void> loadRestaurantStats(int idRestaurante) async {
    await _loadRestaurantStats(idRestaurante);
  }

  /// Crear una nueva reseña
  Future<bool> createReview({
    required int idUsuario,
    required int idRestaurante,
    required int puntuacionComida,
    required int puntuacionServicio,
    required int puntuacionAmbiente,
    String? comentario,
  }) async {
    try {
      debugPrint('📝 Creando nueva reseña...');
      
      final review = await _restaurantService.createReview(
        idUsuario: idUsuario,
        idRestaurante: idRestaurante,
        puntuacionComida: puntuacionComida,
        puntuacionServicio: puntuacionServicio,
        puntuacionAmbiente: puntuacionAmbiente,
        comentario: comentario,
      );

      if (review != null) {
        debugPrint('✅ Reseña creada exitosamente');
        
        // Recargar las estadísticas del restaurante
        await _loadRestaurantStats(idRestaurante);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error al crear reseña: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Actualizar una reseña existente
  Future<bool> updateReview({
    required Review review,
    required int idRestaurante,
  }) async {
    try {
      debugPrint('🔄 Actualizando reseña...');
      
      final updatedReview = await _restaurantService.updateReview(review);

      if (updatedReview != null) {
        debugPrint('✅ Reseña actualizada');
        
        // Actualizar en la lista local
        final index = _reviews.indexWhere(
          (r) => r.idCalificacion == updatedReview.idCalificacion
        );
        if (index != -1) {
          _reviews[index] = updatedReview;
        }
        
        // Recalcular estadísticas
        await _loadRestaurantStats(idRestaurante);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error al actualizar reseña: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Eliminar una reseña
  Future<bool> deleteReview({
    required int idCalificacion,
    required int idRestaurante,
  }) async {
    try {
      debugPrint('🗑️ Eliminando reseña...');
      
      final success = await _restaurantService.deleteReview(idCalificacion);

      if (success) {
        debugPrint('✅ Reseña eliminada');
        
        // Remover de la lista local
        _reviews.removeWhere((r) => r.idCalificacion == idCalificacion);
        
        // Recalcular estadísticas
        await _loadRestaurantStats(idRestaurante);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error al eliminar reseña: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Obtener reseñas de un restaurante específico
  Future<List<Review>> getRestaurantReviews(int idRestaurante) async {
    try {
      debugPrint('📋 Obteniendo reseñas del restaurante $idRestaurante');
      
      final reviews = await _restaurantService.getReviews(idRestaurante);
      
      debugPrint('✅ ${reviews.length} reseñas obtenidas');
      return reviews;
    } catch (e) {
      debugPrint('❌ Error al obtener reseñas: $e');
      return [];
    }
  }

  /// Verificar si un usuario ya ha dejado reseña en un restaurante
  Future<Review?> getUserReviewForRestaurant({
    required int idUsuario,
    required int idRestaurante,
  }) async {
    try {
      final reviews = await _restaurantService.getReviews(idRestaurante);
      
      // Buscar si el usuario ya tiene una reseña
      final userReview = reviews.firstWhere(
        (review) => review.usuario?.idUsuario == idUsuario,
        orElse: () => Review(),
      );
      
      // Si encontró una reseña válida (con ID), devolverla
      if (userReview.idCalificacion != null) {
        return userReview;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error verificando reseña del usuario: $e');
      return null;
    }
  }
  // Agregar este método en la clase RestaurantProvider

/// Calcular el promedio de calificación de un restaurante
/// Retorna un mapa con el promedio general y los promedios por categoría
Future<Map<String, dynamic>> calculateRestaurantRating(int idRestaurante) async {
  try {
    debugPrint('📊 Calculando promedio de calificación para restaurante $idRestaurante');
    
    // Obtener todas las reseñas del restaurante
    final reviews = await _restaurantService.getReviews(idRestaurante);
    
    if (reviews.isEmpty) {
      debugPrint('ℹ️ No hay reseñas para calcular promedio');
      return {
        'averageRating': 0.0,
        'averageComida': 0.0,
        'averageServicio': 0.0,
        'averageAmbiente': 0.0,
        'totalReviews': 0,
      };
    }
    
    // Variables para acumular las puntuaciones
    double totalComida = 0;
    double totalServicio = 0;
    double totalAmbiente = 0;
    double totalGeneral = 0;
    int validReviews = 0;
    
    // Sumar todas las puntuaciones
    for (var review in reviews) {
      final comida = (review.puntuacionComida ?? 0).toDouble();
      final servicio = (review.puntuacionServicio ?? 0).toDouble();
      final ambiente = (review.puntuacionAmbiente ?? 0).toDouble();
      
      // Solo contar reseñas con al menos una puntuación válida
      if (comida > 0 || servicio > 0 || ambiente > 0) {
        totalComida += comida;
        totalServicio += servicio;
        totalAmbiente += ambiente;
        
        // Promedio de esta reseña individual
        final promedioReview = (comida + servicio + ambiente) / 3;
        totalGeneral += promedioReview;
        
        validReviews++;
      }
    }
    
    // Calcular promedios
    final averageRating = validReviews > 0 ? totalGeneral / validReviews : 0.0;
    final averageComida = validReviews > 0 ? totalComida / validReviews : 0.0;
    final averageServicio = validReviews > 0 ? totalServicio / validReviews : 0.0;
    final averageAmbiente = validReviews > 0 ? totalAmbiente / validReviews : 0.0;
    
    debugPrint('✅ Promedio calculado: ${averageRating.toStringAsFixed(1)}★ ($validReviews reseñas)');
    
    return {
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'averageComida': double.parse(averageComida.toStringAsFixed(1)),
      'averageServicio': double.parse(averageServicio.toStringAsFixed(1)),
      'averageAmbiente': double.parse(averageAmbiente.toStringAsFixed(1)),
      'totalReviews': validReviews,
    };
  } catch (e) {
    debugPrint('❌ Error calculando promedio: $e');
    return {
      'averageRating': 0.0,
      'averageComida': 0.0,
      'averageServicio': 0.0,
      'averageAmbiente': 0.0,
      'totalReviews': 0,
    };
  }
}

/// Obtener el promedio de calificación de forma síncrona si ya está cargado
double getLoadedAverageRating() {
  return _averageRating;
}

/// Obtener el total de reseñas de forma síncrona si ya está cargado
int getLoadedTotalReviews() {
  return _totalReviews;
}
  }