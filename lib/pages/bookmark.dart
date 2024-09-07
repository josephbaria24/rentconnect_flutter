import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/home.dart';
import 'toast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/models/property.dart'; // Import the correct Property class

Future<List<Property>> getBookmarkedProperties(String token, String userId) async {
  final url = Uri.parse('http://192.168.1.13:3000/getUserBookmarks/$userId'); // Adjust the endpoint if necessary

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['status'] == true) {
        final List<dynamic> properties = data['properties'];
        // Ensure that properties is a list of maps and map each property to Property object
        return properties.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookmarked properties: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      // Log or print the response body for debugging
      print('Response body: ${response.body}');
      throw Exception('Failed to load bookmarked properties. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    // Print the error to debug
    print('Error loading bookmarked properties: $error');
    throw Exception('Error loading bookmarked properties: $error');
  }
}

class BookmarkPage extends StatefulWidget {
  final String token;

  const BookmarkPage({required this.token, Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<Property>> bookmarkedProperties;
  late String email;
  late String userId;
  late FToast ftoast;
  late ToastNotification toast;

  @override
  void initState() {
    super.initState();
    ftoast = FToast(); // Initialize FToast
    ftoast.init(context);
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId =  jwtDecodedToken['_id']?.toString() ?? 'Unknown userID'; // Implement this function
    bookmarkedProperties = getBookmarkedProperties(widget.token, userId);
    toast = ToastNotification(ftoast.init(context));
  }

  @override
  Widget build(BuildContext context) {
    ftoast = FToast();
    ftoast.init(context);
    toast = ToastNotification(ftoast);
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      appBar: AppBar(
        title: Text('Bookmarked Properties $userId'),
      ),
      body: FutureBuilder<List<Property>>(
        future: bookmarkedProperties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookmarked properties.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final property = snapshot.data![index];
                final imageUrl = property.photo.startsWith('http')
                    ? property.photo
                    : 'http://192.168.1.13:3000/${property.photo}'; // Handle relative image URLs

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ListTile(
                    title: Text(property.description),
                    subtitle: Text('₱${property.price.toStringAsFixed(2)} - ${property.address}',
                    style:TextStyle(
                         fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                         ),),
                    leading: Image.network(imageUrl, width: 100, fit: BoxFit.cover),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Implement this function to extract userId from the token
String extractUserIdFromToken(String token) {
  // Example implementation using jwt_decoder package:
  // Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  // return decodedToken['userId'];
  return 'userId'; // Replace with actual logic
}