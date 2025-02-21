import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Solicitar todos los permisos necesarios
  static Future<void> requestAllPermissions() async {
    await requestNotificationPermission();
    await requestCameraPermission();
    await requestLocationPermission();
    await requestNearbyDevicesPermission();
  }

  // Solicitar permiso de notificaciones
  static Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // Solicitar permiso de cámara
  static Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  // Solicitar permiso de localización
  static Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  // Solicitar permiso de dispositivos cercanos
  static Future<void> requestNearbyDevicesPermission() async {
    var status = await Permission.nearbyWifiDevices.status;
    if (!status.isGranted) {
      await Permission.nearbyWifiDevices.request();
    }
  }

  // Verificar si todos los permisos están concedidos
  static Future<bool> checkAllPermissions() async {
    return await Permission.notification.isGranted &&
           await Permission.camera.isGranted &&
           await Permission.location.isGranted &&
           await Permission.nearbyWifiDevices.isGranted;
  }
}