import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/services/auth_service.dart';
import 'package:rating_app/core/services/user_service.dart';
import 'package:rating_app/core/services/restaurant_service.dart';
import 'package:rating_app/core/services/favorite_service.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear instancias una sola vez
    final apiServices = ApiServices();
    final authService = AuthService(apiServices);
    final userService = UserService(apiServices);
    final restaurantService = RestaurantService(apiServices);
    final favoriteService = FavoriteService(apiServices);
    
    return MultiProvider(
      providers: [
        // 1. Proveedor de ApiServices
        Provider<ApiServices>.value(
          value: apiServices,
        ),
        
        // 2. Proveedor de AuthService
        Provider<AuthService>.value(
          value: authService,
        ),
        
        // 3. Proveedor de UserService
        Provider<UserService>.value(
          value: userService,
        ),
        
        // 4. Proveedor de RestaurantService
        Provider<RestaurantService>.value(
          value: restaurantService,
        ),
        
        // 5. Proveedor de AuthProvider (ChangeNotifier)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, userService),
        ),
        
        // 6. Proveedor de RestaurantProvider (ChangeNotifier)
        ChangeNotifierProvider<RestaurantProvider>(
          create: (_) => RestaurantProvider(restaurantService),
        ),
        // 7. Proveedor de FavoriteService
        Provider<FavoriteService>.value(
          value: favoriteService,
        ),
        // 8. Proveedor de FavoriteProvider (ChangeNotifier)
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(favoriteService),
        ),  

      ],
      child: MaterialApp(
        title: 'Rating App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}