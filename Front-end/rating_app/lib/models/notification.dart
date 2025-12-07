import 'package:rating_app/models/user.dart';
import 'package:rating_app/models/restaurant.dart';

class Notification {
  final int? idNotificacion;
  final User usuario;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final Restaurant? restaurante;
  final bool leida;
  final DateTime fechaCreacion;
  final DateTime? fechaEnvio;

  Notification({
    this.idNotificacion,
    required this.usuario,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.restaurante,
    this.leida = false,
    required this.fechaCreacion,
    this.fechaEnvio,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      idNotificacion: json['idNotificacion'],
      usuario: User.fromJson(json['usuario']),
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: TipoNotificacion.fromString(json['tipo'] ?? 'SISTEMA'),
      restaurante: json['restaurante'] != null
          ? Restaurant.fromJson(json['restaurante'])
          : null,
      leida: json['leida'] ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaEnvio: json['fechaEnvio'] != null
          ? DateTime.parse(json['fechaEnvio'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idNotificacion': idNotificacion,
      'usuario': usuario.toJson(),
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo.value,
      'restaurante': restaurante?.toJson(),
      'leida': leida,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaEnvio': fechaEnvio?.toIso8601String(),
    };
  }

  Notification copyWith({
    int? idNotificacion,
    User? usuario,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    Restaurant? restaurante,
    bool? leida,
    DateTime? fechaCreacion,
    DateTime? fechaEnvio,
  }) {
    return Notification(
      idNotificacion: idNotificacion ?? this.idNotificacion,
      usuario: usuario ?? this.usuario,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      restaurante: restaurante ?? this.restaurante,
      leida: leida ?? this.leida,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
    );
  }
}

enum TipoNotificacion {
  nuevoRestaurante('NUEVO_RESTAURANTE'),
  actualizacionMenu('ACTUALIZACION_MENU'),
  promocion('PROMOCION'),
  sistema('SISTEMA');

  final String value;
  const TipoNotificacion(this.value);

  static TipoNotificacion fromString(String value) {
    switch (value.toUpperCase()) {
      case 'NUEVO_RESTAURANTE':
        return TipoNotificacion.nuevoRestaurante;
      case 'ACTUALIZACION_MENU':
        return TipoNotificacion.actualizacionMenu;
      case 'PROMOCION':
        return TipoNotificacion.promocion;
      case 'SISTEMA':
      default:
        return TipoNotificacion.sistema;
    }
  }

  String get displayName {
    switch (this) {
      case TipoNotificacion.nuevoRestaurante:
        return 'Nuevo Restaurante';
      case TipoNotificacion.actualizacionMenu:
        return 'Actualización de Menú';
      case TipoNotificacion.promocion:
        return 'Promoción';
      case TipoNotificacion.sistema:
        return 'Sistema';
    }
  }
}