import 'package:rating_app/models/user.dart';
import 'package:rating_app/models/restaurant.dart';

class Review {
  int? idCalificacion;
  User? usuario;
  Restaurant? restaurante;
  int? puntuacionComida;
  int? puntuacionServicio;
  int? puntuacionAmbiente;
  String? comentario;
  DateTime? fechaCalificacion;

  Review({
    this.idCalificacion,
    this.usuario,
    this.restaurante,
    this.puntuacionComida,
    this.puntuacionServicio,
    this.puntuacionAmbiente,
    this.comentario,
    this.fechaCalificacion,
  });

  // Factory constructor para crear desde JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idCalificacion: json['idCalificacion'],
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      restaurante: json['restaurante'] != null 
          ? Restaurant.fromJson(json['restaurante']) 
          : null,
      puntuacionComida: json['puntuacionComida'],
      puntuacionServicio: json['puntuacionServicio'],
      puntuacionAmbiente: json['puntuacionAmbiente'],
      comentario: json['comentario'],
      fechaCalificacion: json['fechaCalificacion'] != null
          ? DateTime.parse(json['fechaCalificacion'])
          : null,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'idCalificacion': idCalificacion,
      'usuario': usuario?.toJson(),
      'restaurante': restaurante?.toJson(),
      'puntuacionComida': puntuacionComida,
      'puntuacionServicio': puntuacionServicio,
      'puntuacionAmbiente': puntuacionAmbiente,
      'comentario': comentario,
      'fechaCalificacion': fechaCalificacion?.toIso8601String(),
    };
  }

  // Método para crear un objeto para enviar al backend (sin objetos anidados)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'idUsuario': usuario?.idUsuario,
      'idRestaurante': restaurante?.idRestaurante,
      'puntuacionComida': puntuacionComida,
      'puntuacionServicio': puntuacionServicio,
      'puntuacionAmbiente': puntuacionAmbiente,
      'comentario': comentario,
      'fechaCalificacion': fechaCalificacion?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Calcular el promedio de las puntuaciones
  double get promedioCalificacion {
    if (puntuacionComida == null && 
        puntuacionServicio == null && 
        puntuacionAmbiente == null) {
      return 0.0;
    }
    
    final comida = puntuacionComida ?? 0;
    final servicio = puntuacionServicio ?? 0;
    final ambiente = puntuacionAmbiente ?? 0;
    
    return (comida + servicio + ambiente) / 3.0;
  }

  // Copiar con modificaciones
  Review copyWith({
    int? idCalificacion,
    User? usuario,
    Restaurant? restaurante,
    int? puntuacionComida,
    int? puntuacionServicio,
    int? puntuacionAmbiente,
    String? comentario,
    DateTime? fechaCalificacion,
  }) {
    return Review(
      idCalificacion: idCalificacion ?? this.idCalificacion,
      usuario: usuario ?? this.usuario,
      restaurante: restaurante ?? this.restaurante,
      puntuacionComida: puntuacionComida ?? this.puntuacionComida,
      puntuacionServicio: puntuacionServicio ?? this.puntuacionServicio,
      puntuacionAmbiente: puntuacionAmbiente ?? this.puntuacionAmbiente,
      comentario: comentario ?? this.comentario,
      fechaCalificacion: fechaCalificacion ?? this.fechaCalificacion,
    );
  }

  @override
  String toString() {
    return 'Review(idCalificacion: $idCalificacion, '
        'usuario: ${usuario?.nombre}, '
        'restaurante: ${restaurante?.nombre}, '
        'promedio: ${promedioCalificacion.toStringAsFixed(1)}, '
        'comentario: $comentario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Review &&
        other.idCalificacion == idCalificacion &&
        other.usuario == usuario &&
        other.restaurante == restaurante;
  }

  @override
  int get hashCode {
    return idCalificacion.hashCode ^
        usuario.hashCode ^
        restaurante.hashCode;
  }
}