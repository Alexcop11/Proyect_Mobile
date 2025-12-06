import 'package:flutter/material.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/core/services/notification_services.dart';
import 'package:rating_app/core/services/user_service.dart';
import 'package:rating_app/models/user.dart';

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

  AuthProvider(this._authService, this._userService);

  Future<void> initializeAuth() async {
    try {
      final hasSession = await _authService.hasActiveSession();

      if (hasSession) {
        _isAuthenticated = true;
        _role = await _authService.getStoredRole();
        _token = await _authService.getStoredToken();
        _email = await _authService.getStoredEmail();

        if (_email != null) {
          await loadCurrentUser();
        }
      } else {
        _isAuthenticated = false;
        _role = null;
        _token = null;
        _email = null;
        _id = null;
      }
    } catch (_) {
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

  Future<void> initializeUserServices() async {
    if (currentUser == null) return;

    await NotificationService().initialize();
    await NotificationService().updatePushToken(currentUser!.idUsuario!);
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
        } else {
          debugPrint('⚠️ No se pudo obtener el usuario');
          _errorMessage = 'No se pudo cargar la información del usuario';
        }
      } else {
        debugPrint('⚠️ No hay email guardado');
        _errorMessage = 'No hay sesión activa';
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
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔐 Intentando login con: $email');
      final result = await _authService.login(email, password);
      _token = result['token'];
      _role = result['role'];
      _email = result['email'];

      final userData = await _authService.getUser(_email!);
      _nombre = userData['nombre'];
      _apellido = userData['apellido'];
      _id = userData['idUsuario'];

      await loadCurrentUser();

      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
        _isAuthenticated = true;
        _errorMessage = null;
        await loadCurrentUser();
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _errorMessage = "No se recibió token o rol válido";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      debugPrint(
        '📝 Actualizando perfil de usuario ID: ${_currentUser!.idUsuario}',
      );

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
      debugPrint(
        '🔒 Cambiando contraseña para usuario ID: ${_currentUser!.idUsuario}',
      );

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

      _nombre = userData['nombre'];
      _apellido = userData['apellido'];
      _role = userData['tipousuario'];
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
    _token = null;
    _role = null;
    _email = null;
    _nombre = null;
    _apellido = null;
    _currentUser = null;
    _id = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
