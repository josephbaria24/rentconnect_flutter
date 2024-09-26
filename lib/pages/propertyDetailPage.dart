// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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


class PropertyDetailPage extends StatefulWidget {
  final String token;
  final Property property;
  final String userEmail;
  final String userRole; // Add userRole
  final String profileStatus; // Add profileStatus

    const PropertyDetailPage({
    required this.token,
    required this.property,
    required this.userEmail,
    required this.userRole, // Pass userRole
    required this.profileStatus, // Pass profileStatus
    Key? key
  }) : super(key: key);
  @override
  _PropertyDetailPageState createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  List<dynamic> rooms = [];
  late String email;
  late String userId;
  bool _showMap = false;
  final PageController _pageController = PageController();
  final ThemeController _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // Safely extracting 'email' from the decoded token
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown email';
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.get(Uri.parse('http://192.168.1.13:3000/rooms/properties/${widget.property.id}/rooms'));

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

Future<void> fetchNotifications() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.13:3000/notifications'),
    headers: {
      'Authorization': 'Bearer ${widget.token}', // Use the user's token for authentication
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Assuming data is a list of notifications
    // You can update your UI or store the notifications in the state
    setState(() {
      // Example: notifications = data['notifications'];
    });
  } else {
    print('Failed to fetch notifications');
  }
}



void showRoomDetailsModal(BuildContext context, Map<String, dynamic> room) {
  // Define a list of room photo URLs
  final List<String> roomPhotoUrls = [
    room['photo1'] != null ? '${room['photo1']}' : '',
    room['photo2'] != null ? '${room['photo2']}' : '',
    room['photo3'] != null ? '${room['photo3']}' : '',
  ].where((url) => url.isNotEmpty).toList();

  // Create a PageController for the room photos
  final PageController _roomPageController = PageController();
  final roomStatus = room['roomStatus']; // Get the room status

  // Check if there is a pending request for this occupant
  final bool hasPendingRequest = room['pendingRequest'] ?? false; // Assume a backend response includes 'pendingRequest'

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
            Text('Deposit: ₱${room['deposit']}', style: const TextStyle(fontSize: 16)),
            Text('Advance: ₱${room['advance']}', style: const TextStyle(fontSize: 16)),
            Text('Reservation Duration: ${room['reservationDuration']} Days', style: const TextStyle(fontSize: 16)),
            Text('Reservation Fee: ₱${room['reservationFee']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            if (roomStatus == 'reserved' || roomStatus == 'occupied') ...[
              Text(
                'This room is currently ${roomStatus}.',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ] else if (hasPendingRequest) ...[
              // If occupant already has a pending request, show a message and disable buttons
              Text(
                'You have a pending request. Please wait for it to be approved or rejected before making another request.',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ] else if (widget.userRole == 'occupant' && widget.profileStatus == 'approved') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showReservationConfirmation(context, room, _themeController); // Call confirmation dialog
                      },
                      child:  Text('Reserve',
                      style: TextStyle(
                       color:  _themeController.isDarkMode.value?Colors.black: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showRentConfirmation(context, room, _themeController); // Send rent request
                      },
                      child: Text('Rent', style: TextStyle(
                        color: _themeController.isDarkMode.value?Colors.black: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      );
    },
  );
}

void _sendReserveRequest(BuildContext context, Map<String, dynamic> room) async {
  // Check if there is a pending request before proceeding
  final checkResponse = await http.get(
    Uri.parse('http://192.168.1.13:3000/inquiries/check-pending?userId=$userId&roomId=${room['_id']}'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  if (checkResponse.statusCode == 200) {
    final checkData = jsonDecode(checkResponse.body);
    final bool hasPendingRequest = checkData['hasPendingRequest'] ?? false;

    if (hasPendingRequest) {
      Fluttertoast.showToast(
        msg: 'You already have a pending request for this room.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    } else {
      // Proceed with sending the request
      final inquiryResponse = await http.post(
        Uri.parse('http://192.168.1.13:3000/inquiries/create'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'roomId': '${room['_id']}',
          'userId': userId,
          'requestType': 'reservation',
          'status': 'pending',
        }),
      );

      if (inquiryResponse.statusCode == 201) {
        Fluttertoast.showToast(
          msg: 'Reservation request sent!',
          textColor:_themeController.isDarkMode.value?const Color.fromARGB(255, 0, 0, 0): const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: _themeController.isDarkMode.value?Colors.white: const Color.fromARGB(255, 0, 0, 0),
        );
        // Disable further requests
        setState(() {
          room['pendingRequest'] = true; // Mark room as having a pending request
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send request',
          backgroundColor: Colors.red,
        );
      }
    }
  } else {
    Fluttertoast.showToast(
      msg: 'Failed to check request status',
      backgroundColor: Colors.red,
    );
  }
}


void _sendRentRequest(BuildContext context, Map<String, dynamic> room) async {
  // Check if there is a pending request before proceeding
  final checkResponse = await http.get(
    Uri.parse('http://192.168.1.13:3000/inquiries/check-pending?userId=$userId&roomId=${room['_id']}'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  if (checkResponse.statusCode == 200) {
    final checkData = jsonDecode(checkResponse.body);
    final bool hasPendingRequest = checkData['hasPendingRequest'] ?? false;

    if (hasPendingRequest) {
      Fluttertoast.showToast(
        msg: 'You already have a pending request for this room.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    } else {
      // Proceed with sending the request
      final inquiryResponse = await http.post(
        Uri.parse('http://192.168.1.13:3000/inquiries/create'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'roomId': '${room['_id']}',
          'userId': userId,
          'requestType': 'rent',
          'status': 'pending',
        }),
      );

      if (inquiryResponse.statusCode == 201) {
        Fluttertoast.showToast(
          msg: 'Rent request sent!',
          backgroundColor: _themeController.isDarkMode.value?Colors.white: const Color.fromARGB(255, 0, 0, 0),
        );
        // Disable further requests
        setState(() {
          room['pendingRequest'] = true; // Mark room as having a pending request
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send request',
          backgroundColor: Colors.red,
        );
      }
    }
  } else {
    Fluttertoast.showToast(
      msg: 'Failed to check request status',
      backgroundColor: Colors.red,
    );
  }
}



void _showReservationConfirmation(BuildContext context, Map<String, dynamic> room, ThemeController themeController) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: themeController.isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Confirm Reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room/Unit no. ${room['roomNumber']}'),
              Text('Reservation Fee: ₱${room['reservationFee']}'),
              Text('Reservation Duration: ${room['reservationDuration']} Days'),
              const SizedBox(height: 16),
              const Text(
                'Warning: The reservation fee is non-refundable.',
                style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context); // Cancel button
              },
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _sendReserveRequest(context, room); // Proceed to send rent request
              },
              isDestructiveAction: true,
              child: const Text('Send Reserve Request'),
            ),
          ],
        ),
      );
    },
  );
}



