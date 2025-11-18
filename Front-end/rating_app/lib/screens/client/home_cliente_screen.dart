import 'package:flutter/material.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/welcome_card.dart';
import 'package:rating_app/widgets/client/search.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';
import 'package:rating_app/widgets/common/bottom_navigation_custom.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({Key? key}) : super(key: key);

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> restaurantes = [
    {
      'id': 1,
      'nombre': 'La casona del chef',
      'tipo': 'Fusión Mediterránea',
      'calificacion': 4.8,
      'reviews': 189,
      'ubicacion': 'Av. de la Reforma 125, Col. Juárez',
      'distancia': '1.2 km',
      'tiempo': '25-30 min',
      'foto': 'assets/images/restaurant1.jpg',
      'isFavorite': false,
      'isOpen': true,
    },
    {
      'id': 2,
      'nombre': 'El Jardín Secreto',
      'tipo': 'Cocina Mexicana',
      'calificacion': 4.6,
      'reviews': 245,
      'ubicacion': 'Calle Juárez 89, Centro',
      'distancia': '2.5 km',
      'tiempo': '30-35 min',
      'foto': 'assets/images/restaurant2.jpg',
      'isFavorite': false,
      'isOpen': false,
    },
    {
      'id': 3,
      'nombre': 'Sushi Master',
      'tipo': 'Japonesa',
      'calificacion': 4.9,
      'reviews': 312,
      'ubicacion': 'Av. Insurgentes 456, Roma',
      'distancia': '3.1 km',
      'tiempo': '35-40 min',
      'foto': 'assets/images/restaurant3.jpg',
      'isFavorite': true,
      'isOpen': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoriteTap(int index, bool isFavorite) {
    setState(() {
      restaurantes[index]['isFavorite'] = isFavorite;
    });
  }

  void _onVerRestaurante(int index) {
    // Navegar a detalle del restaurante
    debugPrint('Ver restaurante: ${restaurantes[index]['nombre']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBarCustom(
        title: 'FoodFinder',
        onNotificationTap: () {
          debugPrint('Notificaciones tapped');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Card de bienvenida
            WelcomeCard(
              nombre: 'Maria',
              initiales: 'MG',
            ),
            const SizedBox(height: 16),
            // Buscador
            Search(
              controller: _searchController,
              onChanged: (value) {
                debugPrint('Buscando: $value');
              },
              onSearchTap: () {
                debugPrint('Search tapped');
              },
            ),
            const SizedBox(height: 24),
            // Lista de restaurantes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  restaurantes.length,
                  (index) => RestaurantCard(
                    nombre: restaurantes[index]['nombre'],
                    tipo: restaurantes[index]['tipo'],
                    calificacion: restaurantes[index]['calificacion'],
                    reviews: restaurantes[index]['reviews'],
                    ubicacion: restaurantes[index]['ubicacion'],
                    distancia: restaurantes[index]['distancia'],
                    tiempo: restaurantes[index]['tiempo'],
                    foto: restaurantes[index]['foto'],
                    isFavorite: restaurantes[index]['isFavorite'],
                    isOpen: restaurantes[index]['isOpen'],
                    onFavoriteTap: (isFavorite) {
                      _onFavoriteTap(index, isFavorite);
                    },
                    onVerRestaurante: () {
                      _onVerRestaurante(index);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}