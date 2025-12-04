import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final int idUsuario;
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? telefono;

  const EditProfileScreen({
    super.key,
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombre ?? "");
    apellidoController = TextEditingController(text: widget.apellido ?? "");
    emailController = TextEditingController(text: widget.email ?? "");
    telefonoController = TextEditingController(text: widget.telefono ?? "");
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> guardarCambios() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final email = emailController.text.trim();
    final telefono = telefonoController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos requeridos')),
      );
      return;
    }

    try {
      final success = await authProvider.updateProfile(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cambios guardados correctamente')),
        );
        Navigator.pop(context, true); // Retornar true para indicar que se actualizó
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al guardar cambios'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  InputBorder _redBorder({bool focused = false}) => OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: focused ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
      );

  InputDecoration _styledDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: Colors.redAccent),
      border: _redBorder(),
      enabledBorder: _redBorder(),
      focusedBorder: _redBorder(focused: true),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Editar Perfil"),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  "Información del Usuario",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nombreController,
                  decoration: _styledDecoration("Nombre", Icons.person),
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: apellidoController,
                  decoration: _styledDecoration("Apellido", Icons.person_outline),
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: _styledDecoration("Email", Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telefonoController,
                  decoration: _styledDecoration("Teléfono", Icons.phone),
                  keyboardType: TextInputType.phone,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 4,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: authProvider.isLoading ? null : guardarCambios,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Guardar cambios',
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