void _showRentConfirmation(BuildContext context, Map<String, dynamic> room, ThemeController themeController) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: themeController.isDarkMode.value ? Brightness.dark : Brightness.light,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Confirm Reservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room/Unit no. ${room['roomNumber']}'),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context); // Cancel button
              },
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _sendRentRequest(context, room); // Proceed to send rent request
              },
              isDestructiveAction: true,
              child: const Text('Send Rent Request'),
            ),
          ],
        ),
      );
    },
  );
}



// Function to allow occupant to cancel reservation request before landlord approves
void _allowCancellation(BuildContext context, Map<String, dynamic> room) {
  setState(() {
    room['reservationStatus'] = 'pending'; // Update status to 'pending'
  });

  ElevatedButton(
    onPressed: () async {
      await _cancelReserveRequest(context, room);
    },
    child: const Text('Cancel Reservation'),
  );
}

// Function to cancel reservation request
Future<void> _cancelReserveRequest(BuildContext context, Map<String, dynamic> room) async {
  // Logic for canceling the reservation request...
  final response = await http.post(
    Uri.parse('http://192.168.1.13:3000/inquiries/cancel'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'roomId': '${room['_id']}',
      'userId': userId,
    }),
  );

  if (response.statusCode == 200) {
    Fluttertoast.showToast(
      msg: 'Reservation canceled',
      backgroundColor: Colors.green,
    );
    setState(() {
      room['reservationStatus'] = null; // Reset reservation status
    });
  } else {
    Fluttertoast.showToast(
      msg: 'Failed to cancel reservation',
      backgroundColor: Colors.red,
    );
  }
}

// Function to send rent request





