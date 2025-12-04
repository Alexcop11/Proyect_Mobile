import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/edit_restaurant.dart';
import 'package:rating_app/screens/edit_profile_screen.dart';
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
  @override
  void initState() {
    super.initState();
    // Cargar el restaurante del propietario cuando se inicializa la pantalla
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

        // Mostrar loading mientras carga el restaurante
        if (restaurantProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("FoodFinder"),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.redAccent,
              ),
            ),
          );
        }

        final restaurant = restaurantProvider.ownerRestaurant;

        // Si no tiene restaurante, mostrar pantalla de registro
        if (restaurant == null) {
          return const RegisterRestaurant();
        }

        // Convertir Restaurant a Map para mantener compatibilidad con los widgets existentes
        final restaurantData = {
          'idRestaurante': restaurant.idRestaurante,
          'nombre': restaurant.nombre,
          'descripcion': restaurant.descripcion,
          'direccion': restaurant.direccion,
          'latitud': restaurant.latitud,
          'longitud': restaurant.longitud,
          'telefono': restaurant.telefono,
          'horarioApertura': restaurant.horarioApertura,
          'horarioCierre': restaurant.horarioCierre,
          'precioPromedio': restaurant.precioPromedio,
          'categoria': restaurant.categoria,
          'menuUrl': restaurant.menuUrl,
          'fechaRegistro': restaurant.fechaRegistro,
          'activo': restaurant.activo,
        };

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
          child: RefreshIndicator(
            onRefresh: () async {
              if (authProvider.email != null) {
                await restaurantProvider.loadOwnerRestaurant(
                  authProvider.email!,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de Información del Usuario
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
                                  Icons.person,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      "Información del Usuario",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(
                                          idUsuario: authProvider.currentUser?.idUsuario ?? 0,
                                          nombre: authProvider.currentUser?.nombre,
                                          apellido: authProvider.currentUser?.apellido,
                                          email: authProvider.currentUser?.email,
                                          telefono: authProvider.currentUser?.telefono,
                                        ),
                                      ),
                                    );
                                    
                                    // Si se actualizó, recargar datos del usuario
                                    if (result == true) {
                                      await authProvider.loadCurrentUser();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildOwnerCard(
                            "${authProvider.currentUser?.nombre ?? ''} ${authProvider.currentUser?.apellido ?? ''}",
                            authProvider.currentUser?.email ?? '',
                            authProvider.currentUser?.telefono ?? 'No disponible',
                          ),
                        ],
                      ),
                    ),
                    
                    // Card de Información del Restaurante
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
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditRestaurantScreen(
                                        restaurantData: restaurantData,
                                      ),
                                    ),
                                  );
                                  
                                  // Si se actualizó, recargar datos
                                  if (result == true && authProvider.email != null) {
                                    await restaurantProvider.loadOwnerRestaurant(
                                      authProvider.email!,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infobuild(
                            "Nombre",
                            restaurant.nombre,
                            restaurant.descripcion,
                          ),
                          _infodirection(
                            "Dirección",
                            restaurant.direccion,
                          ),
                          _infoTime(
                            "Horario",
                            restaurant.horarioApertura,
                            restaurant.horarioCierre,
                          ),
                          _infophone("Teléfono", restaurant.telefono),
                          _buildCard(
                            "Info Extra",
                            restaurant.precioPromedio.toString(),
                            restaurant.categoria,
                          ),
                        ],
                      ),
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
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.watch, color: Colors.redAccent, size: 28),
                const SizedBox(width: 12),
                const Text(
                  "Horas de servicio",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Apertura: ${value ?? 'No disponible'}",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Cierre: ${value_2 ?? 'No disponible'}",
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
          color: Colors.grey[100],
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
                const Text(
                  "Telefono",
                  style: TextStyle(
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
          color: Colors.grey[100],
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
                const Text(
                  "Ubicacion",
                  style: TextStyle(
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
          color: Colors.grey[100],
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
            const Text("Descripcion"),
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