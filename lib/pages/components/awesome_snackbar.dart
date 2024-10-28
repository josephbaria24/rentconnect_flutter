import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AwesomeSnackBarWidget {
  static void showSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    ContentType contentType = ContentType.failure, // You can set default to any type
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      duration: Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showMaterialBanner({
    required BuildContext context,
    required String title,
    required String message,
    ContentType contentType = ContentType.success,
  }) {
    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);
  }
}
