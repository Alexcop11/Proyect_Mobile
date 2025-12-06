import 'package:flutter/material.dart';

class RestaurantHeader extends StatelessWidget {
  final String foto;
  final bool isOpen;
  final String status;
  final bool isFavorite;
  final double calificacion;
  final int reviews;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBack;

  const RestaurantHeader({
    Key? key,
    required this.foto,
    required this.isOpen,
    required this.status,
    required this.isFavorite,
    required this.calificacion,
    required this.reviews,
    required this.onFavoriteTap,
    required this.onBack,
  }) : super(key: key);

  /// Determinar si la URL es de red o asset
  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Widget para construir la imagen (red o asset)
  Widget _buildImage() {
    // Validar que la URL no esté vacía
    if (foto.isEmpty) {
      return _buildPlaceholder();
    }

    // Si es una URL de red (Cloudinary)
    if (_isNetworkImage(foto)) {
      final uri = Uri.tryParse(foto);
      
      // Validar que sea una URL válida
      if (uri == null || !uri.hasScheme) {
        debugPrint('⚠️ URL inválida: $foto');
        return _buildPlaceholder();
      }

      return Image.network(
        foto,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          final progress = loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null;

          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B6B),
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error cargando imagen de red: $error');
          return _buildPlaceholder(showError: true);
        },
      );
    }

    // Si es un asset local
    return Image.asset(
      foto,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error cargando asset: $error');
        return _buildPlaceholder(showError: true);
      },
    );
  }

  /// Placeholder cuando no hay imagen o hay error
  Widget _buildPlaceholder({bool showError = false}) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showError ? Icons.broken_image : Icons.restaurant,
              color: showError ? Colors.red[300] : Colors.grey[500],
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              showError ? 'Error al cargar imagen' : 'Sin imagen',
              style: TextStyle(
                color: showError ? Colors.red[600] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: onBack,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFF6B6B),
                size: 24,
              ),
              tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
              onPressed: onFavoriteTap,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen principal
            _buildImage(),

            // Gradiente oscuro en la parte inferior para mejor legibilidad
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Badge de estado (abierto/cerrado)
            if (isOpen && status.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

           ],
        ),
      ),
    );
  }
}