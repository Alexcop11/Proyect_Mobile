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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$rating ★★★★★",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.redAccent),
            ),
            const SizedBox(height: 4),
            Text(
              "Basado en $totalReviews reseñas",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildRatingBar("5 ★", fiveStarRatio, Colors.yellow),
            const SizedBox(height: 8),
            _buildRatingBar("4 ★", fourStarRatio, Colors.orange),
            const SizedBox(height: 8),
            _buildRatingBar("3 ★", threeStarRatio, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label, style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}