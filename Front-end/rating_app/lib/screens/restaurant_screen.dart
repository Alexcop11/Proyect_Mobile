import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/main_restaurant_navigation.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantData();
    });
  }

  Future<void> _loadRestaurantData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    if (authProvider.email != null) {
      await restaurantProvider.loadOwnerRestaurant(
        authProvider.email!,
        authProvider,
      );
    }
  }

  Future<void> _handleRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    if (authProvider.email != null) {
      await Future.wait([
        restaurantProvider.loadOwnerRestaurant(
          authProvider.email!,
          authProvider,
        ),
        authProvider.initializeUserServices(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        // Verificar autenticación
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Estado de carga
        if (restaurantProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),
          );
        }

        // Estado de error
        if (restaurantProvider.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${restaurantProvider.errorMessage}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Verificar si tiene restaurante
        final restaurant = restaurantProvider.ownerRestaurant;
        if (restaurant == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No tienes restaurante registrado",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Registra tu restaurante para comenzar",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Vista principal del restaurante
        return Scaffold(
          appBar: const AppBarCustom(title: 'FoodFinder'),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de saludo
                    _buildGreetingCard(
                      nombre: authProvider.currentUser?.nombre ?? 'Usuario',
                      restaurante: restaurant.nombre,
                    ),

                    const SizedBox(height: 16),

                    // Tarjetas de estadísticas
                    _buildStatsRow(restaurantProvider),

                    const SizedBox(height: 24),

                    // Sección de valoración
                    const Text(
                      'VALORACIÓN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card de valoración
                    _buildRatingCard(
                      rating: restaurantProvider.averageRating,
                      totalReviews: restaurantProvider.totalReviews,
                      onPressed: _navigateToReviews,
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

  Widget _buildStatsRow(RestaurantProvider restaurantProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_border,
            iconColor: const Color(0xFFFF6B6B),
            label: 'Agregado a favoritos',
            count: restaurantProvider.favoritesCount.toString(),
          ),
        ),
        Container(
          width: 1,
          height: 80,
          color: const Color(0xFFE0E0E0),
        ),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_border,
            iconColor: const Color(0xFFFFC107),
            label: 'Reseñas totales',
            count: restaurantProvider.totalReviews.toString(),
          ),
        ),
      ],
    );
  }

  void _navigateToReviews() {
    final navigationState = context.findAncestorStateOfType<
      State<MainRestaurantNavigation>
    >();
    
    if (navigationState != null) {
      (navigationState as dynamic).navigateToReviews();
    }
  }

  Widget _buildGreetingCard({
    required String nombre,
    required String restaurante,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $nombre',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            restaurante,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard({
    required double rating,
    required int totalReviews,
    required VoidCallback onPressed,
  }) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Estrellas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              if (index < fullStars) {
                return const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 32,
                );
              } else if (index == fullStars && hasHalfStar) {
                return const Icon(
                  Icons.star_half,
                  color: Color(0xFFFFC107),
                  size: 32,
                );
              } else {
                return const Icon(
                  Icons.star_border,
                  color: Color(0xFFE0E0E0),
                  size: 32,
                );
              }
            }),
          ),

          const SizedBox(height: 12),

          // Rating número
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 8),

          // Texto de reseñas
          Text(
            'Basado en $totalReviews reseñas',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),

          const SizedBox(height: 20),

          // Botón de ver reseñas
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ver reseñas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}