import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rating_app/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  String? _role;
  String? _email;
  String? _nombre;
  String? _apellido;
  String? _errorMessage;

  String? get token => _token;
  String? get role => _role;
  String? get email => _email;
  String? get nombre => _nombre;
  String? get apellido => _apellido;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  AuthProvider(this._authService) {
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

        if (_email != null) {
          await _authService.getUser(_email!);
        }
      } else {
        _isAuthenticated = false;
        _role = null;
        _token = null;
        _email = null;
      }
    } catch (_) {
      _isAuthenticated = false;
      _role = null;
      _token = null;
      _email = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _token = result['token'];
      _role = result['role'];
      _email = result['email'];

      final userData = await _authService.getUser(_email!);
      _nombre = userData['nombre'];
      _apellido = userData['apellido'];

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

  Future<bool> fetchUserData() async {
    try {
      if (_email == null || _email!.isEmpty) {
        throw Exception("No hay correo guardado en sesión");
      }

      final userData = await _authService.getUser(_email!);
      await _authService.getRestaurantByEmail(_email!);

      debugPrint("📥 Respuesta: ${jsonEncode(userData)}");

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

  Future<bool> createRestaurant({
    required String nombre,
    required String descripcion,
    required String direccion,
    required double latitud,
    required double longitud,
    required String telefono,
    required String horarioApertura,
    required String horarioCierre,
    required double precioPromedio,
    required String categoria,
    required String menuUrl,
    required String fechaRegistro,
    required bool activo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_email == null) {
        throw Exception("No hay sesión activa para crear restaurante");
      }

      final userData = await _authService.getUser(_email!);
      final idUsuarioPropietario = userData['idUsuario'];

      final result = await _authService.createRestaurant(
        idUsuarioPropietario: idUsuarioPropietario,
        nombre: nombre,
        descripcion: descripcion,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        telefono: telefono,
        horarioApertura: horarioApertura,
        horarioCierre: horarioCierre,
        precioPromedio: precioPromedio,
        categoria: categoria,
        menuUrl: menuUrl,
        fechaRegistro: fechaRegistro,
        activo: activo,
      );

      debugPrint("🏠 Restaurante creado: ${result['idRestaurante']}");
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint("❌ Error al crear restaurante: $_errorMessage");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRestaurant({
    required int idRestaurante,
    required String nombre,
    required String descripcion,
    required String direccion,
    required double latitud,
    required double longitud,
    required String telefono,
    required String horarioApertura,
    required String horarioCierre,
    required double precioPromedio,
    required String categoria,
    required String menuUrl,
    required String fechaRegistro,
    required bool activo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_email == null) {
        throw Exception("No hay sesión activa para actualizar restaurante");
      }

      final userData = await _authService.getUser(_email!);
      final idUsuarioPropietario = userData['idUsuario'];

      final result = await _authService.updateRestaurant(
        idRestaurante: idRestaurante,
        idUsuarioPropietario: idUsuarioPropietario,
        nombre: nombre,
        descripcion: descripcion,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        telefono: telefono,
        horarioApertura: horarioApertura,
        horarioCierre: horarioCierre,
        precioPromedio: precioPromedio,
        categoria: categoria,
        menuUrl: menuUrl,
        fechaRegistro: fechaRegistro,
        activo: activo,
      );

      debugPrint("Restaurante actualizado: ${result['idRestaurante']}");
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint("❌ Error al actualizar restaurante: $_errorMessage");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkRestaurantStatus(String email) async {
    try {
      final restaurantData = await _authService.getRestaurantByEmail(email);
      debugPrint("📥 Respuesta: ${jsonEncode(restaurantData)}");

      return restaurantData;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _role = null;
    _email = null;
    _nombre = null;
    _apellido = null;
    notifyListeners();
  }
}
