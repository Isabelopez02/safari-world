import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio centralizado para enviar notificaciones locales del teléfono
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  /// Inicializa el plugin de notificaciones para Android, iOS y Web/Desktop
  Future<void> init() async {
    if (_inicializado) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(settings);

      // Solicitar permisos en Android 13+ (API 33+)
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
      }

      _inicializado = true;
    } catch (e) {
      debugPrint('Error al inicializar NotificationService: $e');
    }
  }

  /// Muestra una notificación inmediata en la barra superior del celular
  Future<void> mostrarNotificacion({
    required String titulo,
    required String cuerpo,
    int id = 0,
  }) async {
    try {
      if (!_inicializado) {
        await init();
      }

      const androidDetails = AndroidNotificationDetails(
        'canal_shows_zoologico',
        'Shows y Cartelera del Zoológico',
        channelDescription:
            'Avisos de funciones, horarios y recomendaciones de visita',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(id, titulo, cuerpo, details);
    } catch (e) {
      debugPrint('Error al mostrar notificación: $e');
    }
  }
}
