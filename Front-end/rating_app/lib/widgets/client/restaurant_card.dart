import 'package:flutter/material.dart';

class RestaurantCard extends StatefulWidget {
  final String nombre;
  final String tipo;
  final double calificacion;
  final int reviews;
  final String ubicacion;
  final String distancia;
  final String tiempo;
  final String foto;
  final bool isFavorite;
  final bool isOpen; 
  final ValueChanged<bool>? onFavoriteTap;
  final VoidCallback? onVerRestaurante;

  const RestaurantCard({
    Key? key,
    required this.nombre,
    required this.tipo,
    required this.calificacion,
    required this.reviews,
    required this.ubicacion,
    required this.distancia,
    required this.tiempo,
    required this.foto,
    required this.isFavorite,
    this.isOpen = false,
    this.onFavoriteTap,
    this.onVerRestaurante,
  }) : super(key: key);

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
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
          // Imagen y Favorito
          _buildImageSection(),
          // Información
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
              widget.foto,
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
        if (widget.isOpen)
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
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              widget.onFavoriteTap?.call(_isFavorite);
            },
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
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del restaurante
          Text(
            widget.nombre,
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
                  widget.tipo,
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
          // Precio promedio (si lo necesitas, sino elimina esta línea)
          Text(
            'Precio Promedio',
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
          _buildVerRestauranteButton(),
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
          '${widget.calificacion}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.reviews})',
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
        Icon(
          Icons.location_on,
          size: 18,
          color: const Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.ubicacion,
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

  Widget _buildVerRestauranteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.onVerRestaurante ?? () {},
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