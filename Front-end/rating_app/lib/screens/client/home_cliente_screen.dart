import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/welcome_card.dart';
import 'package:rating_app/widgets/client/search.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
Future<void> _loadData() async {
  await _loadRestaurants();
  await _loadFavorites(); // Cargar favoritos después de restaurantes
}

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

  Future<void> _loadRestaurants() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    // TODO: Obtener ubicación del usuario y cargar restaurantes cercanos
    // Por ahora cargamos todos los restaurantes
    await restaurantProvider.loadAllRestaurants();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await favoriteProvider.loadUserFavorites(
        authProvider.currentUser!.idUsuario!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RestaurantProvider, FavoriteProvider>(
      builder:
          (context, authProvider, restaurantProvider, favoriteProvider, child) {
            // Mostrar loading mientras se carga el usuario
            if (authProvider.isLoading) {
              return const Scaffold(
                backgroundColor: Color(0xFFF8F8F8),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                ),
              );
            }

            // Si no está autenticado o no hay usuario, mostrar mensaje
            if (!authProvider.isAuthenticated ||
                authProvider.currentUser == null) {
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
                      const Text(
                        'No se pudo cargar la información del usuario',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                        ),
                        child: const Text('Volver al Login'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final user = authProvider.currentUser!;
            final restaurants = restaurantProvider.restaurants;

            return Scaffold(
              backgroundColor: const Color(0xFFF8F8F8),
              appBar: AppBarCustom(
                title: 'FoodFinder',
                
              ),
              body: RefreshIndicator(
                onRefresh: _loadRestaurants,
                color: const Color(0xFFFF6B6B),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Card de bienvenida con datos del usuario
                      WelcomeCard(
                        nombre: user.nombre,
                        initiales: user.iniciales,
                      ),

                      const SizedBox(height: 16),

                      // Buscador
                      Search(
                        controller: _searchController,
                        onChanged: (value) {
                          // Buscar en tiempo real
                          if (value.isNotEmpty) {
                            restaurantProvider.searchRestaurants(value);
                          } else {
                            _loadRestaurants();
                          }
                        },
                        onSearchTap: () {
                          debugPrint(
                            'Search tapped - Cambiar a tab de búsqueda',
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Título de sección - Restaurantes Cerca de Ti
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Restaurantes Cerca de Ti',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Lista de restaurantes cercanos (primeros 3)
                      _buildNearbyRestaurantsList(
                        restaurants,
                        restaurantProvider,
                      ),

                      const SizedBox(height: 32),

                      // Título de sección - Todos los Restaurantes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFFFF6B6B),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
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
                              '${restaurants.length} lugares',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Lista completa de restaurantes
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron restaurantes cercanos',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar solo los primeros 3 restaurantes
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

  Widget _buildAllRestaurantsList(
    List restaurants,
    RestaurantProvider provider,
  ) {
    if (provider.isLoading) {
      return const SizedBox.shrink();
    }

    if (restaurants.isEmpty) {
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
}
