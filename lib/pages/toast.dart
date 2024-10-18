import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart'; // Make sure to import your theme controller if needed
import 'package:shadcn_ui/shadcn_ui.dart';
import 'colors.dart'; // Import AppColors
 // Import ShadToaster and ShadToast

enum ToastType {
  info,
  error,
  success,
  warn,
}

class ToastsColorProps {
  final Color textColor;
  final Color backgroundColor;
  ToastsColorProps(this.textColor, this.backgroundColor);
}

class ToastNotification {
  final BuildContext context; // Context to show the ShadToast
final ThemeController _themeController = Get.find<ThemeController>();
  ToastNotification(this.context);

  ToastsColorProps _getToastColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ToastsColorProps(
          const Color.fromARGB(255, 1, 247, 177),
          AppColors.successBgColor,
        );
      case ToastType.error:
        return ToastsColorProps(
          const Color.fromARGB(255, 250, 45, 45),
          AppColors.errorBgColor,
        );
      case ToastType.warn:
        return ToastsColorProps(
          const Color.fromARGB(255, 245, 117, 19),
          AppColors.warnBgColor,
        );
      case ToastType.info:
      default:
        return ToastsColorProps(
          AppColors.infoTextColor,
          AppColors.infoBgColor,
        );
    }
  }

  void _showToast(ToastType type, String content) {
    IconData icon;
    switch (type) {
      case ToastType.success:
        icon = Icons.check_circle_outline_outlined;
        break;
      case ToastType.error:
        icon = Icons.error_outline_outlined;
        break;
      case ToastType.warn:
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
      default:
        icon = Icons.info_outline_rounded;
        break;
    }

    ShadToaster.of(context).show(
      ShadToast(
        
        title: Text(
          _getToastTitle(type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        closeIcon: Icon(Icons.close_outlined, color: Colors.white,),
        description: Row(
          children: [
            Icon(icon, color: _getToastColor(type).textColor),
            SizedBox(width: 8), // Add some space between icon and text
            Flexible(
              child: Text(
                content,
                style: TextStyle(color: _getToastColor(type).textColor),
              ),
            ),
          ],
        ),
        duration: Duration(milliseconds: 2000),
        alignment: Alignment.topRight,
        
        
      )
    );
  }

  String _getToastTitle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return 'Success';
      case ToastType.error:
        return 'Error';
      case ToastType.warn:
        return 'Warning';
      case ToastType.info:
      default:
        return 'Info';
    }
  }

  void success(String content) {
    _showToast(ToastType.success, content);
  }

  void error(String content) {
    _showToast(ToastType.error, content);
  }

  void info(String content) {
    _showToast(ToastType.info, content);
  }

  void warn(String content) {
    _showToast(ToastType.warn, content);
  }
}
