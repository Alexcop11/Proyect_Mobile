import 'package:flutter/material.dart';

class EditSecurityForm extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  const EditSecurityForm({
    Key? key,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
  }) : super(key: key);

  @override
  State<EditSecurityForm> createState() => _EditSecurityFormState();
}

class _EditSecurityFormState extends State<EditSecurityForm> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  // Estados de validación en tiempo real
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;
  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;

  static const Color _inputBorderColor = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    // Listeners para validación en tiempo real
    _newPasswordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateNewPassword() {
    setState(() {
      final password = _newPasswordController.text;
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      // Revalidar confirmación si ya fue tocada
      if (_confirmPasswordTouched) {
        _validateConfirmPassword();
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _passwordsMatch = _confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text == _newPasswordController.text;
    });
  }

  bool get _isPasswordValid {
    return _hasMinLength && 
           _hasUpperCase && 
           _hasLowerCase && 
           _hasNumber && 
           _hasSpecialChar;
  }

  bool get _canSave {
    return _isPasswordValid && 
           _passwordsMatch && 
           !widget.isSaving;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildValidationItem(String text, bool isValid, bool showCheck) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            showCheck && isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: showCheck && isValid 
                ? const Color(0xFF66BB6A) 
                : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: showCheck && isValid 
                    ? const Color(0xFF66BB6A) 
                    : Colors.grey[600],
                fontWeight: showCheck && isValid 
                    ? FontWeight.w500 
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Color(0xFF66BB6A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seguridad',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Mensaje informativo
            Text(
              'Cambia tu contraseña regularmente para mantener tu cuenta segura',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Nueva Contraseña
            const Text(
              'Nueva Contraseña:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 15),
              onChanged: (value) {
                if (!_newPasswordTouched) {
                  setState(() => _newPasswordTouched = true);
                }
              },
              decoration: InputDecoration(
                hintText: 'Ingresa tu nueva contraseña',
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFFF6B6B),
                    size: 22,
                  ),
                  onPressed: widget.isSaving
                      ? null
                      : () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _newPasswordTouched && !_isPasswordValid 
                        ? Colors.orange 
                        : _inputBorderColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _newPasswordTouched && !_isPasswordValid 
                        ? Colors.orange 
                        : _inputBorderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _newPasswordTouched && _isPasswordValid 
                        ? const Color(0xFF66BB6A)
                        : _inputBorderColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu nueva contraseña';
                }
                if (!_isPasswordValid) {
                  return 'La contraseña no cumple todos los requisitos';
                }
                return null;
              },
            ),
            
            // Indicadores de validación
            if (_newPasswordTouched) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requisitos de contraseña:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildValidationItem(
                      'Mínimo 8 caracteres',
                      _hasMinLength,
                      _newPasswordTouched,
                    ),
                    _buildValidationItem(
                      'Al menos una letra mayúscula (A-Z)',
                      _hasUpperCase,
                      _newPasswordTouched,
                    ),
                    _buildValidationItem(
                      'Al menos una letra minúscula (a-z)',
                      _hasLowerCase,
                      _newPasswordTouched,
                    ),
                    _buildValidationItem(
                      'Al menos un número (0-9)',
                      _hasNumber,
                      _newPasswordTouched,
                    ),
                    _buildValidationItem(
                      'Al menos un carácter especial (!@#\$%^&*)',
                      _hasSpecialChar,
                      _newPasswordTouched,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Confirmar Contraseña
            const Text(
              'Confirmar Contraseña:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !widget.isSaving,
              style: const TextStyle(fontSize: 15),
              onChanged: (value) {
                if (!_confirmPasswordTouched) {
                  setState(() => _confirmPasswordTouched = true);
                }
              },
              decoration: InputDecoration(
                hintText: 'Confirma tu nueva contraseña',
                filled: true,
                fillColor: widget.isSaving ? Colors.grey[100] : Colors.white,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_confirmPasswordTouched && _confirmPasswordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          _passwordsMatch ? Icons.check_circle : Icons.cancel,
                          color: _passwordsMatch 
                              ? const Color(0xFF66BB6A) 
                              : Colors.red[400],
                          size: 22,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFFFF6B6B),
                        size: 22,
                      ),
                      onPressed: widget.isSaving
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmPasswordTouched && !_passwordsMatch 
                        ? Colors.red[400]! 
                        : _inputBorderColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmPasswordTouched && !_passwordsMatch 
                        ? Colors.red[400]! 
                        : _inputBorderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmPasswordTouched && _passwordsMatch 
                        ? const Color(0xFF66BB6A)
                        : _inputBorderColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu nueva contraseña';
                }
                if (!_passwordsMatch) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            
            // Mensaje de confirmación
            if (_confirmPasswordTouched && _confirmPasswordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _passwordsMatch ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: _passwordsMatch 
                        ? const Color(0xFF66BB6A) 
                        : Colors.red[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _passwordsMatch 
                        ? 'Las contraseñas coinciden' 
                        : 'Las contraseñas no coinciden',
                    style: TextStyle(
                      fontSize: 13,
                      color: _passwordsMatch 
                          ? const Color(0xFF66BB6A) 
                          : Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isSaving ? null : widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8E8E8),
                      foregroundColor: const Color(0xFF999999),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
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
                                '',
                                _newPasswordController.text,
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFFF6B6B).withOpacity(0.6),
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
                              fontSize: 15,
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