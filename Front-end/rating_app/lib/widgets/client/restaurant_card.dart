import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/models/restaurant.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/screens/client/restaurant_detail_page.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  Future<void> _handleFavoriteTap(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar favoritos'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final restaurantId = restaurant.idRestaurante;
    if (restaurantId == null) return;

    final isFavorite = favoriteProvider.isFavorite(restaurantId);

    final success = await favoriteProvider.toggleFavorite(
      userId: authProvider.currentUser!.idUsuario!,
      restaurantId: restaurantId,
    );

    if (success && context.mounted) {
      final message = !isFavorite
          ? 'Restaurante agregado a favoritos'
          : 'Restaurante eliminado de favoritos';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favoriteProvider.errorMessage ?? 'Error al actualizar favorito',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

 void _navigateToDetail(BuildContext context, bool isFavorite) {
  String horarioCompleto = '';
  if (restaurant.horarioApertura.isNotEmpty && 
      restaurant.horarioCierre.isNotEmpty) {
    horarioCompleto = '${restaurant.horarioApertura} - ${restaurant.horarioCierre}';
  }

  String status = 'Cerrado';
  if (restaurant.isOpenNow) {
    status = 'Abierto • Cierra a las ${restaurant.horarioCierre}';
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RestaurantDetailPage(
        restaurantId: restaurant.idRestaurante!,
        nombre: restaurant.nombre,
        tipo: restaurant.categoria,
        calificacion: restaurant.calificacionPromedio ?? 0.0,
        reviews: restaurant.numeroReviews ?? 0,
        ubicacion: restaurant.direccion,
        foto: restaurant.menuUrl.isNotEmpty
            ? restaurant.menuUrl
            : 'assets/images/restaurant_placeholder.jpg',
        isOpen: restaurant.isOpenNow,
        status: status,
        description: restaurant.descripcion,
        phone: restaurant.telefono,
        horario: horarioCompleto,
        precioPromedio: restaurant.precioPromedio,
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final restaurantId = restaurant.idRestaurante;
        final isFavorite = restaurantId != null 
            ? favoriteProvider.isFavorite(restaurantId)
            : false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context, isFavorite),
              _buildInfoSection(context, isFavorite),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(BuildContext context, bool isFavorite) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Container(
            height: 200,
            width: double.infinity,
            color: const Color(0xFFE8E8E8),
            child: Image.asset(
              restaurant.menuUrl.isNotEmpty
                  ? restaurant.menuUrl
                  : 'assets/images/restaurante.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Badge "Abierto ahora"
        if (restaurant.isOpenNow)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 8,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Abierto ahora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Botón de favorito
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => _handleFavoriteTap(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del restaurante
          Text(
            restaurant.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Tipo de comida y calificación en la misma línea
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.categoria,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRating(),
            ],
          ),
          const SizedBox(height: 4),
          // Precio promedio
          Text(
            '\$${restaurant.precioPromedio.toStringAsFixed(0)} MXN promedio',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Ubicación
          _buildLocationRow(),
          const SizedBox(height: 16),
          // Botón Ver Restaurante
          _buildVerRestauranteButton(context, isFavorite),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star,
          color: Color(0xFFFFC107),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${restaurant.calificacionPromedio ?? 0.0}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${restaurant.numeroReviews ?? 0})',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          size: 18,
          color: Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            restaurant.direccion,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVerRestauranteButton(BuildContext context, bool isFavorite) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToDetail(context, isFavorite),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Ver Restaurante',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}