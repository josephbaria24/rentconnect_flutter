import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/models/property.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PropertyDetailPage extends StatefulWidget {
  final Property property;
  final String userEmail;

  const PropertyDetailPage({required this.property, required this.userEmail, Key? key}) : super(key: key);

  @override
  _PropertyDetailPageState createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  List<dynamic> rooms = [];
  bool _showMap = false;
  final PageController _pageController = PageController();
  final ThemeController _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.get(Uri.parse('http://192.168.1.16:3000/rooms/properties/${widget.property.id}/rooms'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        setState(() {
          rooms = data['rooms'];
        });
      }
    } else {
      print('Failed to load rooms');
    }
  }

void showRoomDetailsModal(BuildContext context, Map<String, dynamic> room) {
  // Define a list of room photo URLs
  final List<String> roomPhotoUrls = [
    room['photo1'] != null ? 'http://192.168.1.16:3000/${room['photo1']}' : '',
    room['photo2'] != null ? 'http://192.168.1.16:3000/${room['photo2']}' : '',
    room['photo3'] != null ? 'http://192.168.1.16:3000/${room['photo3']}' : '',
  ].where((url) => url.isNotEmpty).toList();

  // Create a PageController for the room photos
  final PageController _roomPageController = PageController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Photos Slider
            roomPhotoUrls.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        height: 180,
                        child: PageView.builder(
                          controller: _roomPageController,
                          itemCount: roomPhotoUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                roomPhotoUrls[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      SmoothPageIndicator(
                        controller: _roomPageController,
                        count: roomPhotoUrls.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 252, 252, 252) : Color.fromARGB(255, 0, 0, 0),
                          dotColor: Colors.grey,
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 10,
                        ),
                      ),
                    ],
                  )
                : Text('No photos available.'),
            SizedBox(height: 16),
            Text(
              'Room/Unit no. ${room['roomNumber']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Price: ₱${room['price']} Monthly', style: TextStyle(fontSize: 16)),
            Text('Capacity: ${room['capacity']}', style: TextStyle(fontSize: 16)),
            Text('Deposit: ${room['deposit']}', style: TextStyle(fontSize: 16)),
            Text('Advance: ${room['advance']}', style: TextStyle(fontSize: 16)),
            Text('Reservation Duration: ${room['reservationDuration']} Days', style: TextStyle(fontSize: 16)),
            Text('Reservation Fee: ₱${room['reservationFee']}', style: TextStyle(fontSize: 16)),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle reserve action
                  },
                  child: Text('Reserve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle rent action
                  },
                  child: Text('Rent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    // Hardcoded URLs for property photos
    final photoUrls = [
      widget.property.photo != null ? 'http://192.168.1.16:3000/${widget.property.photo}' : '',
      widget.property.photo2 != null ? 'http://192.168.1.16:3000/${widget.property.photo2}' : '',
      widget.property.photo3 != null ? 'http://192.168.1.16:3000/${widget.property.photo3}' : '',
    ].where((url) => url.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details', style: TextStyle(
        
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
        ),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Images
                photoUrls.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            height: 250,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: photoUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    photoUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: photoUrls.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 253, 253, 253) : Color.fromARGB(255, 0, 0, 0),
                              dotColor: const Color.fromARGB(255, 148, 146, 146),
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                            ),
                          ),
                        ],
                      )
                    : Text('No photos available.'),
                SizedBox(height: 16),

                // Room/Unit Availability
                Text(
                  'Room/Unit Available',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                rooms.isEmpty
                    ? Text('No rooms available.')
                    : SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final roomPhoto1 = 'http://192.168.1.16:3000/${room['photo1']}';

                            return GestureDetector(
                              onTap: () {
                                showRoomDetailsModal(context, room);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(roomPhoto1, width: 60, fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                // Location and Description
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_pin, color: const Color.fromARGB(255, 252, 3, 3)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.property.address),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(widget.property.description),

                // Amenities
                SizedBox(height: 16),
                Text(
                  'Amenities',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.property.amenities.isNotEmpty
                      ? widget.property.amenities.map((amenity) {
                          return Text('• $amenity');
                        }).toList()
                      : [Text('No amenities listed')],
                )
              ],
            ),
          ),

          // Show Map Location
          if (_showMap && widget.property.location != null)
            Positioned(
              bottom: 16,
              right: 40,
              child: ClipRRect(
                
                borderRadius: BorderRadius.circular(40),
                child: Container(
                 
                  width: 300,
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.property.location!['coordinates'][1],
                        widget.property.location!['coordinates'][0],
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
                              widget.property.location!['coordinates'][1],
                              widget.property.location!['coordinates'][0],
                            ),
                            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () {
          setState(() {
            _showMap = !_showMap;
          });
        },
        child: SvgPicture.asset(_showMap ? 'assets/icons/close.svg' : 'assets/icons/location.svg', color:  const Color.fromARGB(255, 0, 0, 0), width: 36, height: 36,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
