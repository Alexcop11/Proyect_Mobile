import 'package:flutter/material.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/client/restaurant_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Lista de restaurantes favoritos
  List<Map<String, dynamic>> favoritos = [
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

  void _onFavoriteTap(int index, bool isFavorite) {
    setState(() {
      if (!isFavorite) {
        // Si se desmarca como favorito, eliminarlo de la lista
        favoritos.removeAt(index);
      }
    });
  }

  void _onVerRestaurante(int index) {
    debugPrint('Ver restaurante: ${favoritos[index]['nombre']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBarCustom(
        title: 'Mis Favoritos',
        onNotificationTap: () {
          debugPrint('Notificaciones tapped');
        },
      ),
      body: favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega restaurantes a tus favoritos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${favoritos.length} ${favoritos.length == 1 ? 'restaurante' : 'restaurantes'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(
                        favoritos.length,
                        (index) => RestaurantCard(
                          nombre: favoritos[index]['nombre'],
                          tipo: favoritos[index]['tipo'],
                          calificacion: favoritos[index]['calificacion'],
                          reviews: favoritos[index]['reviews'],
                          ubicacion: favoritos[index]['ubicacion'],
                          distancia: favoritos[index]['distancia'],
                          tiempo: favoritos[index]['tiempo'],
                          foto: favoritos[index]['foto'],
                          isFavorite: favoritos[index]['isFavorite'],
                          isOpen: favoritos[index]['isOpen'],
                          onFavoriteTap: (isFavorite) {
                            _onFavoriteTap(index, isFavorite);
                          },
                          onVerRestaurante: () {
                            _onVerRestaurante(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}   