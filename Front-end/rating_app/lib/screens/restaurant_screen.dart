import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/screens/restaurant_reviews.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/custom_card.dart';
import 'package:rating_app/widgets/custom_rate.dart';
import 'package:rating_app/widgets/custom_rating.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del restaurante al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );

      if (authProvider.email != null) {
        restaurantProvider.loadOwnerRestaurant(authProvider.email!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

        // Mostrar loading mientras carga
        if (restaurantProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),
          );
        }

        // Si hay error
        if (restaurantProvider.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${restaurantProvider.errorMessage}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.email != null) {
                        restaurantProvider.loadOwnerRestaurant(
                          authProvider.email!,
                        );
                      }
                    },
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            ),
          );
        }

        // Si no tiene restaurante
        final restaurant = restaurantProvider.ownerRestaurant;
        if (restaurant == null) {
          return const Scaffold(
            body: Center(
              child: Text("No tienes restaurante registrado"),
            ),
          );
        }

        return Navigationscaffold(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantReviews(),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Restaurant_manage_Screen(),
                  ),
                );
                break;
            }
          },
          appBar: AppBar(
            title: const Text("FoodFinder"),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              if (authProvider.email != null) {
                await restaurantProvider.loadOwnerRestaurant(
                  authProvider.email!,
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 12,
                      ),
                      child: custom_card(
                        nombre: authProvider.currentUser?.nombre ?? 'Usuario',
                        restaurante: restaurant.nombre,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: custom_rating(
                            icon: Icons.favorite,
                            iconColor: Colors.redAccent,
                            title: "Favoritos",
                            count: restaurantProvider.favoritesCount.toString(),
                          ),
                        ),
                        Expanded(
                          child: custom_rating(
                            icon: Icons.reviews,
                            iconColor: Colors.amberAccent,
                            title: "Reseñas",
                            count: restaurantProvider.totalReviews.toString(),
                          ),
                        ),
                      ],
                    ),
                    custom_rate(
                      rating: restaurantProvider.averageRating,
                      totalReviews: restaurantProvider.totalReviews,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RestaurantReviews(),
                          ),
                        );
                      },
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