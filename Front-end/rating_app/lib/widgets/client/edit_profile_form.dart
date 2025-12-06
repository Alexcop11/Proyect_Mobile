import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Estados de validación en tiempo real
  bool _nombreValid = true;
  bool _apellidoValid = true;
  bool _telefonoValid = true;
  bool _nombreTouched = false;
  bool _apellidoTouched = false;
  bool _telefonoTouched = false;
  
  String? _nombreError;
  String? _apellidoError;
  String? _telefonoError;

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

    // Listeners para validación en tiempo real
    _nombreController.addListener(_validateNombre);
    _apellidoController.addListener(_validateApellido);
    _telefonoController.addListener(_validateTelefono);
  }

  void _validateNombre() {
    if (!_nombreTouched) return;
    
    setState(() {
      final value = _nombreController.text.trim();
      if (value.isEmpty) {
        _nombreValid = false;
        _nombreError = 'El nombre es requerido';
      } else if (value.length < 2) {
        _nombreValid = false;
        _nombreError = 'Mínimo 2 caracteres';
      } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
        _nombreValid = false;
        _nombreError = 'Solo letras permitidas';
      } else {
        _nombreValid = true;
        _nombreError = null;
      }
    });
  }

  void _validateApellido() {
    if (!_apellidoTouched) return;
    
    setState(() {
      final value = _apellidoController.text.trim();
      // El apellido es opcional, pero si se ingresa debe ser válido
      if (value.isNotEmpty) {
        if (value.length < 2) {
          _apellidoValid = false;
          _apellidoError = 'Mínimo 2 caracteres';
        } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
          _apellidoValid = false;
          _apellidoError = 'Solo letras permitidas';
        } else {
          _apellidoValid = true;
          _apellidoError = null;
        }
      } else {
        _apellidoValid = true;
        _apellidoError = null;
      }
    });
  }

  void _validateTelefono() {
    if (!_telefonoTouched) return;
    
    setState(() {
      final value = _telefonoController.text.trim();
      if (value.isEmpty) {
        _telefonoValid = false;
        _telefonoError = 'El teléfono es requerido';
      } else {
        // Remover guiones y espacios para validar
        final cleanPhone = value.replaceAll(RegExp(r'[-\s]'), '');
        if (cleanPhone.length < 10) {
          _telefonoValid = false;
          _telefonoError = 'Mínimo 10 dígitos';
        } else if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
          _telefonoValid = false;
          _telefonoError = 'Solo números, guiones y espacios';
        } else {
          _telefonoValid = true;
          _telefonoError = null;
        }
      }
    });
  }

  bool get _isFormValid {
    return _nombreValid && _apellidoValid && _telefonoValid;
  }

  bool get _canSave {
    return _isFormValid && !widget.isSaving;
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

  Widget _buildValidationIcon(bool isValid, bool isTouched, String text) {
    if (!isTouched || text.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        isValid ? Icons.check_circle : Icons.error,
        size: 22,
        color: isValid ? const Color(0xFF66BB6A) : Colors.red[400],
      ),
    );
  }

  Widget _buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.red[400]),
          const SizedBox(width: 4),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor(bool isValid, bool isTouched) {
    if (!isTouched) return _inputBorderColor;
    return isValid ? const Color(0xFF66BB6A) : Colors.red[400]!;
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
            Row(
              children: [
                const Text(
                  'Nombre:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _nombreController,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 14),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
              onChanged: (value) {
                if (!_nombreTouched) {
                  setState(() => _nombreTouched = true);
                }
              },
              decoration: InputDecoration(
                hintText: 'Ingresa tu nombre',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                suffixIcon: _buildValidationIcon(
                  _nombreValid, 
                  _nombreTouched, 
                  _nombreController.text,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_nombreValid, _nombreTouched),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_nombreValid, _nombreTouched),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_nombreValid, _nombreTouched),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
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
                if (value.length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            _buildFieldError(_nombreError),
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
              onChanged: (value) {
                if (!_apellidoTouched) {
                  setState(() => _apellidoTouched = true);
                }
              },
              decoration: InputDecoration(
                hintText: 'Ingresa tu apellido (opcional)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                suffixIcon: _buildValidationIcon(
                  _apellidoValid, 
                  _apellidoTouched, 
                  _apellidoController.text,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_apellidoValid, _apellidoTouched),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_apellidoValid, _apellidoTouched),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_apellidoValid, _apellidoTouched),
                    width: 2,
                  ),
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
            _buildFieldError(_apellidoError),
            const SizedBox(height: 16),

            // --- Correo Electrónico ---
            Row(
              children: [
                const Text(
                  'Correo Electrónico:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.lock_outline, size: 14, color: Colors.grey[500]),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              decoration: InputDecoration(
                hintText: 'correo@ejemplo.com',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: Icon(Icons.email_outlined, 
                  size: 20, 
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 2),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El correo electrónico no puede ser modificado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Teléfono ---
            Row(
              children: [
                const Text(
                  'Teléfono:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 14),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\s]')),
                LengthLimitingTextInputFormatter(15),
              ],
              onChanged: (value) {
                if (!_telefonoTouched) {
                  setState(() => _telefonoTouched = true);
                }
              },
              decoration: InputDecoration(
                hintText: '777-123-45-67',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                prefixIcon: Icon(Icons.phone_outlined, 
                  size: 20, 
                  color: _telefonoTouched && !_telefonoValid 
                    ? Colors.red[400]
                    : _telefonoTouched && _telefonoValid
                      ? const Color(0xFF66BB6A)
                      : Colors.grey[500],
                ),
                suffixIcon: _buildValidationIcon(
                  _telefonoValid, 
                  _telefonoTouched, 
                  _telefonoController.text,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_telefonoValid, _telefonoTouched),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_telefonoValid, _telefonoTouched),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(_telefonoValid, _telefonoTouched),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[400]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
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
                final cleanPhone = value.replaceAll(RegExp(r'[-\s]'), '');
                if (cleanPhone.length < 10) {
                  return 'El teléfono debe tener al menos 10 dígitos';
                }
                return null;
              },
            ),
            _buildFieldError(_telefonoError),
            const SizedBox(height: 8),
            
            // Info de formato de teléfono
            if (_telefonoTouched && _telefonoValid) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: const Color(0xFF66BB6A)),
                  const SizedBox(width: 4),
                  Text(
                    'Formato de teléfono válido',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF66BB6A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
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
                    onPressed: _canSave
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave(
                                _nombreCompleto,
                                _correoController.text,
                                _telefonoController.text,
                                _apellidoController.text,
                              );
                            }
                          }
                        : null,
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