import 'package:flutter/material.dart';
import 'rating_summary.dart';
import 'detailed_ratings.dart';
import 'rating_distribution.dart';
import 'review_item.dart';
import 'review_dialog.dart';

class ReviewsTab extends StatelessWidget {
  final double calificacion;
  final int reviews;

  const ReviewsTab({
    Key? key,
    required this.calificacion,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Visitaste este lugar?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comparte tu opinión con otros comensales',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showReviewDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Escribe tu reseña',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Calificaciones y opiniones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          RatingSummary(calificacion: calificacion, reviews: reviews),
          const SizedBox(height: 24),
          const Text(
            'Calificación Detallada',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const DetailedRatings(),
          const SizedBox(height: 32),
          const Text(
            'Distribución de Calificaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const RatingDistribution(),
          const SizedBox(height: 24),
          _buildReviewsList(),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ReviewDialog(),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: const [
        ReviewItem(
          name: 'María García',
          date: 'Hace 3 días',
          comment: 'Excelente lugar, comida...',
          rating: 4.5,
        ),
        ReviewItem(
          name: 'Juan López',
          date: 'Hace 5 días',
          comment: 'Muy buena atención...',
          rating: 5.0,
        ),
      ],
    );
  }
}