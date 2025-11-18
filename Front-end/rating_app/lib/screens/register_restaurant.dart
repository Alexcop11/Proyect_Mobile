import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';

class RegisterRestaurant extends StatefulWidget {
  const RegisterRestaurant({super.key});

  @override
  State<RegisterRestaurant> createState() =>
      Registerrestaurant();
}

class Registerrestaurant extends State<RegisterRestaurant> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final direccionController = TextEditingController();
  final telefonoController = TextEditingController();
  final horarioAperturaController = TextEditingController();
  final horarioCierreController = TextEditingController();
  final precioPromedioController = TextEditingController();
  final categoriaController = TextEditingController();
  final menuUrlController = TextEditingController();

  double? latitud;
  double? longitud;
  bool isGettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => isGettingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitud = position.latitude;
        longitud = position.longitude;
        isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📍 Ubicación guardada")),
      );
    } catch (e) {
      debugPrint("❌ Error al obtener ubicación: $e");
      setState(() => isGettingLocation = false);
    }
  }

  Future<void> _handleCreateRestaurant(AuthProvider authProvider) async {
    final success = await authProvider.createRestaurant(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      direccion: direccionController.text,
      latitud: latitud ?? 0.0,
      longitud: longitud ?? 0.0,
      telefono: telefonoController.text,
      horarioApertura: horarioAperturaController.text,
      horarioCierre: horarioCierreController.text,
      precioPromedio: double.tryParse(precioPromedioController.text) ?? 0.0,
      categoria: categoriaController.text,
      menuUrl: menuUrlController.text,
      fechaRegistro: DateTime.now().toIso8601String(),
      activo: true,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Restaurante creado correctamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${authProvider.errorMessage ?? 'No se pudo crear'}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

        return Navigationscaffold(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterRestaurant(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/RestaurantReseñas');
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RestaurantScreen()),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Crear Restaurante",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nombreController,
                  decoration: _inputDecoration("Nombre"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: _inputDecoration("Descripción"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: direccionController,
                  decoration: _inputDecoration("Dirección"),
                ),
                const SizedBox(height: 16),

                // Botón grande para ubicación
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_on, size: 28,color: Colors.white,),
                    label: Text(
                      
                      isGettingLocation
                          ? "Obteniendo ubicación..."
                          : "Usar mi ubicación",
                      style: const TextStyle(fontSize: 18,
                      color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(  
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isGettingLocation ? null : _getCurrentLocation,
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: telefonoController,
                  decoration: _inputDecoration("Teléfono"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: horarioAperturaController,
                  decoration: _inputDecoration("Horario Apertura (HH:mm)"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: horarioCierreController,
                  decoration: _inputDecoration("Horario Cierre (HH:mm)"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: precioPromedioController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Precio Promedio"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoriaController,
                  decoration: _inputDecoration("Categoría"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: menuUrlController,
                  decoration: _inputDecoration("URL del Menú"),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => _handleCreateRestaurant(authProvider),
                    child: const Text(
                      "Registrar Restaurante",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}