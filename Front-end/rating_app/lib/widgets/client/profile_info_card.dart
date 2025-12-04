import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  // Mapa de datos: {'Etiqueta': 'Valor'} e.g., {'Nombre': 'Maria Garcia'}
  final Map<String, String> details; 

  const ProfileInfoCard ({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo para las etiquetas (Nombre, Correo Electrónico, Teléfono)
    const TextStyle labelStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF666666),
      fontWeight: FontWeight.w500,
    );

    // Estilo para los valores (Maria Garcia, maria.garcia@gmail.com, 777-854-24-10)
    const TextStyle valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Encabezado (Ícono y Título)
          Row(
            children: [
              // Ícono
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Usamos w600 para que coincida con la imagen
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2. Detalles del Perfil (Nombre, Correo, Teléfono)
          ...details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta (e.g., Nombre)
                  Expanded(
                    flex: 1,
                    child: Text(
                      entry.key,
                      style: labelStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Valor (e.g., Maria Garcia)
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.value,
                      style: valueStyle,
                      textAlign: TextAlign.end, // Alinea el valor a la derecha
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
