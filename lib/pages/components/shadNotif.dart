// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/theme_controller.dart';
import 'dart:convert'; // Add this import
import 'package:shadcn_ui/shadcn_ui.dart';

class CardNotifications extends StatefulWidget {
  final String userId;
  final String token;
  final Function(List<dynamic>) onNotificationsUpdated;

  const CardNotifications({
    Key? key,
    required this.userId,
    required this.token,
    required this.onNotificationsUpdated, // Accept the callback
  }) : super(key: key);

  @override
  _CardNotificationsState createState() => _CardNotificationsState();
}

class _CardNotificationsState extends State<CardNotifications> {
  List<dynamic> notifications = [];
  bool hasNewNotifications = false;
  ValueNotifier<bool> pushNotifications = ValueNotifier<bool>(false); // Initialize push notifications value
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Fetch notifications when the widget is initialized
  }

  Future<void> _fetchNotifications() async {
    final fetchedNotifications = await fetchNotifications(widget.userId, widget.token);
    setState(() {
      notifications = fetchedNotifications;
      hasNewNotifications = notifications.isNotEmpty;
    });
    widget.onNotificationsUpdated(notifications); // Notify parent of updates
  }
  
  Future<List<dynamic>> fetchNotifications(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/notification/unread/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('notifications') && data['notifications'] is List) {
          return data['notifications'];
        } else {
          return [];
        }
      } else {
        return []; // Return an empty list if the request fails
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  void _showNotificationsModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Notifications'),
          message: notifications.isEmpty
              ? const Text('No notifications available.')
              : null,
          actions: notifications.map((notification) {
            final status = notification['status'] ?? 'No status available';
            return CupertinoActionSheetAction(
              onPressed: () {
                if (status == 'unread') {
                  _markNotificationAsRead(notification['_id']);
                }
                Navigator.pop(context); // Close the modal
              },
              child: Text(notification['message'] ?? 'No message available'),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
            isDefaultAction: true,
            child: const Text('Close'),
          ),
        );
      },
    );
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    final response = await http.patch(
      Uri.parse('https://rentconnect-backend-nodejs.onrender.com/notification/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Notification marked as read');
      setState(() {
        notifications.removeWhere((notification) => notification['_id'] == notificationId);
        hasNewNotifications = notifications.isNotEmpty; // Update hasNewNotifications
      });
      // Optionally, you could fetch notifications again to ensure the latest data
       _fetchNotifications(); 
    } else {
      print('Failed to mark notification as read');
    }
  }

@override
Widget build(BuildContext context) {
  final theme = ShadTheme.of(context);

  return ShadCard(
    width: 380,
    title: const Text('Notifications'),
    description: const Text('You have new notifications.'),
    child: Column(
      children: [
        const SizedBox(height: 16),
        // Add the Push Notifications Section
        Row(
          children: [
            ShadImage.square(
              LucideIcons.bellRing,
              size: 24,
              color: theme.colorScheme.foreground,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: theme.textTheme.small,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Send notifications to device.',
                      style: theme.textTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: pushNotifications,
              builder: (context, value, child) {
                return ShadSwitch(
                  value: value,
                  onChanged: (v) {
                    pushNotifications.value = v;
                    // Handle enabling/disabling push notifications
                    _handlePushNotifications(v);
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        notifications.isNotEmpty
            ? SizedBox(
                height: 200, // Set a fixed height for scrollable area
                child: Scrollbar(
                  thumbVisibility: true, // Makes the scrollbar always visible
                  child: ListView.builder(
                    itemCount: notifications.length > 5 ? 5 : notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationRow(
                        message: notification['message'] ?? 'No message available',
                        onTap: () => _markNotificationAsRead(notification['_id']),
                      );
                    },
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No notifications available.',
                  style: TextStyle(
                    color: _themeController.isDarkMode.value ? Colors.orange : Colors.orange,
                  ),
                ),
              ),
        const SizedBox(height: 16),
      ],
    ),
    footer: ShadButton(
      width: double.infinity,
      child: const Text('Mark all as read'),
      onPressed: () async {
        await _markAllAsRead();
        // Automatically refresh notifications after marking all as read
        await _fetchNotifications();
      },
    ),
  );
}



  Future<void> _handlePushNotifications(bool isEnabled) async {
    // Implement logic to enable or disable push notifications
    // This could involve calling an API or saving the preference locally
    print('Push notifications ${isEnabled ? 'enabled' : 'disabled'}');
  }

  Future<void> _markAllAsRead() async {
    for (var notification in notifications) {
      if (notification is Map<String, dynamic>) {
        await _markNotificationAsRead(notification['_id']);
      }
    }
    // You can call _fetchNotifications() again here, but it's done after the button is pressed
    setState(() {
      hasNewNotifications = false; // Update the state
      notifications.clear(); // Clear notifications after marking all as read
    });
    print('All notifications marked as read locally.');
  }
}

class NotificationRow extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const NotificationRow({
    Key? key,
    required this.message,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF0CA5E9), // Change color based on status if needed
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
