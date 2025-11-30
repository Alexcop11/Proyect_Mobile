import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/login_screen.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';
import 'package:rating_app/screens/auth_wrapper.dart';
import 'package:rating_app/widgets/custom_rate.dart';
import 'package:rating_app/widgets/cutoms_reviews.dart';

class RestaurantReviews extends StatelessWidget {
  const RestaurantReviews({super.key});

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
      final rating = r["puntuacionComida"] ?? 0; // puedes usar promedio si lo tienes
      if (rating >= 5) {
        fiveStars++;
      } else if (rating == 4) {
        fourStars++;
      } else if (rating == 3) {
        threeStars++;
      } else if (rating == 2) {
        twoStars++;
      } else if (rating == 1) {
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => AuthWrapper()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: authProvider.checkRestaurantStatus(authProvider.email!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text("No tienes restaurante registrado"));
              }

              final summary = data["reviewsSummary"] as Map<String, dynamic>? ?? {};
              final averageRating = (summary["average"] ?? 0.0).toDouble();
              final totalReviews = summary["count"] ?? 0;

              final reviews = data["reviews"] as List<dynamic>? ?? [];
              final ratios = calculateStarRatios(reviews);

              return SingleChildScrollView(
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
                          rating: averageRating,
                          totalReviews: totalReviews,
                          fiveStarRatio: ratios["five"]!,
                          fourStarRatio: ratios["four"]!,
                          threeStarRatio: ratios["three"]!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta de comentarios con scroll interno
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: reviews.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            final usuario = review["usuario"]["nombre"];
                            final comentario = review["comentario"];
                            final puntuacion = review["puntuacionComida"];

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  "$usuario: $comentario ⭐ $puntuacion",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}