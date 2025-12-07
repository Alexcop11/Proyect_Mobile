import 'package:flutter/material.dart';

class Restaurant {
  final int? idRestaurante;
  final int idUsuarioPropietario;
  final String nombre;
  final String descripcion;
  final String direccion;
  final double latitud;
  final double longitud;
  final String telefono;
  final String horarioApertura;
  final String horarioCierre;
  final double precioPromedio;
  final String categoria;
  final String menuUrl;
  final String fechaRegistro;
  final bool activo;
  final double? calificacionPromedio;
  final int? numeroReviews;

  Restaurant({
    this.idRestaurante,
    required this.idUsuarioPropietario,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.telefono,
    required this.horarioApertura,
    required this.horarioCierre,
    required this.precioPromedio,
    required this.categoria,
    required this.menuUrl,
    required this.fechaRegistro,
    required this.activo,
    this.calificacionPromedio,
    this.numeroReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    try {
      // Helper para convertir de manera segura a int
      int? _safeInt(dynamic value, String fieldName) {
        if (value == null) {
          debugPrint("⚠️ Campo '$fieldName' es null");
          return null;
        }
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed == null) {
            debugPrint("⚠️ No se pudo parsear '$fieldName': '$value' a int");
          }
          return parsed;
        }
        if (value is double) return value.toInt();
        debugPrint("⚠️ Tipo inesperado para '$fieldName': ${value.runtimeType}");
        return null;
      }

      // Helper para convertir de manera segura a double
      double _safeDouble(dynamic value, String fieldName, {double defaultValue = 0.0}) {
        if (value == null) {
          debugPrint("⚠️ Campo '$fieldName' es null, usando $defaultValue");
          return defaultValue;
        }
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed == null) {
            debugPrint("⚠️ No se pudo parsear '$fieldName': '$value' a double");
          }
          return parsed ?? defaultValue;
        }
        debugPrint("⚠️ Tipo inesperado para '$fieldName': ${value.runtimeType}");
        return defaultValue;
      }

      final restaurant = Restaurant(
        idRestaurante: _safeInt(json['idRestaurante'], 'idRestaurante'),
        idUsuarioPropietario: _safeInt(json['idUsuarioPropietario'], 'idUsuarioPropietario') ?? 0,
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? '',
        direccion: json['direccion']?.toString() ?? '',
        latitud: _safeDouble(json['latitud'], 'latitud'),
        longitud: _safeDouble(json['longitud'], 'longitud'),
        telefono: json['telefono']?.toString() ?? '',
        horarioApertura: json['horarioApertura']?.toString() ?? '',
        horarioCierre: json['horarioCierre']?.toString() ?? '',
        precioPromedio: _safeDouble(json['precioPromedio'], 'precioPromedio'),
        categoria: json['categoria']?.toString() ?? '',
        menuUrl: json['menuURL']?.toString() ?? json['menuUrl']?.toString() ?? '',
        fechaRegistro: json['fechaRegistro']?.toString() ?? '',
        activo: json['activo'] == true || json['activo'] == 1 || json['activo']?.toString().toLowerCase() == 'true',
        calificacionPromedio: json['calificacionPromedio'] != null 
            ? _safeDouble(json['calificacionPromedio'], 'calificacionPromedio') 
            : null,
        numeroReviews: _safeInt(json['numeroReviews'], 'numeroReviews'),
      );

      return restaurant;
    } catch (e, stackTrace) {
      debugPrint("❌ Error completo en Restaurant.fromJson: $e");
      debugPrint("📄 JSON que causó el error: $json");
      debugPrint("📚 StackTrace: $stackTrace");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (idRestaurante != null) 'idRestaurante': idRestaurante,
      'idUsuarioPropietario': idUsuarioPropietario,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'telefono': telefono,
      'horarioApertura': horarioApertura,
      'horarioCierre': horarioCierre,
      'precioPromedio': precioPromedio,
      'categoria': categoria,
      'menuURL': menuUrl,
      'fechaRegistro': fechaRegistro,
      'activo': activo,
    };
  }

  Restaurant copyWith({
    int? idRestaurante,
    int? idUsuarioPropietario,
    String? nombre,
    String? descripcion,
    String? direccion,
    double? latitud,
    double? longitud,
    String? telefono,
    String? horarioApertura,
    String? horarioCierre,
    double? precioPromedio,
    String? categoria,
    String? menuUrl,
    String? fechaRegistro,
    bool? activo,
    double? calificacionPromedio,
    int? numeroReviews,
  }) {
    return Restaurant(
      idRestaurante: idRestaurante ?? this.idRestaurante,
      idUsuarioPropietario: idUsuarioPropietario ?? this.idUsuarioPropietario,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      telefono: telefono ?? this.telefono,
      horarioApertura: horarioApertura ?? this.horarioApertura,
      horarioCierre: horarioCierre ?? this.horarioCierre,
      precioPromedio: precioPromedio ?? this.precioPromedio,
      categoria: categoria ?? this.categoria,
      menuUrl: menuUrl ?? this.menuUrl,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      numeroReviews: numeroReviews ?? this.numeroReviews,
    );
  }

  // Método para verificar si está abierto ahora
  bool get isOpenNow {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
      
      final opening = _parseTime(horarioApertura);
      final closing = _parseTime(horarioCierre);
      
      if (opening == null || closing == null) return false;
      
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final openingMinutes = opening.hour * 60 + opening.minute;
      final closingMinutes = closing.hour * 60 + closing.minute;
      
      if (closingMinutes < openingMinutes) {
        // Cruza medianoche
        return currentMinutes >= openingMinutes || currentMinutes <= closingMinutes;
      } else {
        return currentMinutes >= openingMinutes && currentMinutes <= closingMinutes;
      }
    } catch (e) {
      return false;
    }
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  // Distancia y tiempo estimado (se calcularían con coordenadas del usuario)
  String getDistanceFrom(double userLat, double userLng) {
    // Implementar cálculo de distancia usando fórmula de Haversine
    // Por ahora retorna placeholder
    return '1.2 km';
  }

  String getEstimatedTime() {
    // Basado en distancia, se calcularía el tiempo estimado
    return '25-30 min';
  }

  void operator [](String other) {}
}