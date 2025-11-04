import 'package:flutter/cupertino.dart';
import 'package:rating_app/core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initializeAuth() async {
    try {
      final hasSession = await _authService.hasActiveSession();
      _isAuthenticated = hasSession;
    } catch (_) {
      _isAuthenticated = false;
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
      final token = result['token'];

      if (token != null) {
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _errorMessage = "No se recibió token válido";
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

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
