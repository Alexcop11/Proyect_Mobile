import 'package:flutter/material.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/screens/restaurant_reviews.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';

class MainRestaurantNavigation extends StatefulWidget {
  const MainRestaurantNavigation({super.key});

  @override
  State<MainRestaurantNavigation> createState() => _MainRestaurantNavigationState();
}

class _MainRestaurantNavigationState extends State<MainRestaurantNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      debugPrint('Navegando a pantalla: $index');
    }
  }

  // Método público para navegar desde otras pantallas
  void navigateToReviews() {
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    return Navigationscaffold(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      appBar: null, // El AppBar se maneja en cada pantalla individual
      child: IndexedStack(
        index: _selectedIndex,
        children: const [
          RestaurantScreen(),
          RestaurantReviews(),
          Restaurant_manage_Screen(),
        ],
      ),
    );
  }
}