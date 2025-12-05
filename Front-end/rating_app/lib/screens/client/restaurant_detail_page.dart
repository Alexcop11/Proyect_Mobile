import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';

// Importar los componentes
import 'package:rating_app/widgets/restaurant_detail/restaurant_header.dart';
import 'package:rating_app/widgets/restaurant_detail/restaurant_info_card.dart';
import 'package:rating_app/widgets/restaurant_detail/information_tab.dart';
import 'package:rating_app/widgets/restaurant_detail/menu_tab.dart';
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
    this.status = 'Abierto • Cierra a las 23:00',
    this.description = '',
    this.phone = '',
    this.horario = '',
    this.precioPromedio = 0.0,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteTap() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar favoritos'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final isFavorite = favoriteProvider.isFavorite(widget.restaurantId);

    final success = await favoriteProvider.toggleFavorite(
      userId: authProvider.currentUser!.idUsuario!,
      restaurantId: widget.restaurantId,
    );

    if (success && mounted) {
      final message = !isFavorite
          ? 'Restaurante agregado a favoritos'
          : 'Restaurante eliminado de favoritos';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(widget.restaurantId);

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
                ),
                RestaurantInfoCard(
                  nombre: widget.nombre,
                  tipo: widget.tipo,
                  ubicacion: widget.ubicacion,
                  calificacion: widget.calificacion,
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
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Información'),
                        Tab(text: 'Menú'),
                        Tab(text: 'Reseñas'),
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
                const MenuTab(),
                // ✅ CORRECCIÓN: Pasar idRestaurante al ReviewsTab
                ReviewsTab(
                  idRestaurante: widget.restaurantId,
                ),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}