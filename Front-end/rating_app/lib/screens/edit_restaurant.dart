import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/models/restaurant.dart';
import 'package:rating_app/screens/auth_wrapper.dart';

class EditRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const EditRestaurantScreen({super.key, required this.restaurantData});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController horarioAperturaController;
  late TextEditingController horarioCierreController;
  late TextEditingController precioPromedioController;
  late TextEditingController menuUrlController;

  String? selectedCategoria;

  final List<String> categorias = [
    'Mexicana',
    'Italiana',
    'Japonesa',
    'China',
    'Americana',
    'Vegetariana',
    'Mariscos',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.restaurantData;
    nombreController = TextEditingController(text: data['nombre'] ?? '');
    descripcionController = TextEditingController(text: data['descripcion'] ?? '');
    direccionController = TextEditingController(text: data['direccion'] ?? '');
    telefonoController = TextEditingController(text: data['telefono'] ?? '');
    horarioAperturaController = TextEditingController(text: data['horarioApertura'] ?? '');
    horarioCierreController = TextEditingController(text: data['horarioCierre'] ?? '');
    precioPromedioController = TextEditingController(text: data['precioPromedio']?.toString() ?? '');
    selectedCategoria = data['categoria'];
    // Mantener compatibilidad con ambos nombres de campo
    menuUrlController = TextEditingController(text: data['menuUrl'] ?? data['menuURL'] ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    horarioAperturaController.dispose();
    horarioCierreController.dispose();
    precioPromedioController.dispose();
    menuUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser?.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Usuario no autenticado")),
      );
      return;
    }

    // Crear objeto Restaurant actualizado
    final updatedRestaurant = Restaurant(
      idRestaurante: widget.restaurantData['idRestaurante'],
      idUsuarioPropietario: authProvider.currentUser!.idUsuario!,
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      direccion: direccionController.text,
      latitud: widget.restaurantData['latitud']?.toDouble() ?? 0.0,
      longitud: widget.restaurantData['longitud']?.toDouble() ?? 0.0,
      telefono: telefonoController.text,
      horarioApertura: horarioAperturaController.text,
      horarioCierre: horarioCierreController.text,
      precioPromedio: double.tryParse(precioPromedioController.text) ?? 0.0,
      categoria: selectedCategoria ?? '',
      menuUrl: menuUrlController.text,
      fechaRegistro: widget.restaurantData['fechaRegistro'],
      activo: true,
    );

    final success = await restaurantProvider.updateRestaurant(updatedRestaurant);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Restaurante actualizado correctamente")),
      );
      Navigator.pop(context, true); // Retornar true para indicar que se actualizó
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restaurantProvider.errorMessage ?? "Error al actualizar restaurante",
          ),
        ),
      );
    }
  }

  InputDecoration _styledDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: Colors.redAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Widget _buildStyledField(TextEditingController controller, String label, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: _styledDecoration(label, icon, hint: hint),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: selectedCategoria,
        items: categorias.map((cat) {
          return DropdownMenuItem(value: cat, child: Text(cat));
        }).toList(),
        onChanged: (value) => setState(() => selectedCategoria = value),
        decoration: _styledDecoration("Tipo de Cocina", Icons.fastfood, hint: "Seleccione un tipo de comida"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        return Scaffold(
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
                    MaterialPageRoute(builder: (_) => AuthWrapper()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  "Información Básica",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(nombreController, "Nombre del Restaurante", Icons.restaurant),
                _buildStyledField(descripcionController, "Descripción", Icons.description),
                _buildDropdownField(),

                const SizedBox(height: 16),
                const Text(
                  "Información de Contacto",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(telefonoController, "Teléfono del Negocio", Icons.phone),

                const SizedBox(height: 16),
                const Text(
                  "Ubicación",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(direccionController, "Dirección", Icons.location_on),

                const SizedBox(height: 16),
                const Text(
                  "Horarios de Atención",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(horarioAperturaController, "Abre a", Icons.access_time),
                _buildStyledField(horarioCierreController, "Cierra a", Icons.access_time),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Horario general de atención (aplica para todos los días por ahora)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Precios",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(
                  precioPromedioController,
                  "Precio Promedio por Persona (\$)",
                  Icons.attach_money,
                  hint: "Aproximadamente cuánto gasta un cliente en promedio",
                ),

                const SizedBox(height: 16),
                const Text(
                  "Menú",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStyledField(
                  menuUrlController,
                  "URL del Menú (Opcional)",
                  Icons.link,
                  hint: "Link a tu menú digital",
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: restaurantProvider.isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 4,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: restaurantProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Guardar Cambios",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
}