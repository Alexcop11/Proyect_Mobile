import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNamesController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerSame = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isRegistering = false;
  String selectedTipoUsuario = 'NORMAL';

  // Estados de validación
  bool _nombreValid = true;
  bool _apellidoValid = true;
  bool _emailValid = true;
  bool _telefonoValid = true;
  bool _passwordValid = true;
  bool _confirmPasswordValid = true;
  
  bool _nombreTouched = false;
  bool _apellidoTouched = false;
  bool _emailTouched = false;
  bool _telefonoTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  
  String? _nombreError;
  String? _apellidoError;
  String? _emailError;
  String? _telefonoError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_validateNombre);
    lastNamesController.addListener(_validateApellido);
    emailController.addListener(_validateEmail);
    phoneController.addListener(_validateTelefono);
    passwordController.addListener(_validatePassword);
    passwordControllerSame.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNamesController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordControllerSame.dispose();
    super.dispose();
  }

  void _validateNombre() {
    if (!_nombreTouched) return;
    
    setState(() {
      final value = nameController.text.trim();
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
      final value = lastNamesController.text.trim();
      if (value.isEmpty) {
        _apellidoValid = false;
        _apellidoError = 'El apellido es requerido';
      } else if (value.length < 2) {
        _apellidoValid = false;
        _apellidoError = 'Mínimo 2 caracteres';
      } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
        _apellidoValid = false;
        _apellidoError = 'Solo letras permitidas';
      } else {
        _apellidoValid = true;
        _apellidoError = null;
      }
    });
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    
    setState(() {
      final value = emailController.text.trim();
      if (value.isEmpty) {
        _emailValid = false;
        _emailError = 'El correo es requerido';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailValid = false;
        _emailError = 'Correo inválido';
      } else {
        _emailValid = true;
        _emailError = null;
      }
    });
  }

  void _validateTelefono() {
    if (!_telefonoTouched) return;
    
    setState(() {
      final value = phoneController.text.trim();
      if (value.isEmpty) {
        _telefonoValid = false;
        _telefonoError = 'El teléfono es requerido';
      } else {
        final cleanPhone = value.replaceAll(RegExp(r'[-\s]'), '');
        if (cleanPhone.length < 10) {
          _telefonoValid = false;
          _telefonoError = 'Mínimo 10 dígitos';
        } else if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
          _telefonoValid = false;
          _telefonoError = 'Solo números permitidos';
        } else {
          _telefonoValid = true;
          _telefonoError = null;
        }
      }
    });
  }
