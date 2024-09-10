import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PropertyLocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationSelected; // Callback for selected location

  const PropertyLocationPicker({required this.onLocationSelected, Key? key}) : super(key: key);

  @override
  _PropertyLocationPickerState createState() => _PropertyLocationPickerState();
}

class _PropertyLocationPickerState extends State<PropertyLocationPicker> {
  LatLng? selectedLocation; // To store the selected location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Property Location'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(9.779734, 118.737455), // Initial map center (can be the center of your city)
          initialZoom: 15.0,
          maxZoom: 18.0,
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
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
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
