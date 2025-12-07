import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/models/restaurant.dart';

class EditRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const EditRestaurantScreen({super.key, required this.restaurantData});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;
  late TextEditingController precioPromedioController;
  late TextEditingController menuUrlController;

  // TimeOfDay para los horarios
  TimeOfDay? horarioApertura;
  TimeOfDay? horarioCierre;

  String? selectedCategoria;
  String? horarioAperturaError;
  String? horarioCierreError;

  // Lista completa de categorías
  final List<String> categorias = [
    'Mexicana',
    'Italiana',
    'Japonesa',
    'China',
    'Americana',
    'Vegetariana',
    'Vegana',
    'Mariscos',
    'Carnes',
    'Pizzería',
    'Hamburguesas',
    'Tacos',
    'Sushi',
    'Cafetería',
    'Panadería',
    'Postres',
    'Comida Rápida',
    'Buffet',
    'Internacional',
    'Fusión',
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
    precioPromedioController = TextEditingController(text: data['precioPromedio']?.toString() ?? '');
    menuUrlController = TextEditingController(text: data['menuUrl'] ?? data['menuURL'] ?? '');
    
    // Validar que la categoría existe en la lista, si no, usar 'Otro'
    final categoria = data['categoria'] ?? '';
    selectedCategoria = categorias.contains(categoria) ? categoria : 'Otro';
    
    // Cargar horarios existentes
    _loadExistingHorarios(data);
    
    debugPrint('📝 Categoría cargada: $selectedCategoria');
  }

  void _loadExistingHorarios(Map<String, dynamic> data) {
    // Cargar horario de apertura
    final aperturaStr = data['horarioApertura'] ?? '';
    debugPrint('📅 Cargando horario apertura: "$aperturaStr"');
    if (aperturaStr.isNotEmpty) {
      horarioApertura = _parseTimeString(aperturaStr);
      debugPrint('✅ Horario apertura parseado: ${horarioApertura != null ? _timeOfDayToString(horarioApertura!) : "NULL"}');
    }

    // Cargar horario de cierre
    final cierreStr = data['horarioCierre'] ?? '';
    debugPrint('📅 Cargando horario cierre: "$cierreStr"');
    if (cierreStr.isNotEmpty) {
      horarioCierre = _parseTimeString(cierreStr);
      debugPrint('✅ Horario cierre parseado: ${horarioCierre != null ? _timeOfDayToString(horarioCierre!) : "NULL"}');
    }
  }

  // Convertir String (HH:mm o HH:mm AM/PM) a TimeOfDay
  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Limpiar el string
      timeStr = timeStr.trim();
      debugPrint('🔍 Parseando: "$timeStr"');
      
      // Verificar si tiene formato AM/PM
      bool hasAMPM = timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM');
      bool isPM = timeStr.toUpperCase().contains('PM');
      
      // Remover AM/PM para procesar
      String cleanTime = timeStr.replaceAll(RegExp(r'\s*(AM|PM|am|pm)\s*'), '').trim();
      
      // Dividir por ":"
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        int? hour = int.tryParse(parts[0].trim());
        int? minute = int.tryParse(parts[1].trim());
        
        if (hour != null && minute != null) {
          // Si tiene formato AM/PM, convertir a formato 24 horas
          if (hasAMPM) {
            if (isPM && hour != 12) {
              hour += 12;
            } else if (!isPM && hour == 12) {
              hour = 0;
            }
          }
          
          // Validar rangos
          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            debugPrint('✅ Hora parseada correctamente: $hour:$minute');
            return TimeOfDay(hour: hour, minute: minute);
          } else {
            debugPrint('❌ Hora fuera de rango: hour=$hour, minute=$minute');
          }
        } else {
          debugPrint('❌ No se pudo parsear hour o minute');
        }
      } else {
        debugPrint('❌ Formato incorrecto, parts: $parts');
      }
    } catch (e) {
      debugPrint('❌ Error parsing time: $e');
    }
    return null;
  }

  // Convertir TimeOfDay a String formato HH:mm
  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      if (cierreMinutos <= aperturaMinutos) {
        // Si el cierre es menor, asumimos que cruza medianoche
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

  Future<void> _saveChanges() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Por favor completa todos los campos requeridos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar horarios
    if (horarioApertura == null || horarioCierre == null) {
      setState(() {
        if (horarioApertura == null) {
          horarioAperturaError = 'Seleccione un horario de apertura';
        }
        if (horarioCierre == null) {
          horarioCierreError = 'Seleccione un horario de cierre';
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Por favor selecciona los horarios de apertura y cierre"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _validateHorarios();
    if (horarioAperturaError != null || horarioCierreError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Corrige los errores en los horarios"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser?.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error: Usuario no autenticado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear objeto Restaurant actualizado
    final updatedRestaurant = Restaurant(
      idRestaurante: widget.restaurantData['idRestaurante'],
      idUsuarioPropietario: authProvider.currentUser!.idUsuario!,
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim(),
      direccion: direccionController.text.trim(),
      latitud: widget.restaurantData['latitud']?.toDouble() ?? 0.0,
      longitud: widget.restaurantData['longitud']?.toDouble() ?? 0.0,
      telefono: telefonoController.text.trim(),
      horarioApertura: _timeOfDayToString(horarioApertura!),
      horarioCierre: _timeOfDayToString(horarioCierre!),
      precioPromedio: double.tryParse(precioPromedioController.text) ?? 0.0,
      categoria: selectedCategoria ?? 'Otro',
      menuUrl: menuUrlController.text.trim(),
      fechaRegistro: widget.restaurantData['fechaRegistro'],
      activo: true,
    );

    final success = await restaurantProvider.updateRestaurant(updatedRestaurant);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Restaurante actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restaurantProvider.errorMessage ?? "❌ Error al actualizar restaurante",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _styledDecoration(String label, IconData icon, {String? hint, String? errorText}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Widget _buildStyledField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: _styledDecoration(label, icon, hint: hint),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required IconData icon,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
    required String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: _styledDecoration(label, icon, errorText: errorText),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTime != null
                    ? _timeOfDayToString(selectedTime)
                    : 'Seleccionar hora',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedTime != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
              const Icon(Icons.access_time, color: Colors.redAccent),
            ],
          ),
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
        decoration: _styledDecoration(
          "Tipo de Cocina",
          Icons.fastfood,
          hint: "Seleccione un tipo de comida",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione una categoría';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Editar Restaurante"),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text(
                    "Información Básica",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildStyledField(
                    nombreController,
                    "Nombre del Restaurante",
                    Icons.restaurant,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  _buildStyledField(
                    descripcionController,
                    "Descripción",
                    Icons.description,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es requerida';
                      }
                      if (value.trim().length < 10) {
                        return 'La descripción debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  _buildDropdownField(),

                  const SizedBox(height: 16),
                  const Text(
                    "Información de Contacto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildStyledField(
                    telefonoController,
                    "Teléfono del Negocio",
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es requerido';
                      }
                      if (value.trim().length != 10) {
                        return 'El teléfono debe tener 10 dígitos';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Ubicación",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildStyledField(
                    direccionController,
                    "Dirección",
                    Icons.location_on,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La dirección es requerida';
                      }
                      if (value.trim().length < 10) {
                        return 'Ingrese una dirección completa';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Horarios de Atención",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTimePickerField(
                    label: "Abre a",
                    icon: Icons.access_time,
                    selectedTime: horarioApertura,
                    onTap: _selectHorarioApertura,
                    errorText: horarioAperturaError,
                  ),
                  _buildTimePickerField(
                    label: "Cierra a",
                    icon: Icons.access_time,
                    selectedTime: horarioCierre,
                    onTap: _selectHorarioCierre,
                    errorText: horarioCierreError,
                  ),
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
                    hint: "Ej: 150.00",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El precio promedio es requerido';
                      }
                      final precio = double.tryParse(value);
                      if (precio == null || precio <= 0) {
                        return 'Ingrese un precio válido mayor a 0';
                      }
                      return null;
                    },
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
                    hint: "https://ejemplo.com/menu",
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final urlPattern = RegExp(
                          r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
                        );
                        if (!urlPattern.hasMatch(value)) {
                          return 'Ingrese una URL válida';
                        }
                      }
                      return null;
                    },
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
                        disabledBackgroundColor: Colors.grey[300],
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}