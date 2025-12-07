import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/photo_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/image_picker_component.dart';
import 'dart:io';
import 'package:rating_app/screens/restaurant_manage_screen.dart';

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
  final precioPromedioController = TextEditingController();
  final menuUrlController = TextEditingController();

  // TimeOfDay para los horarios
  TimeOfDay? horarioApertura;
  TimeOfDay? horarioCierre;

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
  bool isCreatingRestaurant = false; // Nuevo flag para el loading
  
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
    precioPromedioController.addListener(_validatePrecioPromedio);
    
    // Solicitar permisos al iniciar
    _requestPermissions();
  }

  // Solicitar permisos de ubicación y notificaciones
  Future<void> _requestPermissions() async {
    // Solicitar permiso de ubicación
    await _requestLocationPermission();
    
    // Solicitar permiso de notificaciones
    await _requestNotificationPermission();
    
    // Solicitar permiso de cámara
    await _requestCameraPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    
    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Permiso de ubicación denegado. Necesario para registrar el restaurante."),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showPermissionDialog(
        title: "Permiso de Ubicación Requerido",
        message: "Para registrar tu restaurante necesitas habilitar el permiso de ubicación en la configuración de la aplicación.",
        permissionType: "ubicación",
      );
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    
    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Permiso de cámara denegado. No podrás tomar fotos del restaurante."),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showPermissionDialog(
        title: "Permiso de Cámara Requerido",
        message: "Para tomar fotos de tu restaurante necesitas habilitar el permiso de cámara en la configuración de la aplicación.",
        permissionType: "cámara",
      );
    } else if (status.isGranted) {
      if (!mounted) return;
      debugPrint("✅ Permiso de cámara concedido");
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    
    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Permiso de notificaciones denegado. No recibirás notificaciones de la app."),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ℹ️ Puedes habilitar las notificaciones en la configuración de tu dispositivo."),
          duration: Duration(seconds: 4),
        ),
      );
    } else if (status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Notificaciones habilitadas correctamente"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required String permissionType,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text("Abrir Configuración", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
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

  // Validación de horarios
  void _validateHorarios() {
    setState(() {
      // Validar que ambos horarios existan
      if (horarioApertura == null) {
        horarioAperturaError = 'Seleccione un horario de apertura';
        return;
      } else {
        horarioAperturaError = null;
      }

      if (horarioCierre == null) {
        horarioCierreError = 'Seleccione un horario de cierre';
        return;
      } else {
        horarioCierreError = null;
      }

      // Validar que no sean la misma hora
      if (horarioApertura!.hour == horarioCierre!.hour &&
          horarioApertura!.minute == horarioCierre!.minute) {
        horarioCierreError = 'El horario de cierre debe ser diferente al de apertura';
        return;
      }

      // Convertir a minutos desde medianoche para comparar
      final aperturaMinutos = horarioApertura!.hour * 60 + horarioApertura!.minute;
      final cierreMinutos = horarioCierre!.hour * 60 + horarioCierre!.minute;

      // Validar que el horario de cierre sea después del de apertura
      // (considerando que pueden cruzar medianoche)
      if (cierreMinutos <= aperturaMinutos) {
        // Si el cierre es menor, asumimos que cruza medianoche
        // Verificar que tenga sentido (al menos 2 horas de diferencia considerando el cruce)
        final duracion = (24 * 60 - aperturaMinutos) + cierreMinutos;
        if (duracion < 120) { // Menos de 2 horas
          horarioCierreError = 'El restaurante debe estar abierto al menos 2 horas';
        } else {
          horarioCierreError = null;
        }
      } else {
        // No cruza medianoche, validar duración mínima
        final duracion = cierreMinutos - aperturaMinutos;
        if (duracion < 120) { // Menos de 2 horas
          horarioCierreError = 'El restaurante debe estar abierto al menos 2 horas';
        } else {
          horarioCierreError = null;
        }
      }
    });
  }

  // Selector de hora de apertura
  Future<void> _selectHorarioApertura() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioApertura ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        horarioApertura = picked;
        horarioAperturaError = null;
      });
      _validateHorarios();
    }
  }

  // Selector de hora de cierre
  Future<void> _selectHorarioCierre() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioCierre ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        horarioCierre = picked;
        horarioCierreError = null;
      });
      _validateHorarios();
    }
  }

  // Convertir TimeOfDay a String formato HH:mm
  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

      if (horarioApertura == null) {
        horarioAperturaError = 'Seleccione un horario de apertura';
        isValid = false;
      }

      if (horarioCierre == null) {
        horarioCierreError = 'Seleccione un horario de cierre';
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

    // Validar horarios si ambos existen
    if (horarioApertura != null && horarioCierre != null) {
      _validateHorarios();
      if (horarioAperturaError != null || horarioCierreError != null) {
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _getCurrentLocation() async {
    // Verificar primero si el permiso está concedido
    final status = await Permission.location.status;
    
    if (status.isDenied || status.isPermanentlyDenied) {
      if (!mounted) return;
      
      // Intentar solicitar el permiso nuevamente
      final newStatus = await Permission.location.request();
      
      if (newStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Permiso de ubicación denegado"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } else if (newStatus.isPermanentlyDenied) {
        _showPermissionDialog(
          title: "Permiso de Ubicación Requerido",
          message: "Para obtener tu ubicación necesitas habilitar el permiso en la configuración de la aplicación.",
          permissionType: "ubicación",
        );
        return;
      }
    }

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
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

Future<void> _handleCreateRestaurant(
    RestaurantProvider restaurantProvider,
    AuthProvider authProvider,
    PhotoProvider photoProvider,
  ) async {
    // Validar todos los campos
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Por favor corrige los errores"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que el usuario esté autenticado
    if (authProvider.currentUser?.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error: Usuario no autenticado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Activar el loading en el botón
    setState(() {
      isCreatingRestaurant = true;
    });

    try {
      debugPrint("🔄 Iniciando creación de restaurante...");
      
      // 1. Crear el restaurante
      debugPrint("📝 Llamando a createRestaurant...");
      final success = await restaurantProvider.createRestaurant(
        idUsuarioPropietario: authProvider.currentUser!.idUsuario!,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        direccion: direccionController.text,
        latitud: latitud!,
        longitud: longitud!,
        telefono: telefonoController.text,
        horarioApertura: _timeOfDayToString(horarioApertura!),
        horarioCierre: _timeOfDayToString(horarioCierre!),
        precioPromedio: double.parse(precioPromedioController.text),
        categoria: categoriaSeleccionada!,
        menuUrl: menuUrlController.text.isNotEmpty ? menuUrlController.text : '',
        fechaRegistro: DateTime.now().toIso8601String(),
        activo: true,
      );

      debugPrint("✅ createRestaurant completado. Success: $success");

      if (!success) {
        debugPrint("❌ Error al crear restaurante: ${restaurantProvider.errorMessage}");
        setState(() {
          isCreatingRestaurant = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Error: ${restaurantProvider.errorMessage ?? 'No se pudo crear el restaurante'}",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Obtener el restaurante recién creado
      final email = authProvider.email;
      debugPrint("📧 Email del usuario: $email");
      
      if (email == null) {
        setState(() {
          isCreatingRestaurant = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Error: No se pudo obtener el email del usuario"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint("🔍 Cargando restaurante del propietario...");
      await restaurantProvider.loadOwnerRestaurant(email, authProvider);
      
      final restaurante = restaurantProvider.ownerRestaurant;
      debugPrint("🏪 Restaurante obtenido: ${restaurante?.idRestaurante}");
      
      if (restaurante == null || restaurante.idRestaurante == null) {
        setState(() {
          isCreatingRestaurant = false;
        });
        if (!mounted) return;
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
        debugPrint("📸 Subiendo foto del restaurante...");
        photoSuccess = await photoProvider.uploadPhoto(
          imageFile: imagenRestaurante!,
          idRestaurante: idRestaurante,
          descripcion: 'Foto principal del restaurante',
          esPortada: true,
        );
        
        debugPrint("📸 Resultado subida de foto: $photoSuccess");
        
        if (!photoSuccess) {
          photoErrorMsg = photoProvider.errorMessage;
          debugPrint("⚠️ Error al subir foto: $photoErrorMsg");
        }
      } else {
        debugPrint("ℹ️ No hay imagen para subir");
      }

      // Desactivar loading
      setState(() {
        isCreatingRestaurant = false;
      });

      if (!mounted) return;
      
      debugPrint("✅ Proceso completado exitosamente");

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

      // 5. Navegar a la pantalla de gestión del restaurante
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RestaurantManageScreen(),
        ),
      );

    } catch (e, stackTrace) {
      debugPrint("❌ Error inesperado: $e");
      debugPrint("Stack trace: $stackTrace");
      
      setState(() {
        isCreatingRestaurant = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error inesperado: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _clearForm() {
    nombreController.clear();
    descripcionController.clear();
    direccionController.clear();
    telefonoController.clear();
    precioPromedioController.clear();
    menuUrlController.clear();
    setState(() {
      categoriaSeleccionada = null;
      latitud = null;
      longitud = null;
      imagenRestaurante = null;
      horarioApertura = null;
      horarioCierre = null;
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

                // SELECTOR DE HORARIO DE APERTURA
                InkWell(
                  onTap: _selectHorarioApertura,
                  child: InputDecorator(
                    decoration: _inputDecoration("Horario de Apertura", horarioAperturaError),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          horarioApertura != null
                              ? _timeOfDayToString(horarioApertura!)
                              : 'Seleccionar hora',
                          style: TextStyle(
                            fontSize: 16,
                            color: horarioApertura != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.access_time, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SELECTOR DE HORARIO DE CIERRE
                InkWell(
                  onTap: _selectHorarioCierre,
                  child: InputDecorator(
                    decoration: _inputDecoration("Horario de Cierre", horarioCierreError),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          horarioCierre != null
                              ? _timeOfDayToString(horarioCierre!)
                              : 'Seleccionar hora',
                          style: TextStyle(
                            fontSize: 16,
                            color: horarioCierre != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.access_time, color: Colors.redAccent),
                      ],
                    ),
                  ),
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
                  decoration: _inputDecoration("URL del Menú (opcional)", null),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    onPressed: isCreatingRestaurant
                        ? null
                        : () => _handleCreateRestaurant(
                              restaurantProvider,
                              authProvider,
                              photoProvider,
                            ),
                    child: isCreatingRestaurant
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Creando restaurante...",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
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