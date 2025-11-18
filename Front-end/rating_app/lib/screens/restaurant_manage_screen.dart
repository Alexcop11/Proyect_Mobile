import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/register_restaurant.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart'; // 👈 tu pantalla de registro

class Restaurant_manage_Screen extends StatelessWidget {
  const Restaurant_manage_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: authProvider.checkRestaurantStatus(authProvider.email!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("❌ Error: ${snapshot.error}"));
            }

            final restaurantData = snapshot.data;

            if (restaurantData == null) {
              return const RegisterRestaurant();
            }

            return Navigationscaffold(
              currentIndex: 2,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantScreen(),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(
                      context,
                      '/RestaurantReseñas',
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Restaurant_manage_Screen(),
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
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tu Restaurante",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCard("Nombre", restaurantData['nombre']),
                      _buildCard("Descripción", restaurantData['descripcion']),
                      _buildCard("Dirección", restaurantData['direccion']),
                      _buildCard("Teléfono", restaurantData['telefono']),
                      _buildCard(
                        "Horario Apertura",
                        restaurantData['horarioApertura'],
                      ),
                      _buildCard(
                        "Horario Cierre",
                        restaurantData['horarioCierre'],
                      ),
                      _buildCard(
                        "Precio Promedio",
                        restaurantData['precioPromedio'].toString(),
                      ),
                      _buildCard("Categoría", restaurantData['categoria']),
                      _buildCard("Menú URL", restaurantData['menuUrl']),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(String title, String? value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? "No disponible"),
      ),
    );
  }
}
