import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
    var isSnackbarOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!isSnackbarOpen.value) {
        // Show "No internet connection" snackbar
        isSnackbarOpen.value = true;
        Get.rawSnackbar(
          messageText: Text(
            'Please connect to the internet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          isDismissible: false,
          duration: Duration(days: 1),
          backgroundColor: Colors.red,
          icon: Icon(Icons.wifi_off_outlined, color: Colors.white, size: 35),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );
      }
    } else {
      if (Get.isSnackbarOpen) {
        // Close the "No internet connection" snackbar
        Get.closeCurrentSnackbar();
      }

      // Show "Connection Restored" snackbar
      if (isSnackbarOpen.value) {
        isSnackbarOpen.value = false; // Reset the snackbar state
        Get.rawSnackbar(
          messageText: Text(
            'Connection Restored',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.green,
          icon: Icon(Icons.wifi, color: Colors.white, size: 35),
          duration: Duration(seconds: 3),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );
      }
    }
  }
}