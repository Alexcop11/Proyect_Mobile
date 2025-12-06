import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/edit_restaurant.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/register_restaurant.dart';
import 'package:rating_app/widgets/client/profile_info_card.dart';
import 'package:rating_app/widgets/client/profile_option_card.dart';
import 'package:rating_app/widgets/client/edit_profile_form.dart';
import 'package:rating_app/widgets/client/edit_security_form.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/restaurant_photo_section.dart';

class Restaurant_manage_Screen extends StatefulWidget {
  const Restaurant_manage_Screen({super.key});

  @override
  State<Restaurant_manage_Screen> createState() =>
      _Restaurant_manage_ScreenState();
}

class _Restaurant_manage_ScreenState extends State<Restaurant_manage_Screen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final restaurantProvider = context.read<RestaurantProvider>();

      debugPrint('🔄 Cargando datos de configuración...');

      // Cargar usuario si no está cargado
      if (authProvider.currentUser == null) {
        debugPrint('👤 Cargando usuario...');
        await authProvider.loadCurrentUser();
      }

      // Cargar restaurante del propietario
      if (authProvider.email != null) {
        debugPrint('🏪 Cargando restaurante para: ${authProvider.email}');
        await restaurantProvider.loadOwnerRestaurant(authProvider.email!);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('✅ Datos cargados correctamente');
      }
    } catch (e) {
      debugPrint('❌ Error cargando datos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // No mostrar error si es problema de red
        if (!e.toString().contains('Error de red')) {
          _showError('Error al cargar datos: ${e.toString()}');
        }
      }
    }
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Future<void> _guardarCambiosPerfil(String nombre, String correo, String telefono, String apellido) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Extraer nombre del nombre completo si viene todo junto
      final partes = nombre.trim().split(' ');
      final nombreSolo = partes.isNotEmpty ? partes[0] : nombre;
      
      final success = await authProvider.updateProfile(
        nombre: nombreSolo,
        apellido: apellido,
        email: correo,
        telefono: telefono,
      );

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (success) {
        setState(() {
          _expandedSection = null; // Colapsar el formulario
        });

        // Recargar el usuario actualizado
        await authProvider.loadCurrentUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showError(authProvider.errorMessage ?? 'No se pudo actualizar el perfil');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Error al actualizar: ${e.toString()}');
      debugPrint('❌ Error actualizando perfil: $e');
    }
  }

  Future<void> _guardarCambiosSeguridad(String currentPassword, String newPassword) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.changePassword(newPassword);

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (success) {
        setState(() {
          _expandedSection = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showError(authProvider.errorMessage ?? 'No se pudo actualizar la contraseña');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Error al cambiar contraseña: ${e.toString()}');
      debugPrint('❌ Error cambiando contraseña: $e');
    }
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada correctamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();

        // Mostrar loading mientras carga
        if (_isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBarCustom(
              title: 'Configuración',
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.redAccent),
                  SizedBox(height: 16),
                  Text(
                    'Cargando configuración...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final restaurant = restaurantProvider.ownerRestaurant;

        // Si no tiene restaurante, mostrar pantalla de registro
        if (restaurant == null) {
          return const RegisterRestaurant();
        }

        // Convertir Restaurant a Map para mantener compatibilidad
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

        return Scaffold(
          appBar: AppBarCustom(
            title: 'Configuración'
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            color: Colors.redAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Información del Usuario
                    _buildUserInfoSection(authProvider),

                    const SizedBox(height: 16),
                      // NUEVO: Sección de Foto del Restaurante
                  RestaurantPhotoSection(
                    idRestaurante: restaurant?.idRestaurante ?? 0,
                    currentPhotoUrl: restaurantProvider.ownerRestaurant?.menuUrl ?? 'assets/images/restaurante.jpg',
                  ),


                    // Card de Información del Restaurante
                    _buildRestaurantInfoSection(restaurant, restaurantData, authProvider),

                    const SizedBox(height: 16),

                    // Sección de Seguridad
                    _buildSecuritySection(),

                    const SizedBox(height: 24),

                    // Botón de Cerrar Sesión
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Cerrar Sesión'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B6B),
                          side: const BorderSide(color: Color(0xFFFF6B6B)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection(AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    
    return Column(
      children: [
        // Si NO está expandido, mostrar la card de información + botón editar
        if (_expandedSection != 'editar_perfil') ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Encabezado con título
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Información del Usuario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),

                // ProfileInfoCard
                ProfileInfoCard(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF4FC3F7),
                  iconBgColor: const Color(0xFFE3F2FD),
                  title: 'Detalles del Propietario',
                  details: {
                    'Nombre Completo:':
                        currentUser?.nombreCompleto ?? 'No disponible',
                    'Correo Electrónico:':
                        currentUser?.email ?? 'No disponible',
                    'Teléfono:':
                        currentUser?.telefono ?? 'No disponible',
                  },
                ),
              ],
            ),
          ),
          
          // Botón para editar perfil
          ProfileOptionCard(
            icon: Icons.edit,
            iconColor: const Color(0xFFFFA726),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Editar Perfil',
            subtitle: 'Actualiza tu información personal',
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
            onTap: () => _toggleSection('editar_perfil'),
          ),
        ],

        // Si está expandido, mostrar el formulario de edición
        if (_expandedSection == 'editar_perfil' && currentUser != null)
          EditProfileForm(
            nombreCompleto: currentUser.nombreCompleto,
            correoElectronico: currentUser.email,
            telefono: currentUser.telefono ?? '',
            apellido: currentUser.apellido ?? '',
            onSave: _guardarCambiosPerfil,
            onCancel: () => setState(() => _expandedSection = null),
            isSaving: _isSaving,
          ),
      ],
    );
  }

  Widget _buildRestaurantInfoSection(
    restaurant,
    Map<String, dynamic> restaurantData,
    AuthProvider authProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tu Restaurante',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.redAccent),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRestaurantScreen(
                          restaurantData: restaurantData,
                        ),
                      ),
                    );

                    if (result == true && mounted && authProvider.email != null) {
                      final restaurantProvider = context.read<RestaurantProvider>();
                      await restaurantProvider.loadOwnerRestaurant(
                        authProvider.email!,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          ProfileInfoCard(
            icon: Icons.restaurant_menu,
            iconColor: const Color(0xFFFF6B6B),
            iconBgColor: const Color(0xFFFFE5E5),
            title: 'Información Básica',
            details: {
              'Nombre:': restaurant.nombre ?? 'No disponible',
              'Descripción:': restaurant.descripcion ?? 'No disponible',
              'Categoría:': restaurant.categoria ?? 'No disponible',
            },
          ),
          ProfileInfoCard(
            icon: Icons.location_on,
            iconColor: const Color(0xFFFFA726),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Ubicación',
            details: {
              'Dirección:': restaurant.direccion ?? 'No disponible',
            },
          ),
          ProfileInfoCard(
            icon: Icons.access_time,
            iconColor: const Color(0xFF66BB6A),
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Horarios',
            details: {
              'Apertura:': restaurant.horarioApertura ?? 'No disponible',
              'Cierre:': restaurant.horarioCierre ?? 'No disponible',
            },
          ),
          ProfileInfoCard(
            icon: Icons.phone,
            iconColor: const Color(0xFF42A5F5),
            iconBgColor: const Color(0xFFE3F2FD),
            title: 'Contacto y Precios',
            details: {
              'Teléfono:': restaurant.telefono ?? 'No disponible',
              'Precio Promedio:':
                  '\$${restaurant.precioPromedio?.toStringAsFixed(2) ?? '0.00'}',
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        if (_expandedSection != 'seguridad')
          ProfileOptionCard(
            icon: Icons.lock,
            iconColor: const Color(0xFF66BB6A),
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu seguridad',
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
            onTap: () => _toggleSection('seguridad'),
          ),
        if (_expandedSection == 'seguridad')
          EditSecurityForm(
            onSave: _guardarCambiosSeguridad,
            onCancel: () => setState(() => _expandedSection = null),
            isSaving: _isSaving,
          ),
      ],
    );
  }
}