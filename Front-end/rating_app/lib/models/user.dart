// lib/models/user.dart
class User {
  final int? idUsuario;
  final String nombre;
  final String? apellido; // ✅ Nuevo campo
  final String email;
  final String? telefono;
  final TipoUsuario tipoUsuario;
  final bool activo;
  final DateTime? fechaRegistro;
  final DateTime? ultimoLogin;

  User({
    this.idUsuario,
    required this.nombre,
    this.apellido, // ✅ Nuevo parámetro
    required this.email,
    this.telefono,
    this.tipoUsuario = TipoUsuario.NORMAL,
    this.activo = true,
    this.fechaRegistro,
    this.ultimoLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['idUsuario'] ?? json['id_usuario'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'], // ✅ Leer apellido del JSON
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? json['telefeno'],
      tipoUsuario: _parseTipoUsuario(json['tipoUsuario'] ?? json['tipo_usuario']),
      activo: json['activo'] ?? true,
      fechaRegistro: json['fechaRegistro'] != null 
          ? DateTime.parse(json['fechaRegistro']) 
          : null,
      ultimoLogin: json['ultimoLogin'] != null 
          ? DateTime.parse(json['ultimoLogin']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombre': nombre,
      if (apellido != null) 'apellido': apellido, // ✅ Incluir apellido si existe
      'email': email,
      'telefono': telefono,
      'tipoUsuario': tipoUsuario.toString().split('.').last,
      'activo': activo,
    };
  }

  static TipoUsuario _parseTipoUsuario(dynamic value) {
    if (value == null) return TipoUsuario.NORMAL;
    if (value is String) {
      return TipoUsuario.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => TipoUsuario.NORMAL,
      );
    }
    return TipoUsuario.NORMAL;
  }

  // ✅ Getter para obtener nombre completo
  String get nombreCompleto {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombre $apellido';
    }
    return nombre;
  }

  // Método para obtener las iniciales
  String get iniciales {
    if (nombre.isEmpty) return '??';
    
    // Si hay apellido, usar primera letra de nombre y apellido
    if (apellido != null && apellido!.isNotEmpty) {
      return '${nombre[0]}${apellido![0]}'.toUpperCase();
    }
    
    // Si no hay apellido, usar las primeras dos letras del nombre o dos palabras
    final palabras = nombre.trim().split(' ');
    if (palabras.length >= 2) {
      return '${palabras[0][0]}${palabras[1][0]}'.toUpperCase();
    }
    
    if (nombre.length >= 2) {
      return nombre.substring(0, 2).toUpperCase();
    }
    
    return nombre.substring(0, 1).toUpperCase();
  }

  User copyWith({
    int? idUsuario,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    TipoUsuario? tipoUsuario,
    bool? activo,
  }) {
    return User(
      idUsuario: idUsuario ?? this.idUsuario,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido, // ✅ Incluir apellido en copyWith
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      activo: activo ?? this.activo,
    );
  }
}

enum TipoUsuario {
  NORMAL,
  ADMIN,
  RESTAURANTE, // ✅ Agregado por si lo necesitas
}