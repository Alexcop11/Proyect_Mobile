import 'package:flutter/material.dart';

class CustomReviews extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double fiveStarRatio;
  final double fourStarRatio;
  final double threeStarRatio;

  const CustomReviews({
    super.key,
    required this.rating,
    required this.totalReviews,
    required this.fiveStarRatio,
    required this.fourStarRatio,
    required this.threeStarRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sección superior con rating y texto
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating grande a la izquierda
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Estrellas doradas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Barras de progreso a la derecha
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basado en $totalReviews reseñas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingBar(5, fiveStarRatio),
                    const SizedBox(height: 8),
                    _buildRatingBar(4, fourStarRatio),
                    const SizedBox(height: 8),
                    _buildRatingBar(3, threeStarRatio),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Row(
      children: [
        // Número de estrellas con ícono
        SizedBox(
          width: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$stars',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.star,
                size: 14,
                color: Color(0xFF1A1A1A),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Barra de progreso con gradiente
        Expanded(
          child: Stack(
            children: [
              // Barra de fondo gris
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Barra de progreso con gradiente
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradientColors(stars),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(int stars) {
    // Gradiente que va de rojo a amarillo
    switch (stars) {
      case 5:
        return [
          const Color(0xFFFF5252), // Rojo
          const Color(0xFFFF9800), // Naranja
          const Color(0xFFFFC107), // Amarillo
        ];
      case 4:
        return [
          const Color(0xFFFF5252), // Rojo
          const Color(0xFFFF9800), // Naranja
          const Color(0xFFFFC107), // Amarillo
        ];
      case 3:
        return [
          const Color(0xFFFF5252), // Rojo
          const Color(0xFFFF9800), // Naranja
          const Color(0xFFFFC107), // Amarillo
        ];
      default:
        return [
          const Color(0xFFFF5252),
          const Color(0xFFFFC107),
        ];
    }
  }
}