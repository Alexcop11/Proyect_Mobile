import 'package:flutter/material.dart';
import 'package:rating_app/screens/notifications_screen.dart';
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const AppBarCustom({
    Key? key,
    required this.title,
    this.onNotificationTap,
    this.onBackTap,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFF6B6B),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Círculo gris a la izquierda (puede ser logo o menú)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: onBackTap ?? () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  )
                : const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          // Título
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // Botón de notificaciones
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            onPressed: onNotificationTap ?? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }}