import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await favoriteProvider.loadUserFavorites(authProvider.currentUser!.idUsuario!);
    }
  }

  Future<void> _onFavoriteTap(int restaurantId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    final success = await favoriteProvider.removeFavorite(
      userId: authProvider.currentUser!.idUsuario!,
      restaurantId: restaurantId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurante eliminado de favoritos'),
          backgroundColor: Color(0xFFFF6B6B),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favoriteProvider.errorMessage ?? 'Error al eliminar favorito'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onVerRestaurante(int restaurantId) {
    // TODO: Navegar a detalle del restaurante
    debugPrint('Ver restaurante ID: $restaurantId');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, FavoriteProvider>(
      builder: (context, authProvider, favoriteProvider, child) {
        final favorites = favoriteProvider.favorites;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBarCustom(
            title: 'Mis Favoritos',
            onNotificationTap: () {
              debugPrint('Notificaciones tapped');
            },
          ),
          body: favoriteProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B6B),
                  ),
                )
              : favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes favoritos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega restaurantes a tus favoritos',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      color: const Color(0xFFFF6B6B),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${favorites.length} ${favorites.length == 1 ? 'restaurante' : 'restaurantes'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: favorites.map((favorite) {
                                  final restaurant = favorite.restaurante;
                                  if (restaurant == null) return const SizedBox.shrink();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: RestaurantCard(
                                      nombre: restaurant.nombre,
                                      tipo: restaurant.categoria,
                                      calificacion: restaurant.calificacionPromedio ?? 0.0,
                                      reviews: restaurant.numeroReviews ?? 0,
                                      ubicacion: restaurant.direccion,
                                      distancia: restaurant.getDistanceFrom(0.0, 0.0),
                                      tiempo: restaurant.getEstimatedTime(),
                                      foto: restaurant.menuUrl.isNotEmpty
                                          ? restaurant.menuUrl
                                          : 'assets/images/restaurant_placeholder.jpg',
                                      isFavorite: true,
                                      isOpen: restaurant.isOpenNow,
                                      onFavoriteTap: (isFavorite) {
                                        _onFavoriteTap(restaurant.idRestaurante!);
                                      },
                                      onVerRestaurante: () {
                                        _onVerRestaurante(restaurant.idRestaurante!);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}