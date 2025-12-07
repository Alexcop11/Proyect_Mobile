import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/providers/notification_provider.dart';
import 'package:rating_app/models/notification.dart' as app_notification;
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser?.idUsuario != null) {
      await notificationProvider.loadUserNotifications(
        authProvider.currentUser!.idUsuario!,
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  IconData _getIconForType(app_notification.TipoNotificacion tipo) {
    switch (tipo) {
      case app_notification.TipoNotificacion.nuevoRestaurante:
        return Icons.store_outlined;
      case app_notification.TipoNotificacion.actualizacionMenu:
        return Icons.restaurant_menu;
      case app_notification.TipoNotificacion.promocion:
        return Icons.card_giftcard_outlined;
      case app_notification.TipoNotificacion.sistema:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(app_notification.TipoNotificacion tipo) {
    switch (tipo) {
      case app_notification.TipoNotificacion.nuevoRestaurante:
        return const Color(0xFF4DD0E1);
      case app_notification.TipoNotificacion.actualizacionMenu:
        return const Color(0xFFFFA726);
      case app_notification.TipoNotificacion.promocion:
        return const Color(0xFFFF6B6B);
      case app_notification.TipoNotificacion.sistema:
        return const Color(0xFF9575CD);
    }
  }

  Future<void> _handleMarkAsRead(int notificationId, bool isRead) async {
    if (isRead) return; // Ya está leída

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final success = await notificationProvider.markAsRead(notificationId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación marcada como leída'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser?.idUsuario == null) return;

    final success = await notificationProvider.markAllAsRead(
      authProvider.currentUser!.idUsuario!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas las notificaciones marcadas como leídas'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete(int notificationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final success = await notificationProvider.deleteNotification(notificationId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación eliminada'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
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
            actions: [
              if (notificationProvider.unreadCount > 0)
                TextButton.icon(
                  onPressed: _handleMarkAllAsRead,
                  icon: const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Marcar todas',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadNotifications,
            color: const Color(0xFFFF6B6B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs de filtrado
                _buildFilterTabs(notificationProvider),

                // Badge de no leídas
                if (notificationProvider.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${notificationProvider.unreadCount} sin leer',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ),

                // Título de sección
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                  child: _buildNotificationsList(notificationProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs(NotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('Todas', null, provider),
            const SizedBox(width: 8),
            _buildTab(
              'Restaurantes',
              app_notification.TipoNotificacion.nuevoRestaurante,
              provider,
            ),
            const SizedBox(width: 8),
            _buildTab(
              'Promociones',
              app_notification.TipoNotificacion.promocion,
              provider,
            ),
            const SizedBox(width: 8),
            _buildTab(
              'Menú',
              app_notification.TipoNotificacion.actualizacionMenu,
              provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    String text,
    app_notification.TipoNotificacion? tipo,
    NotificationProvider provider,
  ) {
    final isSelected = provider.selectedFilter == tipo;
    return GestureDetector(
      onTap: () => provider.filterByType(tipo),
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

  Widget _buildNotificationsList(NotificationProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNotificationCard(notification),
        );
      },
    );
  }

  Widget _buildNotificationCard(app_notification.Notification notification) {
    final icon = _getIconForType(notification.tipo);
    final color = _getColorForType(notification.tipo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.leida ? Colors.grey[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.leida ? Colors.grey[200]! : Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        notification.leida ? FontWeight.w500 : FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (notification.mensaje.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.mensaje,
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
                      _formatTime(notification.fechaCreacion),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _handleMarkAsRead(
                        notification.idNotificacion!,
                        notification.leida,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: notification.leida
                              ? Colors.pink[50]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: notification.leida
                              ? null
                              : Border.all(color: const Color(0xFFFF6B6B)),
                        ),
                        child: Text(
                          notification.leida ? 'Leída' : 'Marcar como leída',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w500,
                          ),
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
            onPressed: () => _handleDelete(notification.idNotificacion!),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}