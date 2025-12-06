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
  
  // Constantes de validación
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    
    try {
      final photoProvider = context.read<PhotoProvider>();
      await photoProvider.loadPhotosByRestaurant(widget.idRestaurante);
    } catch (e) {
      debugPrint('❌ Error cargando fotos: $e');
    }
  }

  /// Validar el archivo de imagen seleccionado
  Future<bool> _validateImageFile(File imageFile) async {
    try {
      // 1. Verificar que el archivo existe
      if (!await imageFile.exists()) {
        _showError('El archivo seleccionado no existe');
        return false;
      }

      // 2. Verificar el tamaño del archivo
      final fileSize = await imageFile.length();
      debugPrint('📏 Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      if (fileSize > maxFileSizeInBytes) {
        final sizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);
        _showError('La imagen es muy grande ($sizeMB MB). Máximo permitido: 5 MB');
        return false;
      }

      if (fileSize == 0) {
        _showError('El archivo está vacío');
        return false;
      }

      // 3. Verificar la extensión del archivo
      final fileName = imageFile.path.split('/').last.toLowerCase();
      final extension = fileName.split('.').last;
      
      if (!allowedExtensions.contains(extension)) {
        _showError('Formato no permitido. Use: ${allowedExtensions.join(", ")}');
        return false;
      }

      debugPrint('✅ Validación de imagen exitosa');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error validando archivo: $e');
      _showError('Error al validar el archivo');
      return false;
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) {
      debugPrint('⚠️ Ya hay una subida en progreso');
      return;
    }

    try {
      // Validar que tenemos un ID de restaurante válido
      if (widget.idRestaurante <= 0) {
        _showError('ID de restaurante inválido');
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('ℹ️ Usuario canceló la selección de imagen');
        return;
      }

      final imageFile = File(image.path);
      
      // Validar el archivo antes de subirlo
      final isValid = await _validateImageFile(imageFile);
      if (!isValid) {
        return;
      }

      if (!mounted) return;
      setState(() => _isUploading = true);

      final photoProvider = context.read<PhotoProvider>();
      
      // Validar que el provider está disponible
      if (photoProvider == null) {
        throw Exception('Provider no disponible');
      }

      final success = await photoProvider.uploadPhoto(
        imageFile: imageFile,
        idRestaurante: widget.idRestaurante,
        esPortada: true,
        descripcion: 'Foto de portada del restaurante',
      );

      if (!mounted) return;
      
      setState(() => _isUploading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Foto subida correctamente')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await _loadPhotos();
      } else {
        final errorMsg = photoProvider.errorMessage ?? 'Error desconocido al subir la foto';
        _showError(errorMsg);
      }
      
    } catch (e) {
      debugPrint('❌ Error en _pickAndUploadImage: $e');
      
      if (mounted) {
        setState(() => _isUploading = false);
        
        String errorMessage = 'Error al seleccionar imagen';
        
        if (e.toString().contains('Permission')) {
          errorMessage = 'Se necesitan permisos para acceder a la galería';
        } else if (e.toString().contains('Network')) {
          errorMessage = 'Error de conexión. Verifica tu internet';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'La operación tardó demasiado. Intenta de nuevo';
        }
        
        _showError(errorMessage);
      }
    }
  }

  Future<void> _deletePhoto(int? idFoto) async {
    // Validar ID de foto
    if (idFoto == null || idFoto <= 0) {
      _showError('ID de foto inválido');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text('Eliminar Foto'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar esta foto?'),
            SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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

    if (confirmed != true || !mounted) return;

    try {
      final photoProvider = context.read<PhotoProvider>();
      
      // Validar provider
      if (photoProvider == null) {
        throw Exception('Provider no disponible');
      }

      final success = await photoProvider.deletePhoto(idFoto);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Foto eliminada correctamente')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await _loadPhotos();
      } else {
        _showError(photoProvider.errorMessage ?? 'No se pudo eliminar la foto');
      }
    } catch (e) {
      debugPrint('❌ Error eliminando foto: $e');
      
      if (mounted) {
        String errorMessage = 'Error al eliminar la foto';
        
        if (e.toString().contains('Network')) {
          errorMessage = 'Error de conexión. Verifica tu internet';
        } else if (e.toString().contains('401') || e.toString().contains('403')) {
          errorMessage = 'No tienes permisos para eliminar esta foto';
        }
        
        _showError(errorMessage);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final portada = photoProvider.portada;
        
        // Obtener URL de forma segura
        String? photoUrl;
        if (portada != null) {
          try {
            photoUrl = portada.urlFoto;
            if (photoUrl.isEmpty && portada.toJson().containsKey('url')) {
              photoUrl = portada.toJson()['url'];
            }
          } catch (e) {
            debugPrint('⚠️ Error obteniendo URL: $e');
            photoUrl = null;
          }
        }

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
                            child: _buildPhotoWidget(photoUrl),
                          ),
                        ),
                        
                        // Botón de eliminar (solo si hay foto válida del servidor)
                        if (portada?.idFoto != null && portada!.idFoto! > 0)
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
                                tooltip: 'Eliminar foto',
                                onPressed: _isUploading || photoProvider.isLoading
                                    ? null
                                    : () => _deletePhoto(portada.idFoto),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Subiendo foto...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                          portada?.idFoto != null && portada!.idFoto! > 0
                              ? Icons.edit 
                              : Icons.add_photo_alternate,
                          size: 18,
                        ),
                        label: Text(
                          portada?.idFoto != null && portada!.idFoto! > 0
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
                          disabledForegroundColor: Colors.grey,
                        ),
                      ),
                    ),

                    // Texto de ayuda con validaciones
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.info_outline,
                          'Tamaño recomendado: 1920x1080 px',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.file_present,
                          'Tamaño máximo: 5 MB',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.image,
                          'Formatos: ${allowedExtensions.join(", ").toUpperCase()}',
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoWidget(String? photoUrl) {
    // Validar URL
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Validar que sea una URL válida
      final uri = Uri.tryParse(photoUrl);
      if (uri == null || !uri.hasScheme) {
        debugPrint('⚠️ URL inválida: $photoUrl');
        return _buildPlaceholder(error: true);
      }
      
      debugPrint('🖼️ Cargando foto desde: $photoUrl');
      
      return Image.network(
        photoUrl,
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
                    color: const Color(0xFF42A5F5),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error cargando imagen desde $photoUrl: $error');
          return _buildPlaceholder(error: true);
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool error = false}) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            error ? Icons.broken_image : Icons.restaurant,
            size: 64,
            color: error ? Colors.red[300] : Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            error ? 'Error al cargar imagen' : 'Sin foto',
            style: TextStyle(
              color: error ? Colors.red[600] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}