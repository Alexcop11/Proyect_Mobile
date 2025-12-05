import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  
  const FavoritesScreen({
    Key? key,
    this.onNavigateToHome,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => false; // No mantener el estado cuando no está visible

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  // Este método se ejecuta cada vez que la pantalla se vuelve visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar favoritos cada vez que la pantalla se hace visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      debugPrint('🔄 Cargando favoritos del usuario ${authProvider.currentUser!.idUsuario}');
      await favoriteProvider.loadUserFavorites(
        authProvider.currentUser!.idUsuario!,
      );
      debugPrint('✅ Favoritos cargados: ${favoriteProvider.favorites.length}');
    } else {
      debugPrint('⚠️ No hay usuario autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin
    
    return Consumer2<AuthProvider, FavoriteProvider>(
      builder: (context, authProvider, favoriteProvider, child) {
        final favorites = favoriteProvider.favorites;

        // Debug: Mostrar información de favoritos
        debugPrint('📊 FavoritesScreen build - Favoritos: ${favorites.length}');
        debugPrint('📊 Estado de carga: ${favoriteProvider.isLoading}');

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBarCustom(
            title: 'Mis Favoritos',
          ),
          body: favoriteProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                )
              : favorites.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(favorites, favoriteProvider),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToHome,
            icon: const Icon(Icons.search),
            label: const Text('Buscar Restaurantes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    // Usar el callback si está disponible
    if (widget.onNavigateToHome != null) {
      widget.onNavigateToHome!();
    } else {
      debugPrint('⚠️ Callback onNavigateToHome no está configurado');
    }
  }

  Widget _buildFavoritesList(
    List favorites,
    FavoriteProvider favoriteProvider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: const Color(0xFFFF6B6B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${favorites.length} ${favorites.length == 1 ? 'restaurante' : 'restaurantes'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loadFavorites,
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: Color(0xFFFF6B6B),
                    ),
                    label: const Text(
                      'Actualizar',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: favorites.map((favorite) {
                  final restaurant = favorite.restaurante;
                  
                  // Debug: Verificar cada restaurante
                  debugPrint('🍽️ Restaurante: ${restaurant?.nombre ?? "null"} - ID: ${restaurant?.idRestaurante}');
                  
                  if (restaurant == null) {
                    debugPrint('⚠️ Restaurante nulo encontrado en favorito');
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RestaurantCard(
                      key: ValueKey(restaurant.idRestaurante),
                      restaurant: restaurant,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}