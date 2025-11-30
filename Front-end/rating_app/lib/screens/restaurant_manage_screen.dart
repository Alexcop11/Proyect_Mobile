import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/screens/edit_restaurant.dart';
import 'package:rating_app/screens/edit_user_restaurant.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/register_restaurant.dart';
import 'package:rating_app/screens/restaurant_reviews.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';

class Restaurant_manage_Screen extends StatefulWidget {
  const Restaurant_manage_Screen({super.key});

  @override
  State<Restaurant_manage_Screen> createState() =>
      _Restaurant_manage_ScreenState();
}

class _Restaurant_manage_ScreenState extends State<Restaurant_manage_Screen> {
  late final AuthService _authService;
  Map<String, dynamic>? ownerData;

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
              return Center(child: Text("Error: ${snapshot.error}"));
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantReviews(),
                      ),
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
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.restaurant,
                                    color: Colors.redAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "Información del Usuario",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditProfileScreen(
                                            idUsuario:
                                                restaurantData!['usuarioPropietario']['idUsuario'],
                                            nombre:
                                                restaurantData!['usuarioPropietario']['nombre'],
                                            apellido:
                                                restaurantData!['usuarioPropietario']['apellido'],
                                            email:
                                                restaurantData!['usuarioPropietario']['email'],
                                            telefono:
                                                restaurantData!['usuarioPropietario']['telefono'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2),
                            _buildOwnerCard(
                              "${restaurantData!['usuarioPropietario']['nombre'] ?? ''} ${restaurantData!['usuarioPropietario']['apellido'] ?? ''}",
                              restaurantData['usuarioPropietario']['email'] ??
                                  '',
                              restaurantData['usuarioPropietario']['telefono'] ??
                                  'No disponible',
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const Text(
                                  "Tu Restaurante",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditRestaurantScreen(
                                          restaurantData: restaurantData,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _infobuild(
                              "Nombre",
                              restaurantData["nombre"],
                              restaurantData["descripcion"],
                            ),
                            _infodirection(
                              "Dirección",
                              restaurantData['direccion'],
                            ),
                            _infoTime(
                              "Horario",
                              restaurantData['horarioApertura'],
                              restaurantData['horarioCierre'],
                            ),
                            _infophone("Teléfono", restaurantData['telefono']),
                            _buildCard(
                              "Info Extra",
                              restaurantData['precioPromedio'].toString(),
                              restaurantData['categoria'],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildOwnerCard(String? nombre, String? correo, String? telefono) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            if (nombre != null)
              Text("Nombre: $nombre", style: const TextStyle(fontSize: 16)),
            if (correo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Correo Electrónico: $correo",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (telefono != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Teléfono: ${telefono.isEmpty ? 'No disponible' : telefono}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String? value, String? value2) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_offer,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (value != null && value.isNotEmpty)
              Text(
                "Precio Promedio: \$${value}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            if (value2 != null && value2.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Categoría: $value2",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoTime(String title, String? value, String? value_2) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100], // fondo elegante
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.watch, color: Colors.redAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Horas de servicio",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Apertura: ${value}" ?? "No disponible",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Cierre: ${value_2}" ?? "No disponible",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infophone(String title, String? value) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100], // fondo elegante
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.phone_in_talk,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "Telefono",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value ?? "No disponible",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infodirection(String title, String? value) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100], // fondo elegante
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_city,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "Ubicacion",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value ?? "No disponible",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infobuild(String title, String? value, String? value_2) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100], // fondo elegante
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  value ?? "No disponible",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Descripcion"),
            const SizedBox(height: 12),
            Text(
              value_2 ?? "No disponible",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
