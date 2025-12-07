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
import 'core/providers/photo_provider.dart';
import 'core/providers/notification_provider.dart'; // ⭐ Importar

import 'core/services/auth_service.dart';
import 'core/services/api_services.dart';
import 'core/services/user_service.dart';
import 'core/services/restaurant_service.dart';
import 'core/services/favorite_service.dart';
import 'core/services/photo_service.dart';
import 'core/services/notification_services.dart';

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
    final apiServices = ApiServices();
    final authService = AuthService(apiServices);
    final userService = UserService(apiServices);
    final restaurantService = RestaurantService(apiServices);
    final favoriteService = FavoriteService(apiServices);
    final photoService = PhotoService(apiServices);
    
    final notificationService = NotificationService();
    
    return MultiProvider(
      providers: [
        
        // 1. ApiServices
        Provider<ApiServices>.value(
          value: apiServices,
        ),
        
        // 2. AuthService
        Provider<AuthService>.value(
          value: authService,
        ),
        
        // 3. UserService
        Provider<UserService>.value(
          value: userService,
        ),
        
        // 4. RestaurantService
        Provider<RestaurantService>.value(
          value: restaurantService,
        ),
        
        // 5. FavoriteService
        Provider<FavoriteService>.value(
          value: favoriteService,
        ),
        
        // 6. PhotoService
        Provider<PhotoService>.value(
          value: photoService,
        ),
        
        // 7. NotificationService (Singleton)
        Provider<NotificationService>.value(
          value: notificationService,
        ),
        
        
        // 8. AuthProvider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, userService),
        ),
        
        // 9. RestaurantProvider
        ChangeNotifierProvider<RestaurantProvider>(
          create: (_) => RestaurantProvider(restaurantService),
        ),
        
        // 10. FavoriteProvider
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(favoriteService),
        ),
        
        // 11. PhotoProvider
        ChangeNotifierProvider<PhotoProvider>(
          create: (_) => PhotoProvider(photoService),
        ),
        
        // 12. NotificationProvider ⭐ NUEVO
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'FoodFinder App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        routes: {
          "/search": (context) => const MapaScreen(),
        },
      ),
    );
  }
}