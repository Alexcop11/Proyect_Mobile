import 'package:flutter/material.dart';
import 'package:rating_app/core/services/favorite_service.dart';
import 'package:rating_app/core/services/notification_services.dart';
import 'package:rating_app/models/favorite.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Favorite> _favorites = [];

  // Map para cachear el estado de favoritos por restaurante
  final Map<int, bool> _favoriteStatus = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Favorite> get favorites => _favorites;

  FavoriteProvider(this._favoriteService);

  /// Verificar si un restaurante está en favoritos
  bool isFavorite(int restaurantId) {
    return _favoriteStatus[restaurantId] ?? false;
  }

  /// Agregar restaurante a favoritos
  Future<bool> addFavorite({
    required int userId,
    required int restaurantId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('❤️ Agregando restaurante $restaurantId a favoritos');

      final favorite = await _favoriteService.addFavorite(
        userId: userId,
        restaurantId: restaurantId,
      );

      _favorites.add(favorite);
      _favoriteStatus[restaurantId] = true;

      debugPrint('✅ Favorito agregado exitosamente');

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al agregar favorito: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eliminar favorito
  Future<bool> removeFavorite({
    required int userId,
    required int restaurantId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('💔 Eliminando restaurante $restaurantId de favoritos');

      final success = await _favoriteService.removeFavorite(
        userId: userId,
        restaurantId: restaurantId,
      );

      if (success) {
        _favorites.removeWhere(
          (f) => f.restaurante?.idRestaurante == restaurantId,
        );
        _favoriteStatus[restaurantId] = false;

        debugPrint('✅ Favorito eliminado exitosamente');
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al eliminar favorito: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorito (agregar o eliminar)
  Future<bool> toggleFavorite({
    required int userId,
    required int restaurantId,
  }) async {
    final isFav = isFavorite(restaurantId);

    if (isFav) {
      return await removeFavorite(
        userId: userId,
        restaurantId: restaurantId,
      );
    } else {
      return await addFavorite(
        userId: userId,
        restaurantId: restaurantId,
      );
    }
  }

  /// Cargar favoritos del usuario
  Future<void> loadUserFavorites(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📋 Cargando favoritos del usuario $userId');

      _favorites = await _favoriteService.getUserFavorites(userId);

      // Actualizar el map de estado
      _favoriteStatus.clear();
      for (var favorite in _favorites) {
        if (favorite.restaurante?.idRestaurante != null) {
          _favoriteStatus[favorite.restaurante!.idRestaurante!] = true;
        }
      }

      debugPrint('✅ ${_favorites.length} favoritos cargados');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ Error al cargar favoritos: $_errorMessage');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar estado de favorito desde el servidor
  Future<bool> checkFavoriteStatus({
    required int userId,
    required int restaurantId,
  }) async {
    try {
      final isFav = await _favoriteService.isFavorite(
        userId: userId,
        restaurantId: restaurantId,
      );

      _favoriteStatus[restaurantId] = isFav;
      notifyListeners();

      return isFav;
    } catch (e) {
      debugPrint('❌ Error al verificar favorito: $e');
      return false;
    }
  }

  /// Obtener cantidad de favoritos del usuario
  Future<int> getUserFavoritesCount(int userId) async {
    try {
      return await _favoriteService.countUserFavorites(userId);
    } catch (e) {
      debugPrint('❌ Error al contar favoritos: $e');
      return 0;
    }
  }

  /// Obtener cantidad de usuarios que tienen un restaurante en favoritos
  Future<int> getRestaurantFavoritesCount(int restaurantId) async {
    try {
      return await _favoriteService.countRestaurantFavorites(restaurantId);
    } catch (e) {
      debugPrint('❌ Error al contar favoritos del restaurante: $e');
      return 0;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearFavorites() {
    _favorites = [];
    _favoriteStatus.clear();
    notifyListeners();
  }
}