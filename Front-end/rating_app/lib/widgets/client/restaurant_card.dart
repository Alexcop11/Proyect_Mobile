import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/models/restaurant.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/favorite_provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/photo_provider.dart';
import 'package:rating_app/screens/client/restaurant_detail_page.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isProcessing = false;
  bool _isLoadingRating = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialFavoriteStatus();
      _loadRating();
      _loadPhotoIfNeeded();
    });
  }

  /// Cargar foto solo si no está en caché
  Future<void> _loadPhotoIfNeeded() async {
    if (widget.restaurant.idRestaurante == null) return;

    final photoProvider = Provider.of<PhotoProvider>(
      context,
      listen: false,
    );

    // Verificar si ya está en caché o cargando
    final cachedUrl = photoProvider.getPortadaUrl(widget.restaurant.idRestaurante!);
    final isLoading = photoProvider.isLoadingRestaurant(widget.restaurant.idRestaurante!);

    if (cachedUrl == null && !isLoading) {
      // Solo cargar si no está en caché ni se está cargando
      await photoProvider.loadPhotosByRestaurant(
        widget.restaurant.idRestaurante!,
      );
    }
  }

  Future<void> _loadRating() async {
    if (widget.restaurant.idRestaurante == null) {
      return;
    }

    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    try {
      final ratingData = await restaurantProvider.calculateRestaurantRating(
        widget.restaurant.idRestaurante!,
      );

      if (mounted) {
        setState(() {
          _averageRating = ratingData['averageRating'] ?? 0.0;
          _totalReviews = ratingData['totalReviews'] ?? 0;
          _isLoadingRating = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando rating: $e');
      if (mounted) {
        setState(() {
          _isLoadingRating = false;
        });
      }
    }
  }

  Future<void> _checkInitialFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (authProvider.currentUser != null && widget.restaurant.idRestaurante != null) {
      final isInCache = favoriteProvider.isFavorite(widget.restaurant.idRestaurante!);

      if (!isInCache) {
        await favoriteProvider.checkFavoriteStatus(
          userId: authProvider.currentUser!.idUsuario!,
          restaurantId: widget.restaurant.idRestaurante!,
        );
      }
    }
  }

  Future<void> _handleFavoriteTap(BuildContext context) async {
    if (_isProcessing) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

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

    final restaurantId = widget.restaurant.idRestaurante;
    if (restaurantId == null) return;

    setState(() {
      _isProcessing = true;
    });

    final isFavorite = favoriteProvider.isFavorite(restaurantId);

    final success = await favoriteProvider.toggleFavorite(
      userId: authProvider.currentUser!.idUsuario!,
      restaurantId: restaurantId,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success && context.mounted) {
      final message =
          !isFavorite ? 'Restaurante agregado a favoritos' : 'Restaurante eliminado de favoritos';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favoriteProvider.errorMessage ?? 'Error al actualizar favorito',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToDetail(BuildContext context, String? photoUrl) {
    String horarioCompleto = '';
    if (widget.restaurant.horarioApertura.isNotEmpty &&
        widget.restaurant.horarioCierre.isNotEmpty) {
      horarioCompleto =
          '${widget.restaurant.horarioApertura} - ${widget.restaurant.horarioCierre}';
    }

    String status = 'Cerrado';
    if (widget.restaurant.isOpenNow) {
      status = 'Abierto • Cierra a las ${widget.restaurant.horarioCierre}';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailPage(
          restaurantId: widget.restaurant.idRestaurante!,
          nombre: widget.restaurant.nombre,
          tipo: widget.restaurant.categoria,
          calificacion: _averageRating,
          reviews: _totalReviews,
          ubicacion: widget.restaurant.direccion,
          foto: photoUrl ?? 'assets/images/restaurant_placeholder.jpg',
          isOpen: widget.restaurant.isOpenNow,
          status: status,
          description: widget.restaurant.descripcion,
          phone: widget.restaurant.telefono,
          horario: horarioCompleto,
          precioPromedio: widget.restaurant.precioPromedio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoriteProvider, PhotoProvider>(
      builder: (context, favoriteProvider, photoProvider, child) {
        final restaurantId = widget.restaurant.idRestaurante;
        final isFavorite = restaurantId != null 
            ? favoriteProvider.isFavorite(restaurantId) 
            : false;

        // Obtener URL de foto desde caché
        final photoUrl = restaurantId != null 
            ? photoProvider.getPortadaUrl(restaurantId)
            : null;

        final isLoadingPhoto = restaurantId != null
            ? photoProvider.isLoadingRestaurant(restaurantId)
            : false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context, isFavorite, photoUrl, isLoadingPhoto),
              _buildInfoSection(context, photoUrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSection(
    BuildContext context, 
    bool isFavorite, 
    String? photoUrl,
    bool isLoadingPhoto,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Container(
            height: 200,
            width: double.infinity,
            color: const Color(0xFFE8E8E8),
            child: _buildRestaurantImage(photoUrl, isLoadingPhoto),
          ),
        ),
        if (widget.restaurant.isOpenNow)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 8,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Abierto ahora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _isProcessing ? null : () => _handleFavoriteTap(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: _isProcessing
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFFF6B6B),
                        ),
                      ),
                    )
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFFF6B6B),
                      size: 24,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantImage(String? photoUrl, bool isLoadingPhoto) {
    // Si está cargando, mostrar skeleton loader
    if (isLoadingPhoto) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey[400]!,
              ),
            ),
          ),
        ),
      );
    }

    // Si hay URL de Cloudinary, mostrar imagen de red
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Validar que sea una URL válida
      final uri = Uri.tryParse(photoUrl);
      if (uri != null && uri.hasScheme) {
        return Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null;
            
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Error cargando imagen de red: $error');
            return _buildPlaceholderImage();
          },
        );
      }
    }

    // Fallback: intentar cargar desde assets (menuUrl) - solo si existe
    if (widget.restaurant.menuUrl.isNotEmpty && 
        !widget.restaurant.menuUrl.startsWith('http')) {
      return Image.asset(
        widget.restaurant.menuUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }

    // Si no hay ninguna imagen, mostrar placeholder
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/restaurante.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.grey[500],
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin imagen',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.restaurant.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.restaurant.categoria,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRating(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${widget.restaurant.precioPromedio.toStringAsFixed(0)} MXN promedio',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildLocationRow(),
          const SizedBox(height: 16),
          _buildVerRestauranteButton(context, photoUrl),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star,
          color: Color(0xFFFFC107),
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          _averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($_totalReviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          size: 18,
          color: Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.restaurant.direccion,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVerRestauranteButton(BuildContext context, String? photoUrl) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _navigateToDetail(context, photoUrl),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Ver Restaurante',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}