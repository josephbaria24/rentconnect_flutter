import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationProvider extends ChangeNotifier {
  final String userId;
  final String token;

  List<dynamic> _notifications = [];
  bool _hasNewNotifications = false;

  List<dynamic> get notifications => _notifications;
  bool get hasNewNotifications => _hasNewNotifications;

  NotificationProvider({required this.userId, required this.token});

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('https://rentconnect.vercel.app/notification/unread/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _notifications = data['notifications'] ?? [];
        _hasNewNotifications = _notifications.isNotEmpty;
        notifyListeners(); // Notify listeners about updates
      } else {
        _notifications = [];
        _hasNewNotifications = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://rentconnect.vercel.app/notification/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _notifications.removeWhere((notification) => notification['_id'] == notificationId);
        _hasNewNotifications = _notifications.isNotEmpty;
        notifyListeners();
      } else {
        print('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('https://rentconnect.vercel.app/notification/readAll'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        _notifications.clear();
        _hasNewNotifications = false;
        notifyListeners();
      } else {
        print('Failed to mark all notifications as read');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
