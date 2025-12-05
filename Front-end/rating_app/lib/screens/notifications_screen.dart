import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedTab = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs de filtrado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Todas'),
                  const SizedBox(width: 8),
                  _buildTab('Restaurantes'),
                  const SizedBox(width: 8),
                  _buildTab('Restaurantes'),
                  const SizedBox(width: 8),
                  _buildTab('Menú'),
                ],
              ),
            ),
          ),
          
          // Título de sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notificaciones del día',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          
          // Lista de notificaciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNotificationCard(
                  icon: Icons.store_outlined,
                  iconColor: const Color(0xFF4DD0E1),
                  title: '¡Nuevo restaurante disponible cerca de ti!',
                  description: 'Explora el nuevo local La Cocina Verde y disfruta de sus especialidades frescas.',
                  time: '12:24 am',
                  buttonText: 'Leída',
                  buttonColor: Colors.pink[50]!,
                  buttonTextColor: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  icon: Icons.card_giftcard_outlined,
                  iconColor: const Color(0xFFFF6B6B),
                  title: '¡Promoción especial por tiempo limitado!',
                  description: 'Obtén un 20% de descuento en Taco Express al ordenar antes de las 8 p.m.',
                  time: '12:24 am',
                  buttonText: 'Leída',
                  buttonColor: Colors.pink[50]!,
                  buttonTextColor: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  icon: Icons.store_outlined,
                  iconColor: const Color(0xFF4DD0E1),
                  title: '¡Nuevo restaurante disponible cerca de ti!',
                  description: 'Explora el nuevo local La Cocina Verde y disfruta de sus especialidades frescas.',
                  time: '12:24 am',
                  buttonText: 'Marcar sin leer',
                  buttonColor: Colors.transparent,
                  buttonTextColor: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  icon: Icons.store_outlined,
                  iconColor: const Color(0xFF4DD0E1),
                  title: '¡Nuevo restaurante disponible cerca de ti!',
                  description: 'Explora el nuevo local La Cocina Verde y disfruta de sus especialidades frescas.',
                  time: '12:24 am',
                  buttonText: 'Leída',
                  buttonColor: Colors.pink[50]!,
                  buttonTextColor: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  icon: Icons.restaurant_menu,
                  iconColor: const Color(0xFFFFA726),
                  title: '¡Menú actualizado!',
                  description: '',
                  time: '12:24 am',
                  buttonText: 'Leída',
                  buttonColor: Colors.pink[50]!,
                  buttonTextColor: const Color(0xFFFF6B6B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final isSelected = selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 11,
                          color: buttonTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botón de eliminar
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
            onPressed: () {
              // Lógica para eliminar notificación
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}