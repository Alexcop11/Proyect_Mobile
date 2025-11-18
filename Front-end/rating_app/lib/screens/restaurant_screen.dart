import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/custom_card.dart';
import 'package:rating_app/widgets/custom_rate.dart';
import 'package:rating_app/widgets/custom_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return Navigationscaffold(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Inicio restaurante
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RestaurantScreen()),
                );
                break;
              case 1:
                // Reseñas restaurante
                Navigator.pushReplacementNamed(context, '/RestaurantReseñas');
                break;
              case 2:
                // Configuración restaurante
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Restaurant_manage_Screen()),
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
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => AuthWrapper()),
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
                    restaurante: "La casa de los shidoris",
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: custom_rating(
                        icon: Icons.favorite,
                        iconColor: Colors.redAccent,
                        title: "Favoritos",
                        count: 321,
                      ),
                    ),
                    Expanded(
                      child: custom_rating(
                        icon: Icons.reviews,
                        iconColor: Colors.amberAccent,
                        title: "Reseñas",
                        count: 753,
                      ),
                    ),
                  ],
                ),
                custom_rate(rating: 4.8, totalReviews: 127, onPressed: () {}),
              ],
            ),
          ),
        );
      },
    );
  }
}
