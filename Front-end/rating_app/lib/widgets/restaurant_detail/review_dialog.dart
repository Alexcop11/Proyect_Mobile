import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';

class ReviewDialog extends StatefulWidget {
  final int idRestaurante;
  final VoidCallback onReviewSubmitted;

  const ReviewDialog({
    Key? key,
    required this.idRestaurante,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int foodRating = 0;
  int serviceRating = 0;
  int ambianceRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '¿Qué te pareció?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  CloseButton(),
                ],
              ),
              const SizedBox(height: 24),

              _buildRatingSection('Comida', foodRating, (rating) {
                setState(() => foodRating = rating);
              }),
              const SizedBox(height: 16),

              _buildRatingSection('Servicio', serviceRating, (rating) {
                setState(() => serviceRating = rating);
              }),
              const SizedBox(height: 16),

              _buildRatingSection('Ambiente', ambianceRating, (rating) {
                setState(() => ambianceRating = rating);
              }),
              const SizedBox(height: 24),

              const Text(
                'Cuéntanos tu experiencia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ej: La comida estaba deliciosa y el servicio fue excelente...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Publicar Reseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(
      String label, int currentRating, Function(int) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) => IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: index < currentRating
                    ? const Color(0xFFFFC107)
                    : Colors.grey[400],
              ),
              onPressed: () => onRatingChanged(index + 1),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (foodRating == 0 || serviceRating == 0 || ambianceRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor califica todos los aspectos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final restaurantProvider = context.read<RestaurantProvider>();

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Debes iniciar sesión para dejar una reseña');
      }

      final idUsuario = currentUser.idUsuario!;

      final success = await restaurantProvider.createReview(
        idUsuario: idUsuario,
        idRestaurante: widget.idRestaurante,
        puntuacionComida: foodRating,
        puntuacionServicio: serviceRating,
        puntuacionAmbiente: ambianceRating,
        comentario: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        
        // ✅ Cerrar el diálogo
        Navigator.of(context).pop();
        
        // ✅ Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reseña publicada exitosamente!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // ✅ Llamar al callback (ya no necesita delay porque el Provider ahora notifica)
        widget.onReviewSubmitted();
      } else {
        throw Exception('No se pudo publicar la reseña');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() => _isSubmitting = false);
    }
  }
}