import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/fullscreenImage.dart'; // Assuming you have this for property images
import 'package:rentcon/theme_controller.dart';
import '../models/property.dart';

class SearchResultPage extends StatelessWidget {
  final String query;
  final List<Property> properties;

  SearchResultPage({required this.query, required this.properties, Key? key}) : super(key: key);
   final ThemeController _themeController = Get.find<ThemeController>();

  Future<List<dynamic>> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.8:3000/rooms/properties/$propertyId/rooms'));
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
        title: Text('Search Results for "$query"'),
      ),
      body: properties.isEmpty
          ? Center(child: Text('No results found for "$query".'))
          : ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                final imageUrl = property.photo.startsWith('http')
                    ? property.photo
                    : 'http://192.168.1.8:3000/${property.photo}';

                return FutureBuilder<List<dynamic>>(
                  future: fetchRooms(property.id),
                  builder: (context, roomsSnapshot) {
                    if (roomsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (roomsSnapshot.hasError || !roomsSnapshot.hasData) {
                      return Center(child: Text('No rooms available.'));
                    }

                    final rooms = roomsSnapshot.data!;
                    final priceRange = rooms.isNotEmpty
                        ? '${rooms.map((r) => r['price']).reduce((a, b) => a < b ? a : b)} - ${rooms.map((r) => r['price']).reduce((a, b) => a > b ? a : b)}'
                        : 'N/A';

                    return Card(
                      color: _themeController.isDarkMode.value ? Color.fromRGBO(43, 42, 42, 1) : Color.fromRGBO(255, 252, 242, 1) ,
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullscreenImage(imageUrl: imageUrl),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    );
                  },
                );
              },
            ),
    );
  }
}

