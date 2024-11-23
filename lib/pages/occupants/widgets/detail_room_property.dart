// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentcon/pages/services/backend_service.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PropertyDetailsWidget extends StatefulWidget {
  final String? location;
  final List<dynamic>? amenities;
  final String? description;
  final List<double>? coordinates;
  final Map<String, dynamic>? roomDetails;
  final String? token;

  const PropertyDetailsWidget({
    Key? key,
    required this.location,
    required this.amenities,
    required this.description,
    required this.coordinates,
    required this.roomDetails,
    required this.token,
  }) : super(key: key);

  @override
  State<PropertyDetailsWidget> createState() => _PropertyDetailsWidgetState();
}

class _PropertyDetailsWidgetState extends State<PropertyDetailsWidget> {
  final ThemeController _themeController = Get.find<ThemeController>();
  Map<String, dynamic>? userProfile;

  final Map<String, IconData> amenityIcons = {
    'WiFi': Icons.wifi,
    'Parking': Icons.local_parking,
    'Pool': Icons.pool,
    'Study lounge': LineAwesomeIcons.book_open_solid,
    'Gym': Icons.fitness_center,
    'Air Conditioning': Icons.ac_unit,
    'Laundry': Icons.local_laundry_service,
    'Pets Allowed': Icons.pets,
    'Elevator': Icons.elevator,
    'CCTV': Icons.videocam,
  };

  final Map<String, Color> amenityColors = {
    'WiFi': Colors.blue,
    'Parking': Colors.green,
    'Pool': Colors.lightBlue,
    'Study lounge': Colors.orange,
    'Gym': Colors.red,
    'Air Conditioning': Colors.purple,
    'Laundry': Colors.yellow,
    'Pets Allowed': Colors.brown,
    'Elevator': Colors.cyan,
    'CCTV': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    if (widget.roomDetails != null && widget.token != null) {
      fetchUserProfile(widget.roomDetails!['ownerId'], widget.token!);
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String? userId, String token) async {
    if (userId == null) return null;
    final url = Uri.parse('https://rentconnect.vercel.app/user/$userId');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userProfile = data;
        });
        return data;
      } else {
        print('No profile found');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final landlordId = widget.roomDetails?['ownerId'] ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value
            ? Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        scrolledUnderElevation: 0.0,
        title: Text(
          'Property Room Details',
          style: TextStyle(
            fontFamily: 'manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: 11.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 28, 29, 34)
                    : Color.fromARGB(255, 255, 255, 255),
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  width: 0.90,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color.fromARGB(255, 0, 247, 169),
                        width: 3.0,
                      ),
                    ),
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                          ),
                        ),
                        Text(
                          widget.location ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.5,
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Landlord Contact Information:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Name: ${userProfile?['profile']?['firstName'] ?? 'N/A'} ${userProfile?['profile']?['lastName'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Contact: ${userProfile?['profile']?['contactDetails']?['phone'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Email: ${userProfile?['email'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'manrope',
                            color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Amenities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.amenities?.isNotEmpty ?? false
                      ? widget.amenities!.map<Widget>((amenity) {
                          return Container(
                            width: (MediaQuery.of(context).size.width / 2) - 24,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _themeController.isDarkMode.value
                                  ? Color.fromARGB(255, 77, 78, 90)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  amenityIcons[amenity] ?? Icons.check_circle,
                                  color: amenityColors[amenity] ?? Colors.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  amenity,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      : [Text('No amenities available')],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'manrope',
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.description!),
                const SizedBox(height: 10), // Space before the map
                const Text(
                  'Where to locate?',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 114, 114, 114),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            widget.coordinates![1], // latitude
                            widget.coordinates![0], // longitude
                          ),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 40,
                                height: 40,
                                point: LatLng(
                                  widget.coordinates![1], // latitude
                                  widget.coordinates![0], // longitude
                                ),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
