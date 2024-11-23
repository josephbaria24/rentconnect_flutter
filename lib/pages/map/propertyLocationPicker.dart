import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        title: Text('Select Property Location', style: 
        TextStyle(
          fontFamily: 'manrope',
          fontSize: 17,
          fontWeight: FontWeight.bold
        ),),
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
                          Icon(CupertinoIcons.location_solid, color: Colors.red, size: 30),
                       
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
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/loc2.svg',
                            color: const Color.fromARGB(255, 25, 68, 102),
                            height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Add the legend at the top
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legend Title
                  Text(
                    'Legend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: 4),
                  // Legend Items
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/loc2.svg',
                        color: const Color.fromARGB(255, 25, 68, 102),
                        height: 25,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Your Location',
                        style: TextStyle(fontSize: 14, fontFamily: 'manrope', fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Property Location',
                        style: TextStyle(fontSize: 14, fontFamily: 'manrope', fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
    if (selectedLocation == null) {
      // Show prompt if the property location is not selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Not Selected'),
            content: Text('Please select a property location on the map before proceeding.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context, selectedLocation); // Return the selected location if pinned
    }
  },
  child: Icon(Icons.check),
),

    );
  }
}
