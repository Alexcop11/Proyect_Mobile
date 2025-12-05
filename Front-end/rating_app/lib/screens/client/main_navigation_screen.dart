import 'package:flutter/material.dart';
import 'package:rating_app/screens/client/home_cliente_screen.dart';
import 'package:rating_app/screens/client/explore_screen.dart';
import 'package:rating_app/screens/client/favorites_screen.dart';
import 'package:rating_app/screens/client/profile_screen.dart';
import 'package:rating_app/widgets/common/bottom_navigation_custom.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      debugPrint('Navegando a pantalla: $index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const ExploreScreen(),
          // Pasar directamente la función _onItemTapped
          FavoritesScreen(
            onNavigateToHome: () => _onItemTapped(0),
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationCustom(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}