import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/models/user.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/profile_header.dart';
import 'package:rating_app/widgets/client/profile_option_card.dart';
import 'package:rating_app/widgets/client/edit_profile_form.dart';
import 'package:rating_app/widgets/client/edit_security_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false; // Nuevo: para controlar el estado de guardado
  bool _notificacionesActivas = true;
  String? _expandedSection;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para cargar datos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // El AuthProvider ya carga el usuario automáticamente
      final user = authProvider.currentUser;

      debugPrint('🔍 Usuario actual: ${user?.nombre ?? "null"}');
      debugPrint('🔍 Email: ${user?.email ?? "null"}');

      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        debugPrint('✅ Usuario cargado: ${user.nombre}');
      } else {
        debugPrint('⚠️ Usuario null, intentando recargar...');
        // Si no hay usuario, intentar recargar
        await authProvider.loadCurrentUser();
        
        if (mounted) {
          setState(() {
            _currentUser = authProvider.currentUser;
            _isLoading = false;
          });
          
          if (_currentUser == null) {
            _showError('No se pudo cargar la información del usuario');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar datos: ${e.toString()}');
        debugPrint('❌ Error cargando usuario: $e');
      }
    }
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Future<void> _guardarCambiosPerfil(String nombre, String correo, String telefono,String apellido) async {
    if (_currentUser == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Extraer nombre y apellido del nombre completo
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
          _currentUser = authProvider.currentUser;
          _expandedSection = null; // Colapsar el formulario y mostrar la info actualizada
        });

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
    if (_currentUser == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.changePassword(newPassword);

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (success) {
        setState(() {
          _expandedSection = null; // Colapsar el formulario
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

  String _getInitiales(String nombre) {
    if (nombre.isEmpty) return 'U';
    
    List<String> partes = nombre.trim().split(' ');
    
    if (partes.length >= 2 && partes[0].isNotEmpty && partes[1].isNotEmpty) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    
    if (partes[0].length >= 2) {
      return partes[0].substring(0, 2).toUpperCase();
    } else if (partes[0].length == 1) {
      return partes[0][0].toUpperCase();
    }
    
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBarCustom(
        title: 'Mi Perfil',
        showBackButton: false,
        onNotificationTap: () {
          debugPrint('Notificaciones tapped');
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('No se pudo cargar el perfil'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileHeader(
                        nombre: _currentUser?.nombreCompleto ?? 'Usuario',
                        email: _currentUser?.email ?? 'Sin email',
                        initiales: _currentUser?.iniciales ?? 'U',
                      ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // CARD DE INFORMACIÓN PERSONAL
                            if (_expandedSection != 'editar_perfil')
                              _buildInfoCard(),

                            // BOTÓN "EDITAR PERFIL"
                            if (_expandedSection != 'editar_perfil')
                              ProfileOptionCard(
                                icon: Icons.edit,
                                iconColor: const Color(0xFFFFA726),
                                iconBgColor: const Color(0xFFFFF3E0),
                                title: 'Editar Perfil',
                                subtitle: 'Actualiza tu información',
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onTap: () => _toggleSection('editar_perfil'),
                              ),

                            // FORMULARIO DE EDICIÓN
                            if (_expandedSection == 'editar_perfil' && _currentUser != null)
                              EditProfileForm(
                                nombreCompleto: _currentUser!.nombreCompleto,
                                correoElectronico: _currentUser!.email,
                                telefono: _currentUser!.telefono ?? '',
                                apellido: _currentUser!.apellido ?? '',
                                onSave: _guardarCambiosPerfil,
                                onCancel: () => setState(() => _expandedSection = null),
                                isSaving: _isSaving,
                              ),

                            ProfileOptionCard(
                              icon: Icons.notifications,
                              iconColor: const Color(0xFFFF6B6B),
                              iconBgColor: const Color(0xFFFFE5E5),
                              title: 'Notificaciones',
                              subtitle: 'Recibir notificaciones',
                              trailing: Switch(
                                value: _notificacionesActivas,
                                onChanged: (value) {
                                  setState(() {
                                    _notificacionesActivas = value;
                                  });
                                },
                                activeColor: const Color(0xFFFF6B6B),
                              ),
                            ),

                            // BOTÓN "CAMBIAR CONTRASEÑA"
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

                            // FORMULARIO DE SEGURIDAD
                            if (_expandedSection == 'seguridad')
                              EditSecurityForm(
                                onSave: _guardarCambiosSeguridad,
                                onCancel: () => setState(() => _expandedSection = null),
                                isSaving: _isSaving,
                              ),

                            const SizedBox(height: 24),

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
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    if (_currentUser == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4FC3F7),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nombre Completo:', _currentUser!.nombreCompleto),
          const SizedBox(height: 12),
          _buildInfoRow('Correo Electrónico:', _currentUser!.email),
          const SizedBox(height: 12),
          _buildInfoRow('Teléfono:', _currentUser!.telefono ?? 'No registrado'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    // Validar que el valor no esté vacío
    final displayValue = (value.isEmpty || value == 'null') ? 'No registrado' : value;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}