void _validatePassword() {
  if (!_passwordTouched) return;

  setState(() {
    final value = passwordController.text;

    // Reglas de validación fuerte
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (value.isEmpty) {
      _passwordValid = false;
      _passwordError = 'La contraseña es requerida';
    } else if (value.length < 8) {
      _passwordValid = false;
      _passwordError = 'Debe tener mínimo 8 caracteres';
    } else if (!hasUpper) {
      _passwordValid = false;
      _passwordError = 'Debe incluir al menos una mayúscula';
    } else if (!hasLower) {
      _passwordValid = false;
      _passwordError = 'Debe incluir al menos una minúscula';
    } else if (!hasNumber) {
      _passwordValid = false;
      _passwordError = 'Debe incluir al menos un número';
    } else if (!hasSpecial) {
      _passwordValid = false;
      _passwordError = 'Debe incluir un caracter especial (#,!,%,@,...)';
    } else {
      _passwordValid = true;
      _passwordError = null;
    }

    // Revalidar confirmación si ya fue tocada
    if (_confirmPasswordTouched) {
      _validateConfirmPassword();
    }
  });
}
void _validateConfirmPassword() {
  if (!_confirmPasswordTouched) return;

  setState(() {
    final value = passwordControllerSame.text;

    if (value.isEmpty) {
      _confirmPasswordValid = false;
      _confirmPasswordError = 'Confirma tu contraseña';
    } else if (value != passwordController.text) {
      _confirmPasswordValid = false;
      _confirmPasswordError = 'Las contraseñas no coinciden';
    } else {
      _confirmPasswordValid = true;
      _confirmPasswordError = null;
    }
  });
}


  bool get _isFormValid {
    return _nombreValid && 
           _apellidoValid && 
           _emailValid && 
           _telefonoValid && 
           _passwordValid && 
           _confirmPasswordValid &&
           nameController.text.isNotEmpty &&
           lastNamesController.text.isNotEmpty &&
           emailController.text.isNotEmpty &&
           phoneController.text.isNotEmpty &&
           passwordController.text.isNotEmpty &&
           passwordControllerSame.text.isNotEmpty;
  }

  Color _getBorderColor(bool isValid, bool isTouched) {
    if (!isTouched) return Colors.grey[300]!;
    return isValid ? const Color(0xFF66BB6A) : Colors.red[400]!;
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
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.red[400]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    // Marcar todos los campos como tocados
    setState(() {
      _nombreTouched = true;
      _apellidoTouched = true;
      _emailTouched = true;
      _telefonoTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    // Validar todos los campos
    _validateNombre();
    _validateApellido();
    _validateEmail();
    _validateTelefono();
    _validatePassword();
    _validateConfirmPassword();

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Por favor completa todos los campos correctamente"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      nombre: nameController.text.trim(),
      apellido: lastNamesController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      telefono: phoneController.text.trim(),
      tipousuario: selectedTipoUsuario,
    );

    if (!mounted) return;
    
    setState(() => _isRegistering = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "❌ Error al registrar"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registro exitoso"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/restaurante.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.restaurant, color: Colors.orange),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Crea tu cuenta en FoodFinder",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Descubre los mejores restaurantes cerca de ti",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipo de usuario
                          const Text(
                            "Tipo de Usuario",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedTipoUsuario,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[50],
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
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'NORMAL',
                                child: Text('Cliente'),
                              ),
                              DropdownMenuItem(
                                value: 'RESTAURANTE',
                                child: Text('Propietario de Restaurante'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedTipoUsuario = value);
                              }
                            },
                          ),

                          const SizedBox(height: 20),
                          
                          // Nombre
                          Row(
                            children: const [
                              Text(
                                "Nombre",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            enabled: !_isRegistering,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                              ),
                            ],
                            onChanged: (value) {
                              if (!_nombreTouched) {
                                setState(() => _nombreTouched = true);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Juan',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              suffixIcon: _buildValidationIcon(
                                _nombreValid,
                                _nombreTouched,
                                nameController.text,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          _buildFieldError(_nombreError),

                          const SizedBox(height: 16),
                          
                          // Apellido
                          Row(
                            children: const [
                              Text(
                                "Apellido",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: lastNamesController,
                            enabled: !_isRegistering,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                              ),
                            ],
                            onChanged: (value) {
                              if (!_apellidoTouched) {
                                setState(() => _apellidoTouched = true);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Pérez García',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              suffixIcon: _buildValidationIcon(
                                _apellidoValid,
                                _apellidoTouched,
                                lastNamesController.text,
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
                          ),
                          _buildFieldError(_apellidoError),

                          const SizedBox(height: 16),
                          
                          // Email
                          Row(
                            children: const [
                              Text(
                                "Correo Electrónico",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            enabled: !_isRegistering,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              if (!_emailTouched) {
                                setState(() => _emailTouched = true);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'ejemplo@correo.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: _emailTouched && !_emailValid
                                    ? Colors.red[400]
                                    : _emailTouched && _emailValid
                                        ? const Color(0xFF66BB6A)
                                        : Colors.grey[500],
                              ),
                              suffixIcon: _buildValidationIcon(
                                _emailValid,
                                _emailTouched,
                                emailController.text,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_emailValid, _emailTouched),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_emailValid, _emailTouched),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_emailValid, _emailTouched),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          _buildFieldError(_emailError),

                          const SizedBox(height: 16),
                          
                          // Teléfono
                          Row(
                            children: const [
                              Text(
                                "Teléfono",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: phoneController,
                            enabled: !_isRegistering,
                            keyboardType: TextInputType.phone,
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
                              hintText: '777-123-4567',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
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
                                phoneController.text,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          _buildFieldError(_telefonoError),

                          const SizedBox(height: 16),
                          
                          // Contraseña
                          Row(
                            children: const [
                              Text(
                                "Contraseña",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            enabled: !_isRegistering,
                            obscureText: !_isPasswordVisible,
                            onChanged: (value) {
                              if (!_passwordTouched) {
                                setState(() => _passwordTouched = true);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Mínimo 6 caracteres',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: _passwordTouched && !_passwordValid
                                    ? Colors.red[400]
                                    : _passwordTouched && _passwordValid
                                        ? const Color(0xFF66BB6A)
                                        : Colors.grey[500],
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildValidationIcon(
                                    _passwordValid,
                                    _passwordTouched,
                                    passwordController.text,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_passwordValid, _passwordTouched),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_passwordValid, _passwordTouched),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _getBorderColor(_passwordValid, _passwordTouched),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                          _buildFieldError(_passwordError),

                          const SizedBox(height: 16),
                          
                          // Confirmar Contraseña
                          Row(
                            children: const [
                              Text(
                                "Confirmar Contraseña",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordControllerSame,
                            enabled: !_isRegistering,
                            obscureText: !_isConfirmPasswordVisible,
                            onChanged: (value) {
                              if (!_confirmPasswordTouched) {
                                setState(() => _confirmPasswordTouched = true);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Repite tu contraseña',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: _isRegistering ? Colors.grey[100] : Colors.white,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: _confirmPasswordTouched && !_confirmPasswordValid
                                    ? Colors.red[400]
                                    : _confirmPasswordTouched && _confirmPasswordValid
                                        ? const Color(0xFF66BB6A)
                                        : Colors.grey[500],
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildValidationIcon(
                                    _confirmPasswordValid,
                                    _confirmPasswordTouched,
                                    passwordControllerSame.text),
                          IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _getBorderColor(_confirmPasswordValid, _confirmPasswordTouched),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _getBorderColor(_confirmPasswordValid, _confirmPasswordTouched),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _getBorderColor(_confirmPasswordValid, _confirmPasswordTouched),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  _buildFieldError(_confirmPasswordError),

                  const SizedBox(height: 24),

                  // Botón de Registro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid && !_isRegistering
                            ? Colors.redAccent
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: _isFormValid && !_isRegistering ? 2 : 0,
                      ),
                      onPressed: _isRegistering ? null : _handleRegister,
                      child: _isRegistering
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Registrarse",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Link a Login
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿Ya tienes cuenta?",
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _isRegistering
                              ? null
                              : () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: _isRegistering
                                  ? Colors.grey[400]
                                  : Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ),
        ],
      ),
    );
  }
}