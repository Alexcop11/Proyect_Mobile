import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'rating_summary.dart';
import 'detailed_ratings.dart';
import 'rating_distribution.dart';
import 'review_item.dart';
import 'review_dialog.dart';

class ReviewsTab extends StatefulWidget {
  final int idRestaurante;

  const ReviewsTab({
    Key? key,
    required this.idRestaurante,
  }) : super(key: key);

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final provider = context.read<RestaurantProvider>();
    await provider.loadRestaurantStats(widget.idRestaurante);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF6B6B),
            ),
          );
        }

        final reviews = provider.reviews;
        final averageRating = provider.averageRating;
        final totalReviews = provider.totalReviews;

        return RefreshIndicator(
          onRefresh: _loadReviews,
          color: const Color(0xFFFF6B6B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                RatingSummary(
                  calificacion: averageRating,
                  reviews: totalReviews,
                ),
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
                DetailedRatings(reviews: reviews),
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
                RatingDistribution(reviews: reviews),
                const SizedBox(height: 24),
                _buildReviewsList(reviews),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewDialog(
        idRestaurante: widget.idRestaurante,
        onReviewSubmitted: _loadReviews,
      ),
    );
  }

  Widget _buildReviewsList(List reviews) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no hay reseñas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Sé el primero en dejar una reseña!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        // Calcular rating promedio de la reseña
        final avgRating = ((review.puntuacionComida ?? 0) +
                (review.puntuacionServicio ?? 0) +
                (review.puntuacionAmbiente ?? 0)) /
            3;

        return ReviewItem(
          name: review.usuario?.nombre ?? 'Usuario Anónimo',
          date: _formatDate(review.fechaCalificacion),
          comment: review.comentario ?? 'Sin comentarios',
          rating: avgRating,
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic dateField) {
    if (dateField == null) return 'Fecha desconocida';
    
    try {
      DateTime date;
      
      // Si es DateTime, usarlo directamente
      if (dateField is DateTime) {
        date = dateField;
      } 
      // Si es String, parsearlo
      else if (dateField is String) {
        date = DateTime.parse(dateField);
      } 
      else {
        return 'Fecha desconocida';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Hace ${weeks} ${weeks == 1 ? 'semana' : 'semanas'}';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'Hace ${months} ${months == 1 ? 'mes' : 'meses'}';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'Hace ${years} ${years == 1 ? 'año' : 'años'}';
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
  }
}