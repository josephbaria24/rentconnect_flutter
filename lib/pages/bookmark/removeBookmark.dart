import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> removeBookmark(String token, String propertyId) async {
  final url = Uri.parse('http://192.168.1.22:3000/removeBookmark'); // Replace with your backend endpoint
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'propertyId': propertyId,
      }),
    );

    if (response.statusCode == 200) {
      print('Bookmark removed successfully');
    } else {
      throw Exception('Failed to remove bookmark');
    }
  } catch (error) {
    throw Exception('Error removing bookmark: $error');
  }
}
