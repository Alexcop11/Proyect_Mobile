import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/widgets/common/app_bar_custom.dart';
import 'package:rating_app/widgets/cutoms_reviews.dart';

class RestaurantReviews extends StatefulWidget {
  const RestaurantReviews({super.key});

  @override
  State<RestaurantReviews> createState() => _RestaurantReviewsState();
}

class _RestaurantReviewsState extends State<RestaurantReviews> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );

      if (authProvider.email != null) {
        restaurantProvider.loadOwnerRestaurant(authProvider.email!,authProvider);
      }
    });
  }

  /// Función para calcular ratios de estrellas
  Map<String, double> calculateStarRatios(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      return {
        "five": 0.0,
        "four": 0.0,
        "three": 0.0,
        "two": 0.0,
        "one": 0.0,
      };
    }

    int total = reviews.length;
    int fiveStars = 0;
    int fourStars = 0;
    int threeStars = 0;
    int twoStars = 0;
    int oneStar = 0;

    for (var r in reviews) {
      final comida = (r["puntuacionComida"] ?? 0).toDouble();
      final servicio = (r["puntuacionServicio"] ?? 0).toDouble();
      final ambiente = (r["puntuacionAmbiente"] ?? 0).toDouble();
      final rating = (comida + servicio + ambiente) / 3;

      if (rating >= 4.5) {
        fiveStars++;
      } else if (rating >= 3.5) {
        fourStars++;
      } else if (rating >= 2.5) {
        threeStars++;
      } else if (rating >= 1.5) {
        twoStars++;
      } else {
        oneStar++;
      }
    }

    return {
      "five": fiveStars / total,
      "four": fourStars / total,
      "three": threeStars / total,
      "two": twoStars / total,
      "one": oneStar / total,
    };
  }

  /// Obtener iniciales del nombre
  String _getInitials(String nombre) {
    if (nombre.isEmpty) return 'A';
    
    List<String> partes = nombre.trim().split(' ');
    
    if (partes.length >= 2 && partes[0].isNotEmpty && partes[1].isNotEmpty) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    
    if (partes[0].length >= 2) {
      return partes[0].substring(0, 2).toUpperCase();
    } else if (partes[0].length == 1) {
      return partes[0][0].toUpperCase();
    }
    
    return 'A';
  }

  /// Calcular hace cuánto tiempo fue la reseña
  String _getTimeAgo(DateTime? fecha) {
    if (fecha == null) return 'Hace tiempo';
    
    final now = DateTime.now();
    final difference = now.difference(fecha);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return 'hace unos momentos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBarCustom(
            title: 'Reseñas'
          ),
          body: restaurantProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                )
              : restaurantProvider.ownerRestaurant == null
                  ? const Center(
                      child: Text(
                        "No tienes restaurante registrado",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (authProvider.email != null) {
                          await restaurantProvider.loadOwnerRestaurant(
                            authProvider.email!,authProvider
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de resumen de calificación
                            CustomReviews(
                              rating: restaurantProvider.averageRating,
                              totalReviews: restaurantProvider.totalReviews,
                              fiveStarRatio: restaurantProvider.reviews.isEmpty
                                  ? 0.0
                                  : calculateStarRatios(
                                      restaurantProvider.reviews
                                          .map((r) => {
                                                "puntuacionComida": r.puntuacionComida,
                                                "puntuacionServicio": r.puntuacionServicio,
                                                "puntuacionAmbiente": r.puntuacionAmbiente,
                                              })
                                          .toList(),
                                    )["five"]!,
                              fourStarRatio: restaurantProvider.reviews.isEmpty
                                  ? 0.0
                                  : calculateStarRatios(
                                      restaurantProvider.reviews
                                          .map((r) => {
                                                "puntuacionComida": r.puntuacionComida,
                                                "puntuacionServicio": r.puntuacionServicio,
                                                "puntuacionAmbiente": r.puntuacionAmbiente,
                                              })
                                          .toList(),
                                    )["four"]!,
                              threeStarRatio: restaurantProvider.reviews.isEmpty
                                  ? 0.0
                                  : calculateStarRatios(
                                      restaurantProvider.reviews
                                          .map((r) => {
                                                "puntuacionComida": r.puntuacionComida,
                                                "puntuacionServicio": r.puntuacionServicio,
                                                "puntuacionAmbiente": r.puntuacionAmbiente,
                                              })
                                          .toList(),
                                    )["three"]!,
                            ),
                            
                            const SizedBox(height: 24),

                            // Comentarios
                            if (restaurantProvider.reviews.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Aún no hay reseñas para tu restaurante",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: restaurantProvider.reviews.map((review) {
                                  final usuario = "${review.usuario?.nombre ?? ""} ${review.usuario?.apellido ?? ""}".trim();
                                  final comentario = review.comentario ?? "Sin comentario";
                                  final promedioCalificacion = (
                                    (review.puntuacionComida ?? 0) +
                                    (review.puntuacionServicio ?? 0) +
                                    (review.puntuacionAmbiente ?? 0)
                                  ) / 3;

                                  return _buildReviewCard(
                                    usuario: usuario,
                                    initiales: _getInitials(usuario),
                                    timeAgo: _getTimeAgo(review.fechaCalificacion),
                                    rating: promedioCalificacion,
                                    comentario: comentario,
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildReviewCard({
    required String usuario,
    required String initiales,
    required String timeAgo,
    required double rating,
    required String comentario,
  }) {
    // Número de estrellas llenas
    int fullStars = rating.floor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar, nombre y tiempo
          Row(
            children: [
              // Avatar circular con iniciales
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB3BA), // Rosa pastel
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initiales,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Nombre y tiempo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Estrellas de rating
          Row(
            children: List.generate(5, (index) {
              if (index < fullStars) {
                return const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 20,
                );
              } else {
                return const Icon(
                  Icons.star_border,
                  color: Color(0xFFE0E0E0),
                  size: 20,
                );
              }
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Comentario
          Text(
            comentario,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}