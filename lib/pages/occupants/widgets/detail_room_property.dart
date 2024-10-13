// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart'; // Ensure you have this package for icons

class PropertyDetailsWidget extends StatefulWidget {
  final String location;
  final List<dynamic> amenities;
  final String description;
  final List<double> coordinates;

  const PropertyDetailsWidget({
    Key? key,
    required this.location,
    required this.amenities,
    required this.description,
    required this.coordinates,
  }) : super(key: key);

  @override
  State<PropertyDetailsWidget> createState() => _PropertyDetailsWidgetState();
}

class _PropertyDetailsWidgetState extends State<PropertyDetailsWidget> {
  final ThemeController _themeController = Get.find<ThemeController>();

  // Map for amenity icons
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
    // Add more amenities and their respective icons here
  };

  // Map for icon colors
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
    // Add more amenities and their respective icon colors here
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        scrolledUnderElevation: 0.0,
        title: const Text(
          'Property Room Details',
          style: TextStyle(
            fontFamily: 'GeistSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 11.0),
          child: SizedBox(
            height: 40, // Set a specific height for the button
            width: 40, // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 28, 29, 34)
                    : const Color.fromARGB(255, 255, 255, 255),
                side: BorderSide(
                  color: _themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
      ),
      backgroundColor: _themeController.isDarkMode.value
          ? const Color.fromARGB(255, 28, 29, 34)
          : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:_themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 0, 247, 169)
                                  : const Color.fromARGB(255, 0, 247, 169),
                        width: 3.0,
                      )
                    ),
                    color:_themeController.isDarkMode.value? const Color.fromARGB(255, 36, 38, 43): Color.fromARGB(255, 70, 92, 89),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : Colors.white,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            widget.location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Amenities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Displaying amenities with icons in a responsive layout
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.amenities.isNotEmpty
                      ? widget.amenities.map<Widget>((amenity) {
                          return Container(
                            width: (MediaQuery.of(context).size.width / 2) - 24, // Adjust size based on screen width
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 77, 78, 90)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  amenityIcons[amenity] ?? Icons.check_circle, // Use the appropriate icon, fallback to check_circle
                                  color: amenityColors[amenity] ?? Colors.green, // Use the defined color for the icon
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    amenity,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      : [Text('No amenities listed')],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'geistsans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.description),
                const SizedBox(height: 10), // Space before the map
                const Text(
                  'Where to locate?',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'geistsans',
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
                            widget.coordinates[1], // latitude
                            widget.coordinates[0], // longitude
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
                                  widget.coordinates[1], // latitude
                                  widget.coordinates[0], // longitude
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
