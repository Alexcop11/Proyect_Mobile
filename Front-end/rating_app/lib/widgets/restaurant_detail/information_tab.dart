import 'package:flutter/material.dart';

class InformationTab extends StatelessWidget {
  final String description;
  final String horario;
  final String phone;

  const InformationTab({
    Key? key,
    required this.description,
    required this.horario,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Experiencia culinaria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty
                ? description
                : 'Experiencia culinaria que fusiona lo mejor del Mediterráneo con toques locales. Ambiente elegante e ingredientes frescos.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF6B6B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isNotEmpty ? text : 'No disponible',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}