@override
Widget build(BuildContext context) {
  print('$email');
  print(widget.userEmail);
  print(userId);
  final photoUrls = [
    widget.property.photo != null ? '${widget.property.photo}' : '',
    widget.property.photo2 != null ? '${widget.property.photo2}' : '',
    widget.property.photo3 != null ? '${widget.property.photo3}' : '',
  ].where((url) => url.isNotEmpty).toList();

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Property Details',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_outlined),
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
                            activeDotColor: _themeController.isDarkMode.value
                                ? Color.fromARGB(255, 253, 253, 253)
                                : Color.fromARGB(255, 0, 0, 0),
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
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final roomPhoto1 = room['photo1'];
                        final roomStatus = room['roomStatus']; // Get room status

                        return GestureDetector(
                          onTap: () {
                            showRoomDetailsModal(context, room);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        roomPhoto1,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ],
                                ),
                                if (roomStatus == 'occupied' ||
                                    roomStatus == 'reserved') // Condition to show the banner
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: roomStatus == 'occupied'
                                          ? const Color.fromARGB(255, 253, 1, 64)
                                          : Colors.orange,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                        roomStatus == 'occupied'
                                            ? 'Occupied'
                                            : 'Reserved',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              // Location and Description
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_pin,
                      color: const Color.fromARGB(255, 252, 3, 3)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.property.street),
                        Text(widget.property.barangay),
                        Text(widget.property.city),
                      ],
                    ),
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
                 Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.property.amenities.isNotEmpty
                      ? widget.property.amenities.map<Widget>((amenity) {
                          return Container(
                            width: (MediaQuery.of(context).size.width / 2) - 24, // Adjust size based on screen width
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 77, 78, 90) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
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





// void showRoomDetailsModal(BuildContext context, Map<String, dynamic> room) {
//   // Define a list of room photo URLs
//   final List<String> roomPhotoUrls = [
//     room['photo1'] != null ? '${room['photo1']}' : '',
//     room['photo2'] != null ? '${room['photo2']}' : '',
//     room['photo3'] != null ? '${room['photo3']}' : '',
//   ].where((url) => url.isNotEmpty).toList();

//   // Create a PageController for the room photos
//   final PageController _roomPageController = PageController();
//   final roomStatus = room['roomStatus']; // Get the room status

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Room Photos Slider
//             roomPhotoUrls.isNotEmpty
//                 ? Column(
//                     children: [
//                       Container(
//                         height: 180,
//                         child: PageView.builder(
//                           controller: _roomPageController,
//                           itemCount: roomPhotoUrls.length,
//                           itemBuilder: (context, index) {
//                             return ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 roomPhotoUrls[index],
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       SmoothPageIndicator(
//                         controller: _roomPageController,
//                         count: roomPhotoUrls.length,
//                         effect: ExpandingDotsEffect(
//                           activeDotColor: _themeController.isDarkMode.value
//                               ? const Color.fromARGB(255, 252, 252, 252)
//                               : const Color.fromARGB(255, 0, 0, 0),
//                           dotColor: Colors.grey,
//                           dotHeight: 10,
//                           dotWidth: 10,
//                           spacing: 10,
//                         ),
//                       ),
//                     ],
//                   )
//                 : const Text('No photos available.'),
//             const SizedBox(height: 16),
//             Text(
//               'Room/Unit no. ${room['roomNumber']}',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             Text('Price: ₱${room['price']} Monthly', style: const TextStyle(fontSize: 16)),
//             Text('Capacity: ${room['capacity']}', style: const TextStyle(fontSize: 16)),
//             Text('Deposit: ₱${room['deposit']}', style: const TextStyle(fontSize: 16)),
//             Text('Advance: ₱${room['advance']}', style: const TextStyle(fontSize: 16)),
//             Text('Reservation Duration: ${room['reservationDuration']} Days', style: const TextStyle(fontSize: 16)),
//             Text('Reservation Fee: ₱${room['reservationFee']}', style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 16),

//             // Condition to show/hide buttons based on room status
//             if (roomStatus == 'reserved' || roomStatus == 'occupied') ...[
//               // Show a message if the room is reserved or occupied
//               Text(
//                 'This room is currently ${roomStatus}.',
//                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: null, // Disable button
//                       child: const Text('Reserve'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: null, // Disable button
//                       child: const Text('Rent'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ] else ...[
//               // Case 1: Hide buttons if the user is a landlord and profile is approved
//               if (widget.userRole == 'landlord' && widget.profileStatus == 'approved') ...[
//                 const SizedBox.shrink(),
//               ]
//               // Case 2: Show message to set up profile for 'none' role and 'none' status
//               else if (widget.userRole == 'none' && widget.profileStatus == 'none') ...[
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ProfilePageChecker(token: widget.token),
//                       ),
//                     );
//                   },
//                   child: const Text('Please set up your profile first!'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ]
//               // Case 3: Show message for pending profile verification
//               else if (widget.userRole == 'none' && widget.profileStatus == 'pending') ...[
//                 ElevatedButton(
//                   onPressed: () {
//                     Fluttertoast.showToast(
//                       msg: 'Please wait for your profile to be verified!',
//                       backgroundColor: Colors.orangeAccent,
//                       textColor: Colors.white,
//                     );
//                   },
//                   child: const Text('Please wait for your profile to be verified!'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orangeAccent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ]
//               // Case 4: Show Rent and Reserve buttons for eligible users
//               else if (widget.userRole == 'occupant' && widget.profileStatus == 'approved') ...[
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           // Create inquiry
//                           final inquiryResponse = await http.post(
//                             Uri.parse('http://192.168.1.13:3000/inquiries/create'),
//                             headers: {
//                               'Authorization': 'Bearer ${widget.token}', // Use the user's token for authentication
//                               'Content-Type': 'application/json',
//                             },
//                             body: jsonEncode({
//                               'roomId': '${room['_id']}',
//                               'userId': userId, // Assuming you have a userId field
//                               'status': 'pending',
//                               // Add any other relevant fields here
//                             }),
//                           );

//                           if (inquiryResponse.statusCode == 201) {
//                             final inquiryData = jsonDecode(inquiryResponse.body);
//                             final inquiryId = inquiryData['_id']; // Get the inquiryId

//                             // Send notification for reservation
//                             final notificationResponse = await http.post(
//                               Uri.parse('http://192.168.1.13:3000/notification/create'),
//                               headers: {
//                                 'Authorization': 'Bearer ${widget.token}',
//                                 'Content-Type': 'application/json',
//                               },
//                               body: jsonEncode({
//                                 'userId': widget.property.userId, // Send notification to the landlord
//                                 'message': 'Hi there! Your property has been reserved.',
//                                 'roomId': '${room['_id']}',
//                                 'roomNumber': '${room['roomNumber']}',
//                                 'requesterEmail': '$email',
//                                 'inquiryId': inquiryId, // Include inquiryId
//                               }),
//                             );

//                             if (notificationResponse.statusCode == 201) {
//                               Fluttertoast.showToast(
//                                 fontSize: 15,
//                                 msg: 'Reservation notification sent!',
//                                 backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                                 textColor: const Color.fromARGB(255, 0, 0, 0),
//                               );
//                               Navigator.pop(context); // Dismiss the modal
//                             } else {
//                               Fluttertoast.showToast(
//                                 msg: 'Failed to send notification',
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                               );
//                             }
//                           } else {
//                             Fluttertoast.showToast(
//                               msg: 'Failed to create inquiry',
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                           }
//                         },
//                         child: Text(
//                           'Reserve',
//                           style: TextStyle(
//                             color: _themeController.isDarkMode.value
//                                 ? const Color.fromARGB(255, 0, 0, 0)
//                                 : const Color.fromARGB(255, 0, 0, 0),
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _themeController.isDarkMode.value
//                               ? const Color.fromARGB(255, 235, 254, 114)
//                               : const Color.fromARGB(255, 235, 254, 114),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           // Create inquiry
//                           final inquiryResponse = await http.post(
//                             Uri.parse('http://192.168.1.13:3000/inquiries/create'),
//                             headers: {
//                               'Authorization': 'Bearer ${widget.token}', // Use the user's token for authentication
//                               'Content-Type': 'application/json',
//                             },
//                             body: jsonEncode({
//                               'roomId': '${room['_id']}',
//                               'userId': userId, // Assuming you have a userId field
//                               'status': 'pending',
//                               // Add any other relevant fields here
//                             }),
//                           );

//                           if (inquiryResponse.statusCode == 201) {
//                             final inquiryData = jsonDecode(inquiryResponse.body);
//                             final inquiryId = inquiryData['_id']; // Get the inquiryId

//                             // Send notification for rent request
//                             final notificationResponse = await http.post(
//                               Uri.parse('http://192.168.1.13:3000/notification/create'),
//                               headers: {
//                                 'Authorization': 'Bearer ${widget.token}',
//                                 'Content-Type': 'application/json',
//                               },
//                               body: jsonEncode({
//                                 'userId': widget.property.userId, // Send notification to the landlord
//                                 'message': 'Hi there! Your room property has been requested to rent.',
//                                 'roomId': '${room['_id']}',
//                                 'roomNumber': '${room['roomNumber']}',
//                                 'requesterEmail': '$email',
//                                 'inquiryId': inquiryId, // Include inquiryId
//                               }),
//                             );

//                             if (notificationResponse.statusCode == 201) {
//                               Fluttertoast.showToast(
//                                 fontSize: 15,
//                                 msg: 'Rent request notification sent!',
//                                 backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                                 textColor: const Color.fromARGB(255, 0, 0, 0),
//                               );
//                               Navigator.pop(context); // Dismiss the modal
//                             } else {
//                               Fluttertoast.showToast(
//                                 msg: 'Failed to send request',
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                               );
//                             }
//                           } else {
//                             Fluttertoast.showToast(
//                               msg: 'Failed to create inquiry',
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                             );
//                           }
//                         },
//                         child: Text(
//                           'Rent',
//                           style: TextStyle(
//                             color: _themeController.isDarkMode.value
//                                 ? const Color.fromARGB(255, 255, 255, 255)
//                                 : Color.fromARGB(255, 255, 255, 255),
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _themeController.isDarkMode.value
//                               ? const Color.fromARGB(255, 135, 102, 235)
//                               : const Color.fromARGB(255, 135, 102, 235),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ]
//             ],
//             const SizedBox(height: 16),
//           ],
//         ),
//       );
//     },
//   );
// }
