import 'package:flutter/material.dart';

class Photo {
  final int? idFoto;
  final String urlFoto; // Se mapea desde 'url' del servidor
  final String? descripcion;
  final bool esPortada;
  final String fechaSubida;
  final int idRestaurante;

  Photo({
    this.idFoto,
    required this.urlFoto,
    this.descripcion,
    required this.esPortada,
    required this.fechaSubida,
    required this.idRestaurante,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    // El servidor usa 'url' en lugar de 'urlFoto'
    final url = json['url'] ?? json['urlFoto'] ?? '';
    
    debugPrint('📸 Parseando foto: idFoto=${json['idFoto']}, url=$url');
    
    return Photo(
      idFoto: json['idFoto'],
      urlFoto: url,
      descripcion: json['descripcion'],
      esPortada: json['esPortada'] ?? false,
      fechaSubida: json['fechaSubida'] ?? DateTime.now().toIso8601String(),
      idRestaurante: json['idRestaurante'] ?? 
                     json['restaurante']?['idRestaurante'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFoto': idFoto,
      'url': urlFoto, // Usar 'url' para compatibilidad con el servidor
      'urlFoto': urlFoto, // Mantener ambos por compatibilidad
      'descripcion': descripcion,
      'esPortada': esPortada,
      'fechaSubida': fechaSubida,
      'idRestaurante': idRestaurante,
    };
  }

  /// Crear copia con modificaciones
  Photo copyWith({
    int? idFoto,
    String? urlFoto,
    String? descripcion,
    bool? esPortada,
    String? fechaSubida,
    int? idRestaurante,
  }) {
    return Photo(
      idFoto: idFoto ?? this.idFoto,
      urlFoto: urlFoto ?? this.urlFoto,
      descripcion: descripcion ?? this.descripcion,
      esPortada: esPortada ?? this.esPortada,
      fechaSubida: fechaSubida ?? this.fechaSubida,
      idRestaurante: idRestaurante ?? this.idRestaurante,
    );
  }

  @override
  String toString() {
    return 'Photo(idFoto: $idFoto, url: $urlFoto, esPortada: $esPortada, idRestaurante: $idRestaurante)';
  }
}

class PhotoUploadResponse {
  final bool success;
  final String message;
  final Photo? photo;

  PhotoUploadResponse({
    required this.success,
    required this.message,
    this.photo,
  });

  factory PhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    return PhotoUploadResponse(
      success: json['type'] == 'SUCCESS' || json['typeResponse'] == 'SUCCESS',
      message: json['message'] ?? json['text'] ?? '',
      photo: json['result'] != null ? Photo.fromJson(json['result']) : null,
    );
  }
}