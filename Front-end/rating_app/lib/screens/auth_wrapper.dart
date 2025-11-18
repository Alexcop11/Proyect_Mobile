import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/home_screen.dart';
import 'package:rating_app/screens/restaurant_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }
    if (authProvider.role == "RESTAURANTE") {
      return const RestaurantScreen();
    } else {
      return const HomeScreen();
    }
  }
}