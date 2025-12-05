import 'package:flutter/material.dart';

class DetailedRatings extends StatelessWidget {
  final List reviews;

  const DetailedRatings({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular promedios de cada categoría
    final ratings = _calculateAverageRatings();

    final categories = [
      {'name': 'Comida', 'rating': ratings['comida']!},
      {'name': 'Servicio', 'rating': ratings['servicio']!},
      {'name': 'Ambiente', 'rating': ratings['ambiente']!},
    ];

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (category['rating'] as double) / 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFC107),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(category['rating'] as double).toStringAsFixed(1)}',
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