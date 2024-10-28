import 'dart:convert';
import 'package:http/http.dart' as http;

class OccupantService {
  final String baseUrl;

  OccupantService(this.baseUrl);

  Future<void> createOccupant(Map<String, dynamic> occupantData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/occupant/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(occupantData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create occupant: ${response.body}');
    }
  }

  Future<List<dynamic>> getAllOccupants() async {
    final response = await http.get(Uri.parse('$baseUrl/occupant/getAll'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch occupants: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getOccupantById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/occupant/get/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch occupant: ${response.body}');
    }
  }

  Future<void> updateOccupant(String id, Map<String, dynamic> occupantData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/occupant/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(occupantData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update occupant: ${response.body}');
    }
  }

  Future<void> deleteOccupant(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/occupant/delete/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete occupant: ${response.body}');
    }
  }
}
