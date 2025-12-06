import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/photo_provider.dart';

class RestaurantPhotoSection extends StatefulWidget {
  final int idRestaurante;
  final String? currentPhotoUrl;

  const RestaurantPhotoSection({
    Key? key,
    required this.idRestaurante,
    this.currentPhotoUrl,
  }) : super(key: key);

  @override
  State<RestaurantPhotoSection> createState() => _RestaurantPhotoSectionState();
}

class _RestaurantPhotoSectionState extends State<RestaurantPhotoSection> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photoProvider = context.read<PhotoProvider>();
    await photoProvider.loadPhotosByRestaurant(widget.idRestaurante);
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final photoProvider = context.read<PhotoProvider>();
      final success = await photoProvider.uploadPhoto(
        imageFile: File(image.path),
        idRestaurante: widget.idRestaurante,
        esPortada: true,
        descripcion: 'Foto de portada del restaurante',
      );

      if (mounted) {
        setState(() => _isUploading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto subida correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          await _loadPhotos();
        } else {
          _showError(photoProvider.errorMessage ?? 'Error al subir la foto');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showError('Error al seleccionar imagen: ${e.toString()}');
      }
    }
  }

  Future<void> _deletePhoto(int? idFoto) async {
    if (idFoto == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Foto'),
        content: const Text('¿Estás seguro de eliminar esta foto?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final photoProvider = context.read<PhotoProvider>();
      final success = await photoProvider.deletePhoto(idFoto);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto eliminada correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          await _loadPhotos();
        } else {
          _showError('No se pudo eliminar la foto');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al eliminar: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final portada = photoProvider.portada;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            color: Color(0xFF42A5F5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Foto del Restaurante',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenido de la foto
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    // Imagen
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildPhotoWidget(portada),
                          ),
                        ),
                        
                        // Botón de eliminar (solo si hay foto del servidor)
                        if (portada?.idFoto != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _deletePhoto(portada?.idFoto),
                              ),
                            ),
                          ),

                        // Indicador de carga
                        if (_isUploading || photoProvider.isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Botón de cambiar/subir foto
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploading || photoProvider.isLoading
                            ? null
                            : _pickAndUploadImage,
                        icon: Icon(
                          portada?.idFoto != null 
                              ? Icons.edit 
                              : Icons.add_photo_alternate,
                          size: 18,
                        ),
                        label: Text(
                          portada?.idFoto != null 
                              ? 'Cambiar Foto' 
                              : 'Agregar Foto',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF42A5F5),
                          side: const BorderSide(color: Color(0xFF42A5F5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Texto de ayuda
                    const SizedBox(height: 8),
                    Text(
                      'Tamaño recomendado: 1920x1080 px',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoWidget(dynamic portada) {
    // Si hay foto del servidor
    if (portada?.urlFoto != null && portada!.urlFoto.isNotEmpty) {
      return Image.network(
        portada.urlFoto,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF42A5F5),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error cargando imagen: $error');
          return _buildPlaceholder();
        },
      );
    }

    // Placeholder por defecto
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Sin foto',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}