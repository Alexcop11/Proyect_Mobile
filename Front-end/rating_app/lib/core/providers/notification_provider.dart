import 'package:flutter/material.dart';
import 'package:rating_app/core/services/notification_services.dart';
import 'package:rating_app/models/notification.dart' as app_notification;

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  List<app_notification.Notification> _notifications = [];
  List<app_notification.Notification> _filteredNotifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  app_notification.TipoNotificacion? _selectedFilter;

  // Getters
  List<app_notification.Notification> get notifications => _filteredNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  app_notification.TipoNotificacion? get selectedFilter => _selectedFilter;

  // ==================== Cargar notificaciones ====================

  /// Cargar todas las notificaciones de un usuario
  Future<void> loadUserNotifications(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getUserNotifications(userId);
      _filteredNotifications = List.from(_notifications);
      await _loadUnreadCount(userId);
      
      debugPrint('✅ Notificaciones cargadas: ${_notifications.length}');
    } catch (e) {
      _errorMessage = 'Error al cargar notificaciones: $e';
      debugPrint('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar solo notificaciones no leídas
  Future<void> loadUnreadNotifications(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getUnreadNotifications(userId);
      _filteredNotifications = List.from(_notifications);
      _unreadCount = _notifications.length;
      
      debugPrint('✅ Notificaciones no leídas: $_unreadCount');
    } catch (e) {
      _errorMessage = 'Error al cargar notificaciones: $e';
      debugPrint('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar contador de no leídas
  Future<void> _loadUnreadCount(int userId) async {
    try {
      _unreadCount = await _notificationService.countUnreadNotifications(userId);
      debugPrint('📊 Notificaciones no leídas: $_unreadCount');
    } catch (e) {
      debugPrint('❌ Error al cargar contador: $e');
    }
  }

  // ==================== Filtros ====================

  /// Aplicar filtro por tipo
  void filterByType(app_notification.TipoNotificacion? tipo) {
    _selectedFilter = tipo;
    
    if (tipo == null) {
      // Mostrar todas
      _filteredNotifications = List.from(_notifications);
    } else {
      // Filtrar por tipo
      _filteredNotifications = _notifications
          .where((notification) => notification.tipo == tipo)
          .toList();
    }
    
    notifyListeners();
  }

  /// Limpiar filtros
  void clearFilters() {
    _selectedFilter = null;
    _filteredNotifications = List.from(_notifications);
    notifyListeners();
  }

  // ==================== Marcar como leída ====================

  /// Marcar una notificación como leída
  Future<bool> markAsRead(int notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      
      if (success) {
        // Actualizar localmente
        final index = _notifications.indexWhere(
          (n) => n.idNotificacion == notificationId,
        );
        
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(leida: true);
          
          // Actualizar lista filtrada
          final filteredIndex = _filteredNotifications.indexWhere(
            (n) => n.idNotificacion == notificationId,
          );
          if (filteredIndex != -1) {
            _filteredNotifications[filteredIndex] = 
                _filteredNotifications[filteredIndex].copyWith(leida: true);
          }
          
          // Decrementar contador
          if (_unreadCount > 0) _unreadCount--;
          
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error al marcar como leída: $e';
      debugPrint('❌ $_errorMessage');
      return false;
    }
  }

  /// Marcar todas como leídas
  Future<bool> markAllAsRead(int userId) async {
    try {
      final success = await _notificationService.markAllAsRead(userId);
      
      if (success) {
        // Actualizar todas localmente
        _notifications = _notifications.map((n) => n.copyWith(leida: true)).toList();
        _filteredNotifications = _filteredNotifications
            .map((n) => n.copyWith(leida: true))
            .toList();
        
        _unreadCount = 0;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error al marcar todas como leídas: $e';
      debugPrint('❌ $_errorMessage');
      return false;
    }
  }

  // ==================== Eliminar notificación ====================

  /// Eliminar una notificación
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        // Verificar si estaba sin leer antes de eliminar
        final notification = _notifications.firstWhere(
          (n) => n.idNotificacion == notificationId,
          orElse: () => _notifications.first,
        );
        
        final wasUnread = !notification.leida;
        
        // Eliminar localmente
        _notifications.removeWhere((n) => n.idNotificacion == notificationId);
        _filteredNotifications.removeWhere((n) => n.idNotificacion == notificationId);
        
        // Actualizar contador si estaba sin leer
        if (wasUnread && _unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar notificación: $e';
      debugPrint('❌ $_errorMessage');
      return false;
    }
  }

  // ==================== Helpers ====================

  /// Obtener notificaciones del día
  List<app_notification.Notification> getTodayNotifications() {
    final today = DateTime.now();
    return _filteredNotifications.where((notification) {
      final notificationDate = notification.fechaCreacion;
      return notificationDate.year == today.year &&
          notificationDate.month == today.month &&
          notificationDate.day == today.day;
    }).toList();
  }

  /// Limpiar estado
  void clear() {
    _notifications = [];
    _filteredNotifications = [];
    _unreadCount = 0;
    _selectedFilter = null;
    _errorMessage = null;
    notifyListeners();
  }
}