// ignore_for_file: deprecated_member_use

import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showLoading() {
  Get.dialog(
    Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 200,
              child: Image.asset(
                "assets/images/icon.png",

                fit: BoxFit.cover,
              ),
            ),
            const Text(
              "Cargando datos...",
              style: TextStyle(
                  fontSize: 20.0, color: black),
            ),
            
          ],
        ),
      ),
    ),
    // barrierDismissible: true,
  );
}

showSessionDialog() {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Text(
        "Session Time out",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        "Sorry! your session is expired, Please login again",
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            PrefUtils.clearPrefs();
          },
          child: const Text(
            'signin',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    ),
  );
}

showErrorDialog(String message) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: const Text(
        "Error",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    ),
  );
}

handleApiError(errorMessage) {
  showSnackBar(backgroundColor: Colors.redAccent, message: errorMessage);
}

showWarning(message) {
  showSnackBar(backgroundColor: Colors.blueAccent, message: message);
}

hideLoading() {
  Get.back();
}

void showSnackBar(
    {title,
    message,
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Duration? duration}) {
  Get.showSnackbar(
    GetBar(
      title: title,
      message: message,
      duration: duration ?? const Duration(seconds: 2),
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.black87,
    ),
  );
}

// showLogoutDialog() {
//   Get.dialog(
//     AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       title: const Text(
//         "Logout",
//       ),
//       content: const Text(
//         "Are you sure you want to logout?",
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             Get.back();
//           },
//           child: const Text(
//             'Cancel',
//           ),
//         ),
//         TextButton(
//           onPressed: () async {
//             await AuthenticationModule().logoutApi();
//           },
//           child: const Text(
//             "Logout",
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Future<String> getImageUrl(
//     {required String model, required String field, required String id}) async {
//   String session = await PrefUtils.getToken();
//   return "${Config.OdooDevURL}/web/image?model=$model&field=$field&$session&id=$id";
// }
