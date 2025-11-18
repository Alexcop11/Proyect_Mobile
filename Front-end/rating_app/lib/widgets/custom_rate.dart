import 'package:flutter/material.dart';

class custom_rate extends StatelessWidget {
  final double rating;       // ej. 4.8
  final int totalReviews;    // ej. 127
  final VoidCallback onPressed; // acción del botón

  const custom_rate({
    super.key,
    required this.rating,
    required this.totalReviews,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "VALORACIÓN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                if (index < fullStars) {
                  return const Icon(Icons.star, color: Colors.amber);
                } else if (index == fullStars && hasHalfStar) {
                  return const Icon(Icons.star_half, color: Colors.amber);
                } else {
                  return const Icon(Icons.star_border, color: Colors.grey);
                }
              }),
            ),
            const SizedBox(height: 8),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Basado en $totalReviews reseñas",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onPressed,
              child: const Text("Ver reseñas"),
            ),
          ],
        ),
      ),
    );
  }
}