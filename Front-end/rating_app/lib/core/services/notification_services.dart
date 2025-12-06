import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/core/services/api_services.dart';
import 'package:rating_app/core/utils/constants.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiServices _apiServices = ApiServices();

  String? deviceToken;

  // Inicializar permisos, token y notificaciones locales
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

  Future<Map<String, dynamic>> sendNotification({
    required int userId,
    required String titulo,
    required String mensaje,
  }) async {
    try {
      debugPrint("📤 Enviando notificación al restaurante $userId");
      debugPrint("📝 Título: $titulo");
      debugPrint("💬 Mensaje: $mensaje");

      final response = await _apiServices.request(
        method: "POST",
        endpoint: Api_Constants.pushNotification,
        data: {
          "userId": userId,
          "titulo": titulo,
          "mensaje": mensaje,
        },
      );

      final responseData = response.data;

      debugPrint("📥 Respuesta notification-send: ${jsonEncode(responseData)}");

      if (responseData["type"] == "SUCCESS") {
        return {
          "status": "OK",
          "message": responseData["message"] ?? "Notificación enviada",
        };
      } else {
        throw Exception(
          responseData["message"] ?? "Error al enviar notificación",
        );
      }
    } catch (e) {
      debugPrint("❌ Error en sendNotification: $e");
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
}
