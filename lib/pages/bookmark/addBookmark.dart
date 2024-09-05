import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> addBookmark(String token, String propertyId) async {
  final url = Uri.parse('http://192.168.1.22:3000/addBookmark'); // Replace with your backend endpoint
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
      print('Bookmark added successfully');
    } else {
      throw Exception('Failed to add bookmark');
    }
  } catch (error) {
    throw Exception('Error adding bookmark: $error');
  }
}
