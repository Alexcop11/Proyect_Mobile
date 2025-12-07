import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/core/services/notification_services.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/welcome_card.dart';
import 'package:rating_app/widgets/client/search.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga todos los datos iniciales en paralelo
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadRestaurants(),
      _loadFavorites(),
      _loadNotifications(),
    ]);
  }

  /// Carga todos los restaurantes
  Future<void> _loadRestaurants() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    
    try {
      // TODO: Obtener ubicación del usuario y cargar restaurantes cercanos
      await restaurantProvider.loadAllRestaurants();
    } catch (e) {
      debugPrint('❌ Error cargando restaurantes: $e');
    }
  }

  /// Carga los favoritos del usuario
  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser?.idUsuario != null) {
      try {
        await favoriteProvider.loadUserFavorites(
          authProvider.currentUser!.idUsuario!,
        );
      } catch (e) {
        debugPrint('❌ Error cargando favoritos: $e');
      }
    }
  }

  /// Inicializa el servicio de notificaciones
  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser?.idUsuario == null) {
      debugPrint('❌ No hay usuario autenticado para notificaciones');
      return;
    }

    try {
      final userId = authProvider.currentUser!.idUsuario!;
      debugPrint('👤 Inicializando notificaciones para usuario: $userId');
      
      await NotificationService().initialize();
      debugPrint('🔔 NotificationService inicializado');
      
      await NotificationService().updatePushToken(userId);
      debugPrint('📨 Push token actualizado');
    } catch (e) {
      debugPrint('❌ Error inicializando notificaciones: $e');
    }
  }

  /// Maneja la búsqueda de restaurantes
  void _handleSearch(String value) {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    if (value.isNotEmpty) {
      restaurantProvider.searchRestaurants(value);
    } else {
      _loadRestaurants();
    }
  }

  /// Navega al tab de búsqueda
  void _handleSearchTap() {
    debugPrint('🔍 Navegando al tab de búsqueda');
    // TODO: Implementar navegación al tab de búsqueda
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RestaurantProvider, FavoriteProvider>(
      builder: (context, authProvider, restaurantProvider, favoriteProvider, child) {
        // Estado de carga
        if (authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F8F8),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            ),
          );
        }

        // Estado sin autenticación
        if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
          return _buildErrorState(authProvider);
        }

        final user = authProvider.currentUser!;
        final restaurants = restaurantProvider.restaurants;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: const AppBarCustom(title: 'FoodFinder'),
          body: RefreshIndicator(
            onRefresh: _loadInitialData,
            color: const Color(0xFFFF6B6B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Card de bienvenida
                  WelcomeCard(
                    nombre: user.nombre,
                    initiales: user.iniciales,
                  ),

                  const SizedBox(height: 16),

                  // Buscador
                  Search(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    onSearchTap: _handleSearchTap,
                  ),

                  const SizedBox(height: 24),

                  // Sección: Restaurantes Cerca de Ti
                  _buildSectionHeader('Restaurantes Cerca de Ti'),
                  const SizedBox(height: 8),
                  _buildNearbyRestaurantsList(
                    restaurants,
                    restaurantProvider,
                  ),

                  const SizedBox(height: 32),

                  // Sección: Todos los Restaurantes
                  _buildAllRestaurantsHeader(restaurants.length),
                  const SizedBox(height: 8),
                  _buildAllRestaurantsList(restaurants, restaurantProvider),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget para el estado de error
  Widget _buildErrorState(AuthProvider authProvider) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFFF6B6B),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No se pudo cargar la información del usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Volver al Login'),
            ),
          ],
        ),
      ),
    );
  }

  /// Header de sección simple
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  /// Header de la sección de todos los restaurantes con contador
  Widget _buildAllRestaurantsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(
                Icons.restaurant,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Todos los Restaurantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          Text(
            '$count lugares',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de restaurantes cercanos (primeros 3)
  Widget _buildNearbyRestaurantsList(
    List restaurants,
    RestaurantProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    if (restaurants.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_outlined,
        message: 'No se encontraron restaurantes cercanos',
      );
    }

    final nearbyRestaurants = restaurants.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: nearbyRestaurants.map((restaurant) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(restaurant: restaurant),
          );
        }).toList(),
      ),
    );
  }

  /// Lista completa de restaurantes
  Widget _buildAllRestaurantsList(
    List restaurants,
    RestaurantProvider provider,
  ) {
    if (provider.isLoading || restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: restaurants.map((restaurant) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(restaurant: restaurant),
          );
        }).toList(),
      ),
    );
  }

  /// Widget para estado vacío
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}