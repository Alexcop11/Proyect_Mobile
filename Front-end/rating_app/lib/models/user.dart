class User {
  final int id_usuario;
  final String email;
  final String password_hash;
  final String tipo_usuario;
  final String nombre;
  final String apellido;
  final String telefeno;
  final DateTime fecha_registro;
  final bool activo;
  final DateTime ultimo_login;

  User({
    required this.id_usuario,
    required this.email,
    required this.password_hash,
    required this.tipo_usuario,
    required this.nombre,
    required this.apellido,
    required this.telefeno,
    required this.fecha_registro,
    required this.activo,
    required this.ultimo_login,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id_usuario: json["id_usuario"],
      email: json["email"],
      password_hash: json["password_hash"],
      tipo_usuario: json["tipo_usuario"],
      nombre: json["nombre"],
      apellido: json["apellido"],
      telefeno: json["telefeno"],
      fecha_registro: json["fecha_registro"],
      activo: json["activo"],
      ultimo_login: json["ultimo_login"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_usuario": id_usuario,
      "email": email,
      "password_hash": password_hash,
      "tipo_usuario": tipo_usuario,
      "nombre": nombre,
      "apellido": apellido,
      "telefeno": telefeno,
      "fecha_registro": fecha_registro,
      "activo": activo,
      "ultimo_login": ultimo_login,
    };
  }
}
