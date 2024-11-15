import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PropertyLocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationSelected; // Callback for selected location

  const PropertyLocationPicker({required this.onLocationSelected, Key? key}) : super(key: key);

  @override
  _PropertyLocationPickerState createState() => _PropertyLocationPickerState();
}

class _PropertyLocationPickerState extends State<PropertyLocationPicker> {
  LatLng? selectedLocation; // To store the selected location
  LatLng? userLocation;     // To store the user's current location
  final MapController _mapController = MapController();
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _requestLocationAndCenterMap(); // Request location on widget initialization
  }

  // Function to request location permission and get current location
  Future<void> _requestLocationAndCenterMap() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        // Center the map on the user's location
        _mapController.move(userLocation!, 20.0);
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Show a message or prompt the user to enable location permission
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Property Location'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Assign the map controller
            options: MapOptions(
              initialCenter: userLocation ?? LatLng(9.779734, 118.737455), // Initial map center
              initialZoom: 15.0,
              maxZoom: 20.0,
              minZoom: 12,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
                widget.onLocationSelected(point); // Pass the selected location back
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 150,
                      height: 100,
                      child: Column(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red, size: 40),
                          Text('Property location', style: TextStyle(color: Colors.red, fontFamily: 'manrope', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (userLocation != null) // Display "You" marker if user location is available
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 80,
                      height: 80,
                      child:  Column(
                        children: [
                          Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                          Text('You', style: TextStyle(color: Colors.blue, fontFamily: 'manrope', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Add the "center map" button
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (userLocation != null) {
                  _mapController.move(userLocation!, 15.0); // Center the map to user's location
                }
              },
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation); // Return the selected location
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
