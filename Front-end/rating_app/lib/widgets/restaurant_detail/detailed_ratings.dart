import 'package:flutter/material.dart';

class DetailedRatings extends StatelessWidget {
  final List reviews;

  const DetailedRatings({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ratings = _calculateAverageRatings();

    final categories = [
      {'name': 'Comida', 'rating': ratings['comida']!},
      {'name': 'Servicio', 'rating': ratings['servicio']!},
      {'name': 'Ambiente', 'rating': ratings['ambiente']!},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        double percent = (category['rating'] as double) / 5;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nombre categoría
              SizedBox(
                width: 80,
                child: Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Barra con degradado
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * percent;

                      return Stack(
                        children: [
                          // Barra coloreada en gradiente
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF6A5D), // rojo suave
                                  Color(0xFFFFE067), // amarillo
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Valor numérico
              Text(
                (category['rating'] as double).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, double> _calculateAverageRatings() {
    if (reviews.isEmpty) {
      return {
        'comida': 0.0,
        'servicio': 0.0,
        'ambiente': 0.0,
      };
    }

    double totalComida = 0;
    double totalServicio = 0;
    double totalAmbiente = 0;

    for (var review in reviews) {
      totalComida += (review.puntuacionComida ?? 0).toDouble();
      totalServicio += (review.puntuacionServicio ?? 0).toDouble();
      totalAmbiente += (review.puntuacionAmbiente ?? 0).toDouble();
    }

    return {
      'comida': totalComida / reviews.length,
      'servicio': totalServicio / reviews.length,
      'ambiente': totalAmbiente / reviews.length,
    };
  }
}
