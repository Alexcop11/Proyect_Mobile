import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerComponent extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String? errorText;

  const ImagePickerComponent({
    super.key,
    required this.onImageSelected,
    this.errorText,
  });

  @override
  State<ImagePickerComponent> createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        widget.onImageSelected(_selectedImage);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("📸 Imagen seleccionada")),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error al seleccionar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al seleccionar la imagen"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Seleccionar imagen",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                  title: const Text("Cámara"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.redAccent),
                  title: const Text("Galería"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Eliminar imagen"),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                      widget.onImageSelected(null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón principal
        InkWell(
          onTap: _showImageSourceDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: _selectedImage != null ? 200 : 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null ? Colors.red : Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      // Imagen seleccionada
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Botón para cambiar/eliminar
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: widget.errorText != null
                            ? Colors.red
                            : Colors.redAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Agregar foto del restaurante",
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.errorText != null
                              ? Colors.red
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Toca para seleccionar",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        // Mensaje de error
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}