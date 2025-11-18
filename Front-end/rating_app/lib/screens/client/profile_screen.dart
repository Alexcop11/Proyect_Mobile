import 'package:flutter/material.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/profile_header.dart';
import 'package:rating_app/widgets/client/profile_info_card.dart';
import 'package:rating_app/widgets/client/profile_option_card.dart';
import 'package:rating_app/widgets/client/edit_profile_form.dart';
import 'package:rating_app/widgets/client/edit_security_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Datos del usuario
  String _nombreCompleto = 'Maria Garcia';
  String _correoElectronico = 'maria.garcia@gmail.com';
  String _telefono = '777-854-24-10';
  bool _notificacionesActivas = true;

  // Control de secciones expandidas
  String? _expandedSection;

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void _guardarCambiosPerfil(String nombre, String correo, String telefono) {
    setState(() {
      _nombreCompleto = nombre;
      _correoElectronico = correo;
      _telefono = telefono;
      _expandedSection = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _guardarCambiosSeguridad(String currentPassword, String newPassword) {
    // Aquí iría la lógica para cambiar la contraseña
    setState(() {
      _expandedSection = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica de cierre de sesión
              debugPrint('Cerrando sesión...');
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

  String _getInitiales(String nombre) {
    List<String> partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBarCustom(
        title: 'Mi Perfil',
        //showBackButton: true,
        onNotificationTap: () {
          debugPrint('Notificaciones tapped');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar y nombre
            ProfileHeader(
              nombre: _nombreCompleto,
              email: _correoElectronico,
              initiales: _getInitiales(_nombreCompleto),
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Información Personal (expandible)
                  _buildExpandableInfoCard(),
                  
                  // Editar Perfil
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
                  
                  // Formulario de edición de perfil
                  if (_expandedSection == 'editar_perfil')
                    EditProfileForm(
                      nombreCompleto: _nombreCompleto,
                      correoElectronico: _correoElectronico,
                      telefono: _telefono,
                      onSave: _guardarCambiosPerfil,
                      onCancel: () => setState(() => _expandedSection = null),
                    ),
                  
                  // Notificaciones
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
                  
                  // Cambiar Contraseña (expandible)
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
                  
                  // Formulario de cambio de contraseña
                  if (_expandedSection == 'seguridad')
                    EditSecurityForm(
                      onSave: _guardarCambiosSeguridad,
                      onCancel: () => setState(() => _expandedSection = null),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón Cerrar Sesión
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

  Widget _buildExpandableInfoCard() {
    bool isExpanded = _expandedSection == 'info_personal';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isExpanded
            ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
            : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection('info_personal'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildInfoRow('Nombre', _nombreCompleto),
                  const SizedBox(height: 8),
                  _buildInfoRow('Correo Electrónico', _correoElectronico),
                  const SizedBox(height: 8),
                  _buildInfoRow('Teléfono', _telefono),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}