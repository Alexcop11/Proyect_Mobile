import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/screens/map_screen.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/restaurant_provider.dart';
import 'core/providers/favorite_provider.dart';

import 'core/services/auth_service.dart';
import 'core/services/api_services.dart';
import 'core/services/user_service.dart';
import 'core/services/restaurant_service.dart';
import 'core/services/favorite_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Notificación en background: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase inicializado");
  } catch (e) {
    debugPrint("❌ Error al inicializar Firebase: $e");
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiServices>(create: (_) => ApiServices()),

        ProxyProvider<ApiServices, AuthService>(
          update: (_, apiService, __) => AuthService(apiService),
        ),

        ProxyProvider<ApiServices, UserService>(
          update: (_, apiService, __) => UserService(apiService),
        ),

        ChangeNotifierProxyProvider2<AuthService, UserService, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
          update: (_, authService, userService, __) =>
              AuthProvider(authService, userService),
        ),

        ProxyProvider<ApiServices, RestaurantService>(
          update: (_, apiService, __) => RestaurantService(apiService),
        ),

        ChangeNotifierProxyProvider<RestaurantService, RestaurantProvider>(
          create: (context) =>
              RestaurantProvider(context.read<RestaurantService>()),
          update: (_, restaurantService, __) =>
              RestaurantProvider(restaurantService),
        ),

        ProxyProvider<ApiServices, FavoriteService>(
          update: (_, apiService, __) => FavoriteService(apiService),
        ),

        ChangeNotifierProxyProvider<FavoriteService, FavoriteProvider>(
          create: (context) => FavoriteProvider(context.read<FavoriteService>()),
          update: (_, favoriteService, __) => FavoriteProvider(favoriteService),
        ),
      ],
      child: MaterialApp(
        title: 'Consumo Backend App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthWrapper(), // ✅ aquí se inicializan notificaciones
        debugShowCheckedModeBanner: false,
        routes: {
          "/search": (context) => const MapaScreen(),
        },
      ),
    );
  }
}