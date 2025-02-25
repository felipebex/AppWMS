import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Solicitar todos los permisos necesarios
  static Future<void> requestAllPermissions() async {
    await requestNearbyDevicesPermission();
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