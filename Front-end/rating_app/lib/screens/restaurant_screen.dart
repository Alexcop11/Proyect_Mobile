import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/services/auth_service.dart';
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
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: authProvider.checkRestaurantStatus(authProvider.email!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text("Error: ${snapshot.error}")),
              );
            }

            final data = snapshot.data;

            if (data == null) {
              return const Scaffold(
                body: Center(child: Text("No tienes restaurante registrado")),
              );
            }

            final summary = data["reviewsSummary"] as Map<String, dynamic>;
            final averageRating = (summary["average"] ?? 0.0).toDouble();
            final restaurante = data["restaurante"];
            final favoritos = data["favoritos"];

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
                        nombre: "${authProvider.nombre ?? 'Usuario'}",
                        restaurante: "${data['nombre'] ?? ''}",
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: custom_rating(
                            icon: Icons.favorite,
                            iconColor: Colors.redAccent,
                            title: "Favoritos",
                            count: (data['favoritesCount'] ?? 0).toString(),
                          ),
                        ),
                        Expanded(
                          child: custom_rating(
                            icon: Icons.reviews,
                            iconColor: Colors.amberAccent,
                            title: "Reseñas",
                            count: (data['reviewsCount'] ?? 0).toString(),
                          ),
                        ),
                      ],
                    ),
                    custom_rate(
                      rating: (averageRating ?? 0.0),
                      totalReviews: (data['reviewsCount'] ?? 0),
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
            );
          },
        );
      },
    );
  }
}
