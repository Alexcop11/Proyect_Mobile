import 'package:flutter/cupertino.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      final hasSesion = await _authService.hasActiveSession();
      if (hasSesion) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      _errorMessage = "Error al encontrar o verificar sesion";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      _user = result['user'];
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
