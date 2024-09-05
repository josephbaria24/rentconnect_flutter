import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentcon/models/property.dart'; // Import the Property class

Future<List<Property>> getBookmarkedProperties(String token, String userId) async {
  final url = Uri.parse('http://192.168.1.22:3000/getUserBookmarks/$userId'); // Adjust the endpoint if necessary
  
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body); // Ensure the root type is Map
      if (data['status'] == true) {
        final List<dynamic> properties = data['properties'];
        return properties.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookmarked properties.');
      }
    } else {
      throw Exception('Failed to load bookmarked properties. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error loading bookmarked properties: $error');
  }
}
