import 'package:flutter/material.dart';

class RatingDistribution extends StatelessWidget {
  const RatingDistribution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distribution = [
      {'stars': 5, 'percentage': 92},
      {'stars': 4, 'percentage': 80},
      {'stars': 3, 'percentage': 50},
      {'stars': 2, 'percentage': 20},
      {'stars': 1, 'percentage': 8},
    ];

    return Column(
      children: distribution.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '${item['stars']}',
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
                    value: (item['percentage'] as int) / 100,
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
                '${item['percentage']}%',
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
}