import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int page;
  final Function(int) onTap;
  final String role;

  const Navbar({
    super.key,
    required this.page,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = role == "RESTAURANTE"
        ? const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.reviews), label: 'Reseñas'),
            NavigationDestination(
                icon: Icon(Icons.view_headline_outlined), label: 'Configuración'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Descubrir'),
            NavigationDestination(icon: Icon(Icons.favorite), label: 'Favoritos'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ];

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
          return IconThemeData(
            color: states.contains(MaterialState.selected)
                ? Colors.white
                : Colors.redAccent,
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: Colors.redAccent);
        }),
      ),
      child: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: Colors.redAccent,
        selectedIndex: page,
        onDestinationSelected: onTap,
        destinations: destinations,
      ),
    );
  }
}