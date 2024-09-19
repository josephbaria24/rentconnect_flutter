import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/models/property.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentcon/pages/profileSection/personalInformation.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';

class Manageproperty extends StatefulWidget {
  final String token;
  final Property property;
  final String userEmail;
  final String userRole;
  final String profileStatus;

  const Manageproperty({
    required this.token,
    required this.property,
    required this.userEmail,
    required this.userRole,
    required this.profileStatus,
    Key? key
  }) : super(key: key);

  @override
  _ManagepropertyState createState() => _ManagepropertyState();
}

class _ManagepropertyState extends State<Manageproperty> {
  List<dynamic> rooms = [];
  bool _showCalendarOverlay = false; // Calendar overlay toggle
  final PageController _pageController = PageController();
  final ThemeController _themeController = Get.find<ThemeController>();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.get(Uri.parse('https://rentconnect-backend-nodejs.onrender.com/rooms/properties/${widget.property.id}/rooms'));

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
    final List<String> roomPhotoUrls = [
      room['photo1'] != null ? '${room['photo1']}' : '',
      room['photo2'] != null ? '${room['photo2']}' : '',
      room['photo3'] != null ? '${room['photo3']}' : '',
    ].where((url) => url.isNotEmpty).toList();

    final PageController _roomPageController = PageController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        const SizedBox(height: 8),
                        SmoothPageIndicator(
                          controller: _roomPageController,
                          count: roomPhotoUrls.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: _themeController.isDarkMode.value
                                ? const Color.fromARGB(255, 252, 252, 252)
                                : const Color.fromARGB(255, 0, 0, 0),
                            dotColor: Colors.grey,
                            dotHeight: 10,
                            dotWidth: 10,
                            spacing: 10,
                          ),
                        ),
                      ],
                    )
                  : const Text('No photos available.'),
              const SizedBox(height: 16),
              Text(
                'Room/Unit no. ${room['roomNumber']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('Price: ₱${room['price']} Monthly', style: const TextStyle(fontSize: 16)),
              Text('Capacity: ${room['capacity']}', style: const TextStyle(fontSize: 16)),
              Text('Deposit: ${room['deposit']}', style: const TextStyle(fontSize: 16)),
              Text('Advance: ${room['advance']}', style: const TextStyle(fontSize: 16)),
              Text('Reservation Duration: ${room['reservationDuration']} Days', style: const TextStyle(fontSize: 16)),
              Text('Reservation Fee: ₱${room['reservationFee']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.userRole == 'landlord' && widget.profileStatus == 'approved') ...[
                    const SizedBox.shrink(),
                  ] 
                  else if (widget.userRole == 'none' && widget.profileStatus == 'none') ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePageChecker(token: widget.token)));
                      },
                      child: const Text('Please set up your profile first!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] 
                  else if (widget.userRole == 'none' && widget.profileStatus == 'pending') ...[
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please wait for your profile to be verified!')),
                        );
                      },
                      child: const Text('Please wait for your profile to be verified!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] 
                  else if (widget.userRole == 'occupant' && widget.profileStatus == 'approved') ...[
                    ElevatedButton(
                      onPressed: () {
                        // Handle reserve action
                      },
                      child: const Text('Reserve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle rent action
                      },
                      child: const Text('Rent'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] 
                  else ...[
                    ElevatedButton(
                      onPressed: null, // Disable button
                      child: const Text('Reserve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: null, // Disable button
                      child: const Text('Rent'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrls = rooms.isNotEmpty
        ? [
            rooms[0]['photo1'] != null ? '${rooms[0]['photo1']}' : '',
            rooms[0]['photo2'] != null ? '${rooms[0]['photo2']}' : '',
            rooms[0]['photo3'] != null ? '${rooms[0]['photo3']}' : '',
          ].where((url) => url.isNotEmpty).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Room', style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),

                // Room Images
                photoUrls.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            height: 200,
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
                              activeDotColor: _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 252, 252, 252)
                                  : const Color.fromARGB(255, 0, 0, 0),
                              dotColor: Colors.grey,
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                            ),
                          ),
                        ],
                      )
                    : const Text('No photos available.'),
                SizedBox(height: 16),

                // Room List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: room['photo1'] != null
                            ? Image.network(
                                room['photo1'],
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text('Room/Unit no. ${room['roomNumber']}'),
                        subtitle: Text('Price: ₱${room['price']} Monthly'),
                        onTap: () => showRoomDetailsModal(context, room),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Calendar overlay
          if (_showCalendarOverlay)
            Positioned(
              top: 100, // Adjust position based on where you want it to appear
              left: 0,
              right: 0,
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(10.0),
                child: TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _showCalendarOverlay = false; // Hide calendar after selection
                    });
                  },
                ),
              ),
            ),

          // Floating button to toggle calendar
          Positioned(
            top: 60,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showCalendarOverlay = !_showCalendarOverlay;
                });
              },
              child: Icon(LineAwesomeIcons.calendar),
            ),
          ),
        ],
      ),
    );
  }
}
