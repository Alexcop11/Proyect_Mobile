import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/photo_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/image_picker_component.dart';
import 'dart:io';

class RegisterRestaurant extends StatefulWidget {
  const RegisterRestaurant({super.key});

  @override
  State<RegisterRestaurant> createState() => Registerrestaurant();
}

class Registerrestaurant extends State<RegisterRestaurant> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final direccionController = TextEditingController();
  final telefonoController = TextEditingController();
  final horarioAperturaController = TextEditingController();
  final horarioCierreController = TextEditingController();
  final precioPromedioController = TextEditingController();
  final menuUrlController = TextEditingController();

  // Categoría seleccionada
  String? categoriaSeleccionada;

  // Lista de categorías estáticas
  final List<String> categorias = [
    'Mexicana',
    'Italiana',
    'China',
    'Japonesa',
    'Americana',
    'Española',
    'India',
    'Francesa',
    'Árabe',
    'Vegetariana',
    'Mariscos',
    'Fast Food',
    'Cafetería',
    'Postres',
    'Otra',
  ];

  double? latitud;
  double? longitud;
  bool isGettingLocation = false;
  
  // Imagen del restaurante
  File? imagenRestaurante;

  // Validaciones
  String? nombreError;
  String? descripcionError;
  String? direccionError;
  String? telefonoError;
  String? horarioAperturaError;
  String? horarioCierreError;
  String? precioPromedioError;
  String? categoriaError;
  String? ubicacionError;
  String? imagenError;

  @override
  void initState() {
    super.initState();
    // Listeners para validaciones en tiempo real
    nombreController.addListener(_validateNombre);
    descripcionController.addListener(_validateDescripcion);
    direccionController.addListener(_validateDireccion);
    telefonoController.addListener(_validateTelefono);
    horarioAperturaController.addListener(_validateHorarioApertura);
    horarioCierreController.addListener(_validateHorarioCierre);
    precioPromedioController.addListener(_validatePrecioPromedio);
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

  // Validaciones en tiempo real
  void _validateNombre() {
    setState(() {
      if (nombreController.text.isEmpty) {
        nombreError = null;
      } else if (nombreController.text.length < 3) {
        nombreError = 'Mínimo 3 caracteres';
      } else {
        nombreError = null;
      }
    });
  }

  void _validateDescripcion() {
    setState(() {
      if (descripcionController.text.isEmpty) {
        descripcionError = null;
      } else if (descripcionController.text.length < 10) {
        descripcionError = 'Mínimo 10 caracteres';
      } else {
        descripcionError = null;
      }
    });
  }

  void _validateDireccion() {
    setState(() {
      if (direccionController.text.isEmpty) {
        direccionError = null;
      } else if (direccionController.text.length < 5) {
        direccionError = 'Mínimo 5 caracteres';
      } else {
        direccionError = null;
      }
    });
  }

  void _validateTelefono() {
    setState(() {
      if (telefonoController.text.isEmpty) {
        telefonoError = null;
      } else if (!RegExp(r'^\d{10}$').hasMatch(telefonoController.text)) {
        telefonoError = 'Debe tener 10 dígitos';
      } else {
        telefonoError = null;
      }
    });
  }

  void _validateHorarioApertura() {
    setState(() {
      if (horarioAperturaController.text.isEmpty) {
        horarioAperturaError = null;
      } else if (!RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$')
          .hasMatch(horarioAperturaController.text)) {
        horarioAperturaError = 'Formato: HH:mm (ej: 09:00)';
      } else {
        horarioAperturaError = null;
      }
    });
  }

  void _validateHorarioCierre() {
    setState(() {
      if (horarioCierreController.text.isEmpty) {
        horarioCierreError = null;
      } else if (!RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$')
          .hasMatch(horarioCierreController.text)) {
        horarioCierreError = 'Formato: HH:mm (ej: 22:00)';
      } else {
        horarioCierreError = null;
      }
    });
  }

  void _validatePrecioPromedio() {
    setState(() {
      if (precioPromedioController.text.isEmpty) {
        precioPromedioError = null;
      } else {
        final precio = double.tryParse(precioPromedioController.text);
        if (precio == null || precio <= 0) {
          precioPromedioError = 'Debe ser un número mayor a 0';
        } else {
          precioPromedioError = null;
        }
      }
    });
  }

  // Validación final antes de enviar
  bool _validateAll() {
    bool isValid = true;

    setState(() {
      if (nombreController.text.isEmpty || nombreController.text.length < 3) {
        nombreError = 'El nombre es requerido (mín. 3 caracteres)';
        isValid = false;
      }

      if (descripcionController.text.isEmpty ||
          descripcionController.text.length < 10) {
        descripcionError = 'La descripción es requerida (mín. 10 caracteres)';
        isValid = false;
      }

      if (direccionController.text.isEmpty ||
          direccionController.text.length < 5) {
        direccionError = 'La dirección es requerida (mín. 5 caracteres)';
        isValid = false;
      }

      if (latitud == null || longitud == null) {
        ubicacionError = 'Debe obtener la ubicación';
        isValid = false;
      } else {
        ubicacionError = null;
      }

      if (telefonoController.text.isEmpty ||
          !RegExp(r'^\d{10}$').hasMatch(telefonoController.text)) {
        telefonoError = 'Teléfono requerido (10 dígitos)';
        isValid = false;
      }

      if (horarioAperturaController.text.isEmpty ||
          !RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$')
              .hasMatch(horarioAperturaController.text)) {
        horarioAperturaError = 'Formato incorrecto (HH:mm)';
        isValid = false;
      }

      if (horarioCierreController.text.isEmpty ||
          !RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$')
              .hasMatch(horarioCierreController.text)) {
        horarioCierreError = 'Formato incorrecto (HH:mm)';
        isValid = false;
      }

      final precio = double.tryParse(precioPromedioController.text);
      if (precioPromedioController.text.isEmpty || precio == null || precio <= 0) {
        precioPromedioError = 'Precio requerido y mayor a 0';
        isValid = false;
      }

      if (categoriaSeleccionada == null) {
        categoriaError = 'Debe seleccionar una categoría';
        isValid = false;
      } else {
        categoriaError = null;
      }

      // Validación de imagen
      if (imagenRestaurante == null) {
        imagenError = 'Debe seleccionar una imagen del restaurante';
        isValid = false;
      } else {
        imagenError = null;
      }
    });

    return isValid;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
      ubicacionError = null;
    });
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
        const SnackBar(content: Text("📍 Ubicación guardada")),
      );
    } catch (e) {
      debugPrint("❌ Error al obtener ubicación: $e");
      setState(() {
        isGettingLocation = false;
        ubicacionError = 'No se pudo obtener la ubicación';
      });
    }
  }
  Future<void> _handleCreateRestaurant(
  RestaurantProvider restaurantProvider,
  AuthProvider authProvider,
  PhotoProvider photoProvider,
) async {
  // Validar todos los campos
  if (!_validateAll()) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Por favor corrige los errores"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Mostrar indicador de carga
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // 1. Crear el restaurante
    final success = await restaurantProvider.createRestaurant(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      direccion: direccionController.text,
      latitud: latitud!,
      longitud: longitud!,
      telefono: telefonoController.text,
      horarioApertura: horarioAperturaController.text,
      horarioCierre: horarioCierreController.text,
      precioPromedio: double.parse(precioPromedioController.text),
      categoria: categoriaSeleccionada!,
      menuUrl: menuUrlController.text,
      fechaRegistro: DateTime.now().toIso8601String(),
      activo: true,
      idUsuarioPropietario: authProvider.currentUser?.idUsuario ?? 0,
    );

    if (!success) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Error: ${restaurantProvider.errorMessage ?? 'No se pudo crear'}",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Obtener el restaurante recién creado
    final email = authProvider.email;
    if (email == null) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error: No se pudo obtener el email del usuario"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await restaurantProvider.loadOwnerRestaurant(email);
    
    final restaurante = restaurantProvider.ownerRestaurant;
    
    if (restaurante == null || restaurante.idRestaurante == null) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No se pudo obtener el restaurante creado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final idRestaurante = restaurante.idRestaurante!;

    // 3. Subir la foto si existe
    bool photoSuccess = true;
    String? photoErrorMsg;
    
    if (imagenRestaurante != null) {
      photoSuccess = await photoProvider.uploadPhoto(
        imageFile: imagenRestaurante!,
        idRestaurante: idRestaurante,
        descripcion: 'Foto principal del restaurante',
        esPortada: true,
      );
      
      if (!photoSuccess) {
        photoErrorMsg = photoProvider.errorMessage;
      }
    }

    // ✅ CORRECCIÓN: Cerrar el loading AQUÍ, después de TODO
    if (!mounted) return;
    Navigator.pop(context);

    // 4. Mostrar resultado
    if (imagenRestaurante != null && photoSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Restaurante y foto creados correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (imagenRestaurante != null && !photoSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ Restaurante creado, pero error al subir foto: ${photoErrorMsg ?? 'Desconocido'}",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Restaurante creado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }

    // 5. Limpiar formulario
    _clearForm();

  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context); // Cerrar loading en caso de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Error inesperado: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  void _clearForm() {
    nombreController.clear();
    descripcionController.clear();
    direccionController.clear();
    telefonoController.clear();
    horarioAperturaController.clear();
    horarioCierreController.clear();
    precioPromedioController.clear();
    menuUrlController.clear();
    setState(() {
      categoriaSeleccionada = null;
      latitud = null;
      longitud = null;
      imagenRestaurante = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RestaurantProvider, PhotoProvider>(
      builder: (context, authProvider, restaurantProvider, photoProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

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
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
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
                  decoration: _inputDecoration("Nombre", nombreError),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: _inputDecoration("Descripción", descripcionError),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: direccionController,
                  decoration: _inputDecoration("Dirección", direccionError),
                ),
                const SizedBox(height: 16),

                // COMPONENTE DE IMAGEN
                ImagePickerComponent(
                  onImageSelected: (File? image) {
                    setState(() {
                      imagenRestaurante = image;
                      imagenError = null;
                    });
                  },
                  errorText: imagenError,
                ),
                const SizedBox(height: 16),

                // Botón grande para ubicación
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.location_on,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      isGettingLocation
                          ? "Obteniendo ubicación..."
                          : (latitud != null
                              ? "✓ Ubicación guardada"
                              : "Usar mi ubicación"),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
                if (ubicacionError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      ubicacionError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),
                TextField(
                  controller: telefonoController,
                  decoration: _inputDecoration("Teléfono", telefonoError),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: horarioAperturaController,
                  decoration:
                      _inputDecoration("Horario Apertura (HH:mm)", horarioAperturaError),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: horarioCierreController,
                  decoration:
                      _inputDecoration("Horario Cierre (HH:mm)", horarioCierreError),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: precioPromedioController,
                  keyboardType: TextInputType.number,
                  decoration:
                      _inputDecoration("Precio Promedio", precioPromedioError),
                ),
                const SizedBox(height: 16),
                
                // SELECT DE CATEGORÍAS
                DropdownButtonFormField<String>(
                  value: categoriaSeleccionada,
                  decoration: _inputDecoration("Categoría", categoriaError),
                  items: categorias.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      categoriaSeleccionada = newValue;
                      categoriaError = null;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: menuUrlController,
                  decoration: _inputDecoration("URL del Menú", null),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => _handleCreateRestaurant(
                      restaurantProvider,
                      authProvider,
                      photoProvider,
                    ),
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

  InputDecoration _inputDecoration(String label, String? errorText) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}