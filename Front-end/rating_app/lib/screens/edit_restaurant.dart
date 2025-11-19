import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';

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
  late TextEditingController categoriaController;
  late TextEditingController menuUrlController;

  @override
  void initState() {
    super.initState();
    final data = widget.restaurantData;
    nombreController = TextEditingController(text: data['nombre']);
    descripcionController = TextEditingController(text: data['descripcion']);
    direccionController = TextEditingController(text: data['direccion']);
    telefonoController = TextEditingController(text: data['telefono']);
    horarioAperturaController = TextEditingController(text: data['horarioApertura']);
    horarioCierreController = TextEditingController(text: data['horarioCierre']);
    precioPromedioController = TextEditingController(text: data['precioPromedio'].toString());
    categoriaController = TextEditingController(text: data['categoria']);
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
    categoriaController.dispose();
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
      categoria: categoriaController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Restaurante")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: descripcionController, decoration: const InputDecoration(labelText: "Descripción")),
            TextField(controller: direccionController, decoration: const InputDecoration(labelText: "Dirección")),
            TextField(controller: telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
            TextField(controller: horarioAperturaController, decoration: const InputDecoration(labelText: "Horario Apertura")),
            TextField(controller: horarioCierreController, decoration: const InputDecoration(labelText: "Horario Cierre")),
            TextField(controller: precioPromedioController, decoration: const InputDecoration(labelText: "Precio Promedio")),
            TextField(controller: categoriaController, decoration: const InputDecoration(labelText: "Categoría")),
            TextField(controller: menuUrlController, decoration: const InputDecoration(labelText: "Menú URL")),
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