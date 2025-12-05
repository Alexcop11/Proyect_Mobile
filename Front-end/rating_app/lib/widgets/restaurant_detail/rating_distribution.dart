import 'package:flutter/material.dart';

class RatingDistribution extends StatelessWidget {
  final List reviews;

  const RatingDistribution({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distribution = _calculateDistribution();

    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final percentage = distribution[stars] ?? 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '$stars',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
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
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<int, double> _calculateDistribution() {
    if (reviews.isEmpty) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }

    // Contar cuántas reseñas hay de cada rating
    Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in reviews) {
      // Calcular el rating promedio de esta reseña
      final avgRating = ((review.puntuacionComida ?? 0) +
              (review.puntuacionServicio ?? 0) +
              (review.puntuacionAmbiente ?? 0)) /
          3;

      // Redondear al entero más cercano
      final roundedRating = avgRating.round().clamp(1, 5);
      counts[roundedRating] = (counts[roundedRating] ?? 0) + 1;
    }

    // Convertir a porcentajes
    Map<int, double> percentages = {};
    for (var stars in [5, 4, 3, 2, 1]) {
      percentages[stars] = (counts[stars]! / reviews.length) * 100;
    }

    return percentages;
  }
}