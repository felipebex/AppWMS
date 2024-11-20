import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wms_app/environment/environment.dart';

final class LocalNotificationsService {
// Instancia global del plugin de notificaciones
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();




static Future<void> reqyestPermissionsLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }


// Método para inicializar las notificaciones
  Future<void> initializeNotifications() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
        Environment.flavor.appName == "BexPicking"
            ?
             'ic_launcherbex'
            : 'ic_launcher'
            ); // Asegúrate de tener el icono en la carpeta de recursos
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Inicialización sin el parámetro onSelectNotification
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: selectNotification);
  }

// Acción cuando el usuario selecciona la notificación
  Future selectNotification(NotificationResponse details) async {
    // Aquí puedes navegar a la vista deseada, pasando un payload si es necesario
    final String? payload = details.payload;
    if (payload != null) {
      print("Notificación seleccionada: $payload");
      // Aquí puedes navegar a la vista "batch_picking" o a donde necesites
      // Navigator.pushNamed(context, '/batch_picking');
    }
  }

// Función para mostrar una notificación
  Future<void> showNotification(
      String title, String body, String payload
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel', // Canal de notificación
      'Canal de Notificaciones', // Descripción
      importance: Importance.high, // Mostrar de manera destacada
      priority: Priority.high, // Prioridad alta
      sound: RawResourceAndroidNotificationSound('notification'), // Sonido
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación
      title, // Título
      body, // Cuerpo
      platformDetails,
      payload: 'batch_picking', // Payload para identificar la acción
    );
  }
}
