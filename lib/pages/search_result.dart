import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/pages/fullscreenImage.dart'; // Assuming you have this for property images
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/property.dart';

class SearchResultPage extends StatefulWidget {
  final String query;
  final String token;
  final List<Property> properties;
  final String userId;
  final String userEmail;
  final String userRole;
  final String profileStatus;

  SearchResultPage({
    required this.query, 
    required this.properties, 
    required this.token, 
    required this.userId,
    required this.userEmail,
    required this.userRole,
    required this.profileStatus,

    Key? key})
      : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}


class _SearchResultPageState extends State<SearchResultPage> {
  final ThemeController _themeController = Get.find<ThemeController>();
  late String email;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // Safely extracting 'email' from the decoded token
     email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';

    // Mock data, replace this with real data from your backend

  }

  Future<List<dynamic>> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.4:3000/rooms/properties/$propertyId/rooms'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          return data['rooms']; // Return the rooms data as List<dynamic>
        }
      }
    } catch (e) {
      print('Failed to load rooms for property $propertyId');
    }
    return []; // Return an empty list if an error occurs or no rooms are found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.query}"'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove any padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: widget.properties.isEmpty
            ? Center(child: Text('No results found for "${widget.query}".'))
            : ListView.builder(
                itemCount: widget.properties.length,
                itemBuilder: (context, index) {
                  final property = widget.properties[index];
                  final imageUrl = property.photo.startsWith('http')
                      ? property.photo
                      : 'http://192.168.1.4:3000/${property.photo}';
        
                  return FutureBuilder<List<dynamic>>(
                    future: fetchRooms(property.id),
                    builder: (context, roomsSnapshot) {
                      if (roomsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (roomsSnapshot.hasError ||
                          !roomsSnapshot.hasData) {
                        return Center(child: Text('No rooms available.'));
                      }
        
                      final rooms = roomsSnapshot.data!;
                      final priceRange = rooms.isNotEmpty
                          ? '${rooms.map((r) => r['price']).reduce((a, b) => a < b ? a : b)} - ${rooms.map((r) => r['price']).reduce((a, b) => a > b ? a : b)}'
                          : 'N/A';
        
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> PropertyDetailPage(token: widget.token, property: property, userEmail: widget.userEmail, userRole: widget.userRole, profileStatus: widget.profileStatus)));
                          
                        },
                        child: Card(
                          color: _themeController.isDarkMode.value
                              ? Color.fromRGBO(43, 42, 42, 1)
                              : Color.fromRGBO(255, 252, 242, 1),
                          elevation: 5.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullscreenImage(imageUrl: imageUrl),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: imageUrl,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  property.description,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '${property.street}, ${property.barangay}, ${property.city}', // Concatenate street, barangay, and city
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _themeController.isDarkMode.value
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Price Range: $priceRange',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
