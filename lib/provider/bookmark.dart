import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentcon/pages/toast.dart'; // Assuming you're using fluttertoast for toast notifications

class BookmarkProvider extends ChangeNotifier {
  List<String> bookmarkedPropertyIds = [];

  Future<void> bookmarkProperty(BuildContext context, String propertyId, String token) async {
    final url = Uri.parse('http://192.168.1.115:3000/addBookmark');
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    // Create the ToastNotification instance here
    ToastNotification toastNotification = ToastNotification(context);

    try {
      if (bookmarkedPropertyIds.contains(propertyId)) {
        // If already bookmarked, remove it
        final removeUrl = Uri.parse('http://192.168.1.115:3000/removeBookmark');
        await http.post(removeUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        // Update state
        bookmarkedPropertyIds.remove(propertyId);
        toastNotification.warn("Successfully removed from bookmark!");
      } else {
        // If not bookmarked, add it
        await http.post(url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        // Update state
        bookmarkedPropertyIds.add(propertyId);
        toastNotification.success("Successfully added to bookmark!");
      }
      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error toggling bookmark: $error');
      toastNotification.error("Error toggling bookmark!");
    }
  }

  bool isBookmarked(String propertyId) {
    return bookmarkedPropertyIds.contains(propertyId);
  }
}
