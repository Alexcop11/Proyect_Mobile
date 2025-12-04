import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/custom_rate.dart';
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
    // Cargar datos del restaurante al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );

      if (authProvider.email != null) {
        restaurantProvider.loadOwnerRestaurant(authProvider.email!);
      }
    });
  }

  /// 🔥 Función para calcular ratios de estrellas
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
      // Calcular el promedio de las tres puntuaciones
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RestaurantProvider>(
      builder: (context, authProvider, restaurantProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return Navigationscaffold(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RestaurantScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RestaurantReviews(),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Restaurant_manage_Screen(),
                  ),
                );
                break;
            }
          },
          appBar: AppBar(
            title: const Text("FoodFinder"),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          child: restaurantProvider.isLoading
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
                            authProvider.email!,
                          );
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de resumen de calificación
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: CustomReviews(
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
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Tarjeta de comentarios
                            if (restaurantProvider.reviews.isEmpty)
                              const Card(
                                elevation: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      "Aún no hay reseñas para tu restaurante",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Comentarios",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.builder(
                                        itemCount: restaurantProvider.reviews.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final review = restaurantProvider.reviews[index];
                                          final usuario = review.usuario?.nombre ?? "Anónimo";
                                          final comentario = review.comentario ?? "Sin comentario";
                                          final promedioCalificacion = (
                                            (review.puntuacionComida ?? 0) +
                                            (review.puntuacionServicio ?? 0) +
                                            (review.puntuacionAmbiente ?? 0)
                                          ) / 3;

                                          return Card(
                                            elevation: 2,
                                            margin: const EdgeInsets.only(bottom: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        usuario,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            promedioCalificacion.toStringAsFixed(1),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    comentario,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildRatingChip("Comida", review.puntuacionComida ?? 0),
                                                      const SizedBox(width: 8),
                                                      _buildRatingChip("Servicio", review.puntuacionServicio ?? 0),
                                                      const SizedBox(width: 8),
                                                      _buildRatingChip("Ambiente", review.puntuacionAmbiente ?? 0),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildRatingChip(String label, int rating) {
    return Chip(
      label: Text(
        "$label: $rating",
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}