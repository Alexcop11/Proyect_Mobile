import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';
import 'package:rating_app/models/notification.dart' as app_notification;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiServices _apiServices = ApiServices();

  String? deviceToken;

  // ==================== Inicialización ====================

  Future<void> initialize() async {
    await _messaging.requestPermission();

    deviceToken = await _messaging.getToken();
    debugPrint("🔑 Token FCM inicial: $deviceToken");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      deviceToken = newToken;
      debugPrint("♻️ Token FCM se actualizó: $newToken");
    });

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);
  }

  Future<Map<String, dynamic>> updatePushToken(int userId) async {
    try {
      if (deviceToken == null) {
        throw Exception("No se pudo obtener el token FCM del dispositivo");
      }

      debugPrint("📤 Enviando pushToken para user $userId");
      debugPrint("🔐 Token a enviar: $deviceToken");

      final response = await _apiServices.request(
        method: "PATCH",
        endpoint: Api_Constants.tokenNotification,
        data: {"id": userId, "pushToken": deviceToken},
      );

      final responseData = response.data;
      debugPrint("📥 Respuesta push-token: ${jsonEncode(responseData)}");

      if (responseData["status"] == "OK") {
        return {
          "status": "OK",
          "message": responseData["message"] ?? "Token actualizado",
        };
      } else {
        throw Exception(responseData["message"] ?? "Error al actualizar token");
      }
    } catch (e) {
      debugPrint("❌ Error en updatePushToken: $e");
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // ==================== Enviar notificación ====================

  Future<Map<String, dynamic>> sendNotification({
    required int userId,
    required String titulo,
    required String mensaje,
    int? restaurantId,
  }) async {
    try {
      debugPrint("📤 Enviando notificación al usuario $userId");
      debugPrint("📝 Título: $titulo");
      debugPrint("💬 Mensaje: $mensaje");
      if (restaurantId != null) {
        debugPrint("🏪 Restaurante: $restaurantId");
      }

      final response = await _apiServices.request(
        method: "POST",
        endpoint: Api_Constants.pushNotification,
        data: {
          "userId": userId,
          "titulo": titulo,
          "mensaje": mensaje,
          if (restaurantId != null) "restaurantId": restaurantId,
        },
      );

      final responseData = response.data;
      debugPrint("📥 Respuesta notification-send: ${jsonEncode(responseData)}");

      if (responseData["type"] == "SUCCESS" || responseData["type"] == "WARNING") {
        return {
          "status": "OK",
          "message": responseData["text"] ?? "Notificación procesada",
          "type": responseData["type"],
        };
      } else {
        throw Exception(
          responseData["text"] ?? "Error al enviar notificación",
        );
      }
    } catch (e) {
      debugPrint("❌ Error en sendNotification: $e");
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // ==================== Obtener notificaciones ====================

  /// Obtener todas las notificaciones de un usuario
  Future<List<app_notification.Notification>> getUserNotifications(
    int userId,
  ) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.notificationPoint}user/$userId',
      );

      final responseData = response.data;
      debugPrint(
        "📡 getUserNotifications: ${responseData['result']?.length ?? 0} notificaciones",
      );

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> notificationsJson = responseData['result'];
        return notificationsJson
            .map((json) => app_notification.Notification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getUserNotifications: $e');
      return [];
    }
  }

  /// Obtener notificaciones no leídas
  Future<List<app_notification.Notification>> getUnreadNotifications(
    int userId,
  ) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.notificationPoint}user/$userId/unread',
      );

      final responseData = response.data;
      debugPrint(
        "📡 getUnreadNotifications: ${responseData['result']?.length ?? 0} no leídas",
      );

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        final List<dynamic> notificationsJson = responseData['result'];
        return notificationsJson
            .map((json) => app_notification.Notification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error en getUnreadNotifications: $e');
      return [];
    }
  }

  /// Contar notificaciones no leídas
  Future<int> countUnreadNotifications(int userId) async {
    try {
      final response = await _apiServices.request(
        method: 'GET',
        endpoint: '${Api_Constants.notificationPoint}user/$userId/unread/count',
      );

      final responseData = response.data;
      debugPrint("📡 countUnreadNotifications: ${responseData['result']}");

      if (responseData['type'] == 'SUCCESS' && responseData['result'] != null) {
        return responseData['result'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Error en countUnreadNotifications: $e');
      return 0;
    }
  }

  /// Obtener notificaciones por tipo
  Future<List<app_notification.Notification>> getNotificationsByType(
    int userId,
    app_notification.TipoNotificacion tipo,
  ) async {
    try {
      // Primero obtenemos todas las notificaciones del usuario
      final allNotifications = await getUserNotifications(userId);
      
      // Filtramos por tipo en el cliente
      return allNotifications.where((n) => n.tipo == tipo).toList();
    } catch (e) {
      debugPrint('❌ Error en getNotificationsByType: $e');
      return [];
    }
  }

  // ==================== Marcar como leída ====================

  /// Marcar una notificación como leída
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiServices.request(
        method: 'PATCH',
        endpoint: '${Api_Constants.notificationPoint}$notificationId/read',
      );

      final responseData = response.data;
      debugPrint("📡 markAsRead: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en markAsRead: $e');
      return false;
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead(int userId) async {
    try {
      final response = await _apiServices.request(
        method: 'PATCH',
        endpoint: '${Api_Constants.notificationPoint}user/$userId/read-all',
      );

      final responseData = response.data;
      debugPrint("📡 markAllAsRead: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en markAllAsRead: $e');
      return false;
    }
  }

  // ==================== Eliminar notificación ====================

  /// Eliminar una notificación
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiServices.request(
        method: 'DELETE',
        endpoint: '${Api_Constants.notificationPoint}$notificationId',
      );

      final responseData = response.data;
      debugPrint("📡 deleteNotification: ${jsonEncode(responseData)}");

      return responseData['type'] == 'SUCCESS';
    } catch (e) {
      debugPrint('❌ Error en deleteNotification: $e');
      return false;
    }
  }
}