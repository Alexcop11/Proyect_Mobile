import 'package:flutter/material.dart';
import 'package:rating_app/models/restaurant.dart';
import 'package:rating_app/models/user.dart';

class Favorite {
  final int? idFavorito;
  final User? usuario;
  final Restaurant? restaurante;
  final String fechaAgregado;

  Favorite({
    this.idFavorito,
    this.usuario,
    this.restaurante,
    required this.fechaAgregado,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    try {
      return Favorite(
        idFavorito: json['idFavorito'] as int?,
        usuario: json['usuario'] != null 
            ? User.fromJson(json['usuario']) 
            : null,
        restaurante: json['restaurante'] != null 
            ? Restaurant.fromJson(json['restaurante']) 
            : null,
        fechaAgregado: json['fechaAgregado']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Error en Favorite.fromJson: $e");
      debugPrint("📄 JSON: $json");
      debugPrint("📚 StackTrace: $stackTrace");
      rethrow;
    }
  }

  get restaurantName => null;

  Map<String, dynamic> toJson() {
    return {
      if (idFavorito != null) 'idFavorito': idFavorito,
      if (usuario != null) 'usuario': usuario!.toJson(),
      if (restaurante != null) 'restaurante': restaurante!.toJson(),
      'fechaAgregado': fechaAgregado,
    };
  }
}

// DTO para crear un favorito
class FavoriteDTO {
  final int idUsuario;
  final int idRestaurante;

  FavoriteDTO({
    required this.idUsuario,
    required this.idRestaurante,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'idRestaurante': idRestaurante,
    };
  }
}