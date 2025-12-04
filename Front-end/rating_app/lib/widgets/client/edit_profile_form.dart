import 'package:flutter/material.dart';

class EditProfileForm extends StatefulWidget {
  final String nombreCompleto;
  final String correoElectronico;
  final String telefono;
  final String apellido;
  final Function(String nombreCompleto, String correo, String telefono, String apellido) onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  const EditProfileForm({
    Key? key,
    required this.nombreCompleto,
    required this.correoElectronico,
    required this.telefono,
    required this.apellido,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
  }) : super(key: key);

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  final _formKey = GlobalKey<FormState>();

  static const Color _inputBorderColor = Color(0xFFFF6B6B);
  static const Color _saveButtonColor = Color(0xFFFF6B6B);
  static const Color _cancelButtonBgColor = Color(0xFFE0E0E0);
  static const Color _cancelButtonTextColor = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    
    // Separar nombre completo en nombre y apellido
    final partes = widget.nombreCompleto.trim().split(' ');
    final nombre = partes.isNotEmpty ? partes[0] : '';
    final apellido = partes.length > 1 ? partes.sublist(1).join(' ') : '';
    
    _nombreController = TextEditingController(text: nombre);
    _apellidoController = TextEditingController(text: apellido);
    _correoController = TextEditingController(text: widget.correoElectronico);
    _telefonoController = TextEditingController(text: widget.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  String get _nombreCompleto {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    
    if (apellido.isEmpty) {
      return nombre;
    }
    return '$nombre $apellido';
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado 'Información Personal'
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
            
            // --- Nombre ---
            const Text(
              'Nombre:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _nombreController,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ingresa tu nombre',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Apellido ---
            const Text(
              'Apellido:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _apellidoController,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ingresa tu apellido',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                // El apellido es opcional
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Correo Electrónico ---
            const Text(
              'Correo Electrónico:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'correo@ejemplo.com',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Advertencia de Correo
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber[600]),
                const SizedBox(width: 4),
                Text(
                  'No puedes cambiar tu correo electrónico',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Teléfono ---
            const Text(
              'Teléfono:',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '777-123-45-67',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _inputBorderColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // --- Botones ---
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isSaving ? null : widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cancelButtonBgColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: _cancelButtonTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón Guardar Cambios con Loading
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isSaving
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave(
                                _nombreCompleto, // Combina nombre + apellido
                                _correoController.text,
                                _telefonoController.text,
                                _apellidoController.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saveButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: _saveButtonColor.withOpacity(0.6),
                    ),
                    child: widget.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}