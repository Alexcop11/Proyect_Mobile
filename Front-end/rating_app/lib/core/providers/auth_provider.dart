import 'package:flutter/material.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/core/services/user_service.dart';
import 'package:rating_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  String? _role;
  String? _email;
  String? _id;
  String? _nombre;
  String? _apellido;
  User? _currentUser;
  String? _errorMessage;

  String? get token => _token;
  String? get role => _role;
  String? get email => _email;
  String? get id => _id;
  String? get nombre => _nombre;
  String? get apellido => _apellido;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  AuthProvider(this._authService, this._userService) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final hasSession = await _authService.hasActiveSession();

      if (hasSession) {
        _isAuthenticated = true;
        _role = await _authService.getStoredRole();
        _token = await _authService.getStoredToken();
        _email = await _authService.getStoredEmail();

        // Intentar cargar usuario desde cache local primero
        final cachedUser = await _loadUserFromCache();
        
        if (cachedUser != null) {
          debugPrint('✅ Usuario cargado desde cache');
          _currentUser = cachedUser;
          _nombre = cachedUser.nombre;
          _apellido = cachedUser.apellido;
          _id = cachedUser.idUsuario.toString();
          
          // Cargar en segundo plano para actualizar datos
          loadCurrentUser();
        } else if (_email != null) {
          await loadCurrentUser();
        }
      } else {
        _isAuthenticated = false;
        _role = null;
        _token = null;
        _email = null;
        _id = null;
      }
    } catch (e) {
      debugPrint('❌ Error en _initializeAuth: $e');
      _isAuthenticated = false;
      _role = null;
      _token = null;
      _email = null;
      _id = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Guardar usuario en cache local
  Future<void> _saveUserToCache(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'idUsuario': user.idUsuario,
        'nombre': user.nombre,
        'apellido': user.apellido,
        'email': user.email,
        'telefono': user.telefono,
        'tipoUsuario': user.tipoUsuario.toString(),
        'activo': user.activo,
        'fechaRegistro': user.fechaRegistro?.toIso8601String(),
      });
      
      await prefs.setString('cached_user', userJson);
      debugPrint('💾 Usuario guardado en cache local');
    } catch (e) {
      debugPrint('❌ Error guardando usuario en cache: $e');
    }
  }

  /// Cargar usuario desde cache local
  Future<User?> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');
      
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        
        return User(
          idUsuario: userData['idUsuario'] as int?,
          nombre: userData['nombre'] as String? ?? 'Usuario',
          apellido: userData['apellido'] as String? ?? '',
          email: userData['email'] as String? ?? '',
          telefono: userData['telefono'] as String?,
          tipoUsuario: _parseTipoUsuario(userData['tipoUsuario'] as String? ?? 'NORMAL'),
          activo: (userData['activo'] as bool?) ?? true,
          fechaRegistro: userData['fechaRegistro'] != null 
            ? DateTime.tryParse(userData['fechaRegistro'] as String) 
            : null,
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando usuario desde cache: $e');
    }
    return null;
  }

  /// Limpiar cache de usuario
  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
      debugPrint('🗑️ Cache de usuario limpiado');
    } catch (e) {
      debugPrint('❌ Error limpiando cache: $e');
    }
  }

  TipoUsuario _parseTipoUsuario(String tipo) {
    if (tipo.contains('RESTAURANTE')) {
      return TipoUsuario.RESTAURANTE;
    } else {
      return TipoUsuario.NORMAL;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final email = await _authService.getUserEmail();
      debugPrint('📧 Email recuperado: $email');
      
      if (email != null && email.isNotEmpty) {
        debugPrint('🔄 Cargando datos del usuario desde el servidor...');
        
        _currentUser = await _userService.getUserByEmail(email);
        
        if (_currentUser != null) {
          debugPrint('✅ Usuario cargado: ${_currentUser!.nombre}');
          _nombre = _currentUser!.nombre;
          _apellido = _currentUser!.apellido;
          _id = _currentUser!.idUsuario.toString();
          
          // Guardar en cache
          await _saveUserToCache(_currentUser!);
          
          notifyListeners();
        } else {
          debugPrint('⚠️ No se pudo obtener el usuario');
          _errorMessage = 'No se pudo cargar la información del usuario';
          notifyListeners();
        }
      } else {
        debugPrint('⚠️ No hay email guardado');
        _errorMessage = 'No hay sesión activa';
        notifyListeners();
      }
    } on Exception catch (e) {
      debugPrint('❌ Error cargando usuario: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      final email = await _authService.getUserEmail();
      if (email != null) {
        debugPrint('⚠️ Continuando con datos básicos del usuario');
        _currentUser = User(
          nombre: 'Usuario',
          email: email,
          tipoUsuario: TipoUsuario.NORMAL,
          activo: true,
        );
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔐 Intentando login con: $email');
      final result = await _authService.login(email, password);
      _token = result['token'];
      _role = result['role'];
      _email = result['email'];

      // ✅ CORREGIDO: Obtener datos del usuario directamente del servidor
      debugPrint('🔄 Obteniendo datos completos del usuario...');
      final userData = await _authService.getUser(_email!);
      
      _nombre = userData['nombre'] as String?;
      _apellido = userData['apellido'] as String?;
      _id = userData['idUsuario']?.toString();

      // Crear objeto User completo con manejo seguro de nulls
      _currentUser = User(
        idUsuario: userData['idUsuario'] as int?,
        nombre: userData['nombre'] as String? ?? 'Usuario',
        apellido: userData['apellido'] as String? ?? '',
        email: userData['email'] as String? ?? _email!,
        telefono: userData['telefono'] as String?,
        tipoUsuario: _parseTipoUsuario(userData['tipoUsuario'] as String? ?? 'NORMAL'),
        activo: (userData['activo'] as bool?) ?? true,
        fechaRegistro: userData['fechaRegistro'] != null 
          ? DateTime.tryParse(userData['fechaRegistro'] as String) 
          : null,
      );

      debugPrint('✅ Usuario completo cargado: ${_currentUser!.nombre} ${_currentUser!.apellido}');
      
      // Guardar en cache
      await _saveUserToCache(_currentUser!);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
    required String tipousuario,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📝 Intentando registro con: $email');
      final result = await _authService.register(
        nombre: nombre,
        apellido: apellido,
        email: email,
        password: password,
        telefono: telefono,
        tipousuario: tipousuario,
      );

      final token = result['token'];
      final role = result['role'];

      if (token != null && role != null) {
        _token = token;
        _role = role;
        _email = email;
        _isAuthenticated = true;
        _errorMessage = null;
        
        // Cargar datos completos del usuario
        await loadCurrentUser();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _errorMessage = "No se recibió token o rol válido";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error en registro: $e');
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      debugPrint('📝 Actualizando perfil de usuario ID: ${_currentUser!.idUsuario}');
        
      final updatedUser = await _userService.updateProfile(
        idUsuario: _currentUser!.idUsuario!,
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        tipoUsuario: _currentUser!.tipoUsuario.toString().split('.').last,
        activo: _currentUser!.activo,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        _nombre = updatedUser.nombre;
        _apellido = updatedUser.apellido;
        
        // Actualizar cache
        await _saveUserToCache(updatedUser);
        
        debugPrint('✅ Perfil actualizado correctamente');
        notifyListeners();
        return true;
      }

      _errorMessage = 'No se pudo actualizar el perfil';
      return false;
    } catch (e) {
      debugPrint('❌ Error actualizando perfil: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (_currentUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      debugPrint('🔒 Cambiando contraseña para usuario ID: ${_currentUser!.idUsuario}');
      
      final success = await _userService.changePassword(
        idUsuario: _currentUser!.idUsuario!,
        newPassword: newPassword,
      );

      if (success) {
        debugPrint('✅ Contraseña actualizada correctamente');
      } else {
        _errorMessage = 'No se pudo cambiar la contraseña';
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error cambiando contraseña: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> fetchUserData() async {
    try {
      if (_email == null || _email!.isEmpty) {
        throw Exception("No hay correo guardado en sesión");
      }

      final userData = await _authService.getUser(_email!);
      debugPrint("📥 Respuesta: $userData");

      _nombre = userData['nombre'] as String?;
      _apellido = userData['apellido'] as String?;
      _role = userData['tipousuario'] as String?;
      _id = userData['idUsuario']?.toString();
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _clearUserCache();
    
    _token = null;
    _role = null;
    _email = null;
    _nombre = null;
    _apellido = null;
    _currentUser = null;
    _id = null;
    _isAuthenticated = false;
    
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}