import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double calificacion;
  final int reviews;

  const RatingSummary({
    Key? key,
    required this.calificacion,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '$calificacion',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < calificacion.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Basado en $reviews reseñas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}