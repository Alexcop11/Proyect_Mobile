import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
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
    nombreController = TextEditingController(text: data['nombre']);
    descripcionController = TextEditingController(text: data['descripcion']);
    direccionController = TextEditingController(text: data['direccion']);
    telefonoController = TextEditingController(text: data['telefono']);
    horarioAperturaController = TextEditingController(
      text: data['horarioApertura'],
    );
    horarioCierreController = TextEditingController(
      text: data['horarioCierre'],
    );
    precioPromedioController = TextEditingController(
      text: data['precioPromedio'].toString(),
    );
    selectedCategoria = data['categoria'];
    menuUrlController = TextEditingController(text: data['menuUrl']);
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateRestaurant(
      idRestaurante: widget.restaurantData['idRestaurante'],
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      direccion: direccionController.text,
      latitud: widget.restaurantData['latitud'],
      longitud: widget.restaurantData['longitud'],
      telefono: telefonoController.text,
      horarioApertura: horarioAperturaController.text,
      horarioCierre: horarioCierreController.text,
      precioPromedio: double.tryParse(precioPromedioController.text) ?? 0,
      categoria: selectedCategoria ?? '',
      menuUrl: menuUrlController.text,
      fechaRegistro: widget.restaurantData['fechaRegistro'],
      activo: true,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar restaurante")),
      );
    }
  }

  InputBorder _redBorder({bool focused = false}) => OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: focused ? 2 : 1),
  );

  Widget _buildStyledField(
    TextEditingController controller,
    String label, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: _redBorder(),
          enabledBorder: _redBorder(),
          focusedBorder: _redBorder(focused: true),
          filled: true,
          fillColor: Colors.grey[100],
        ),
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
        decoration: InputDecoration(
          labelText: "Tipo de Cocina",
          hintText: "Seleccione un tipo de comida",
          border: _redBorder(),
          enabledBorder: _redBorder(),
          focusedBorder: _redBorder(focused: true),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Información Básica",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStyledField(nombreController, "Nombre del Restaurante"),
            _buildStyledField(descripcionController, "Descripción"),
            _buildDropdownField(),

            const SizedBox(height: 16),
            const Text(
              "Información de Contacto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStyledField(telefonoController, "Teléfono del Negocio"),

            const SizedBox(height: 16),
            const Text(
              "Ubicación",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStyledField(direccionController, "Dirección"),

            const SizedBox(height: 16),
            const Text(
              "Horarios de Atención",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStyledField(horarioAperturaController, "Abre a"),
            _buildStyledField(horarioCierreController, "Cierra a"),
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
              hint: "Link a tu menú digital",
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
