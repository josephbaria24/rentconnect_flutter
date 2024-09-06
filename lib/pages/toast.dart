import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'colors.dart'; // Import AppColors

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
  final FToast toast;

  ToastNotification(this.toast);

  ToastsColorProps _getToastColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ToastsColorProps(
          AppColors.successTextColor,
          AppColors.successBgColor,
        );
      case ToastType.error:
        return ToastsColorProps(
          AppColors.errorTextColor,
          AppColors.errorBgColor,
        );
      case ToastType.warn:
        return ToastsColorProps(
          AppColors.warnTextColor,
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

  void _showToast(ToastType type, String content, IconData icon) {
    toast.showToast(
      child: _buildToast(type, content, icon),
      gravity: ToastGravity.BOTTOM,
    );
  }

  void success(String content) {
    _showToast(ToastType.success, content, Icons.check);
  }

  void error(String content) {
    _showToast(ToastType.error, content, Icons.error);
  }

  void info(String content) {
    _showToast(ToastType.info, content, Icons.info);
  }

  void warn(String content) {
    _showToast(ToastType.warn, content, Icons.warning);
  }

  Widget _buildToast(ToastType type, String content, IconData icon) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 560, maxWidth: 360),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _getToastColor(type).backgroundColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _getToastColor(type).textColor),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  content,
                  style: TextStyle(
                    color: _getToastColor(type).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
