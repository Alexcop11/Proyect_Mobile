import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/client/main_navigation_screen.dart';
import 'package:rating_app/screens/main_restaurant_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializa la autenticación al arrancar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // ✅ Solo decide la navegación según el rol
    return authProvider.role == "RESTAURANTE"
        ? const MainRestaurantNavigation()
        : const MainNavigationScreen();
  }
}