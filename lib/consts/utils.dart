import 'package:permission_handler/permission_handler.dart';

class Utils {
  // Method to check storage permission status
  static Future<bool> checkPermission() async {
    PermissionStatus status = await Permission.storage.status;
    return status.isGranted;
  }

  // Method to request storage permission if not granted
  static Future<bool> requestPermission() async {
    if (await checkPermission()) {
      return true;
    }
    PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }
}
