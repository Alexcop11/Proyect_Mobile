import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';

// COMPONENTES
import 'package:rating_app/widgets/restaurant_detail/restaurant_header.dart';
import 'package:rating_app/widgets/restaurant_detail/restaurant_info_card.dart';
import 'package:rating_app/widgets/restaurant_detail/information_tab.dart';
import 'package:rating_app/widgets/restaurant_detail/reviews_tab.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  final String nombre;
  final String tipo;
  final double calificacion;
  final int reviews;
  final String ubicacion;
  final String foto;
  final bool isOpen;
  final String status;
  final String description;
  final String phone;
  final String horario;
  final double precioPromedio;

  const RestaurantDetailPage({
    Key? key,
    required this.restaurantId,
    required this.nombre,
    required this.tipo,
    required this.calificacion,
    required this.reviews,
    required this.ubicacion,
    required this.foto,
    this.isOpen = false,
    this.status = '',
    this.description = '',
    this.phone = '',
    this.horario = '',
    this.precioPromedio = 0,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loadingRating = true;
  double _avgRating = 0.0;
  int _totalReviews = 0;

  Map<String, dynamic>? _ratingDetails;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar rating una vez renderizada la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRatingData();
    });
  }

  Future<void> _loadRatingData() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);

    try {
      final data =
          await provider.calculateRestaurantRating(widget.restaurantId);

      if (!mounted) return;

      setState(() {
        _avgRating = data['averageRating'] ?? 0.0;
        _totalReviews = data['totalReviews'] ?? 0;
        _ratingDetails = data;
        _loadingRating = false;
      });
    } catch (e) {
      debugPrint("Error cargando rating: $e");
      setState(() => _loadingRating = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteTap() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final favorites = Provider.of<FavoriteProvider>(context, listen: false);

    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await favorites.toggleFavorite(
      userId: auth.currentUser!.idUsuario!,
      restaurantId: widget.restaurantId,
    );

    if (success && mounted) {
      final isFav = favorites.isFavorite(widget.restaurantId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFav
              ? 'Agregado a favoritos'
              : 'Eliminado de favoritos'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final isFavorite = favProvider.isFavorite(widget.restaurantId);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                RestaurantHeader(
                  foto: widget.foto,
                  isOpen: widget.isOpen,
                  status: widget.status,
                  isFavorite: isFavorite,
                  onFavoriteTap: _handleFavoriteTap,
                  onBack: () => Navigator.pop(context),

                  /// ⭐ Aquí se envía el rating real calculado
                  calificacion:
                      _loadingRating ? widget.calificacion : _avgRating,
                  reviews: _loadingRating ? widget.reviews : _totalReviews,
                ),

                RestaurantInfoCard(
                  nombre: widget.nombre,
                  tipo: widget.tipo,
                  ubicacion: widget.ubicacion,
                  calificacion:
                      _loadingRating ? widget.calificacion : _avgRating,
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFFF6B6B),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFFFF6B6B),
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: "Información"),
                        Tab(text: "Reseñas"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                InformationTab(
                  description: widget.description,
                  horario: widget.horario,
                  phone: widget.phone,
                ),
                ReviewsTab(idRestaurante: widget.restaurantId),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_) => false;
}