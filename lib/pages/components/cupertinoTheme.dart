import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart'; // Your ThemeController file

void _showReservationConfirmation(BuildContext context, Map<String, dynamic> room, ThemeController themeController) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: themeController.isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Confirm Reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room/Unit no. ${room['roomNumber']}'),
              Text('Reservation Fee: ₱${room['reservationFee']}'),
              Text('Reservation Duration: ${room['reservationDuration']} Days'),
              const SizedBox(height: 16),
              const Text(
                'Warning: The reservation fee is non-refundable.',
                style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context); // Cancel button
              },
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                // Proceed to send reserve request
              },
              isDestructiveAction: true,
              child: const Text('Send Reserve Request'),
            ),
          ],
        ),
      );
    },
  );
}
