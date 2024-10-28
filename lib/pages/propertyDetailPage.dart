// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
import 'package:rentcon/pages/components/awesome_snackbar.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/pages/profileSection/personalInformation.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
  bool _loadingRooms = true;
  final PageController _roomPageController = PageController();
  int _currentPageIndex = 0;
 late ToastNotification toastNotification; 
  @override
  void initState() {
    super.initState();
    toastNotification = ToastNotification(context);
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    
    // Safely extracting 'email' from the decoded token
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown email';
    fetchRooms();
     _roomPageController.addListener(() {
      setState(() {
        _currentPageIndex = _roomPageController.page!.round();
      });
    });
     _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }
    @override
  void dispose() {
    _roomPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

Future<void> fetchRooms() async {
  setState(() {
    _loadingRooms = true;  // Start loading
  });

  final response = await http.get(Uri.parse('http://192.168.1.8:3000/rooms/properties/${widget.property.id}/rooms'));

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

  setState(() {
    _loadingRooms = false;  // Stop loading
  });
}

Future<void> fetchNotifications() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.8:3000/notifications'),
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
        padding: const EdgeInsets.fromLTRB(20, 3,20,20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100, // Full width
                height: 7.0, // Thickness of the divider
                decoration: BoxDecoration(
                  color: _themeController.isDarkMode.value? const Color.fromARGB(255, 199, 198, 198): Color.fromARGB(255, 83, 83, 83), // Color of the divider
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius here
                ),
                margin: const EdgeInsets.symmetric(vertical: 10.0), // Space above and below
              ),
            ),

            // Room Photos Slider
            roomPhotoUrls.isNotEmpty
                ? Column(
                    children: [
                      GestureDetector(
                      onTap: () {
                        // Pass the current image to the FullscreenImage widget
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenImage(imageUrl: roomPhotoUrls[_currentPageIndex]),
                          ),
                        );
                      },
                      child: Hero(
                        // Pass the current image to the Hero tag
                        tag: roomPhotoUrls[_currentPageIndex],
                        child: Container(
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
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index; // Update current index on page change
                              });}
                          ),
                        ),
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
            Text('Reservation Fee: ₱${room['reservationFee']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            if (roomStatus == 'reserved' || roomStatus == 'occupied') ...[
              Text(
                'This room is currently ${roomStatus}.',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ] else if (hasPendingRequest) ...[
              Text(
                'You have a pending request. Please wait for it to be approved or rejected before making another request.',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ] else if (widget.userRole == 'occupant' && widget.profileStatus == 'approved') ...[
              // Reservation Duration Picker
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showDurationPicker(context, room, _themeController); // Show duration picker
                      },
                      child: Text('Reserve',
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.black
                              : Colors.white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showRentConfirmation(context, room, _themeController); 
                      },
                      child: Text('Rent', 
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.black
                              : Colors.white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
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

void _sendRentRequest(BuildContext context, Map<String, dynamic> room, DateTime? proposedStartDate, String? customTerms) async {
  // Check if the user can inquire and if there is a pending request before proceeding
  final checkResponse = await http.get(
    Uri.parse('http://192.168.1.8:3000/inquiries/check-pending?userId=$userId'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  print('Check Pending Response: ${checkResponse.statusCode} - ${checkResponse.body}'); // Debugging line

  if (checkResponse.statusCode == 200) {
    final checkData = jsonDecode(checkResponse.body);
    final bool hasPendingRequest = checkData['canInquire'] ?? false;

    if (hasPendingRequest) {
      toastNotification.warn('You cannot inquire more than one room.');
    } else {
      // Check if the user can inquire about the room
      final inquireCheckResponse = await http.get(
        Uri.parse('http://192.168.1.8:3000/inquiries/check-pending?userId=$userId'), // New endpoint for inquiry check
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (inquireCheckResponse.statusCode == 200) {
        final inquireCheckData = jsonDecode(inquireCheckResponse.body);
        final bool canInquire = inquireCheckData['canInquire'] ?? false;

        if (!canInquire) {
          toastNotification.warn('You cannot inquire more than one room.');
          return; // Exit the function if the user cannot inquire
        }

        // Proceed with sending the request
        final inquiryResponse = await http.post(
          Uri.parse('http://192.168.1.8:3000/inquiries/create'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'roomId': '${room['_id']}',
            'userId': userId,
            'requestType': 'rent',
            'status': 'pending',
            'proposedStartDate': proposedStartDate?.toIso8601String(), // Send start date
            'customTerms': customTerms, // Send custom terms
          }),
        );

        print('Inquiry Response: ${inquiryResponse.statusCode} - ${inquiryResponse.body}'); // Debugging line

        if (inquiryResponse.statusCode == 201) {
          toastNotification.success('Rent request sent!');

          // Disable further requests
          setState(() {
            room['pendingRequest'] = true; // Mark room as having a pending request
          });

          // Fetch landlord's email using the provided endpoint
          final landlordEmailResponse = await http.get(
            Uri.parse('http://192.168.1.8:3000/rooms/landlord-email/${room['_id']}'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
            },
          );

          if (landlordEmailResponse.statusCode == 200) {
            final landlordData = jsonDecode(landlordEmailResponse.body);
            final String landlordEmail = landlordData['landlordEmail']; // Adjust according to the response structure

            // Now send notification to landlord
            final notificationBody = {
              'userId': "${room['ownerId']}",
              'message': 'You have a new rent inquiry for room ${room['roomNumber']}.',
              'roomId': room['_id'],
              'roomNumber': room['roomNumber'],
              'requesterEmail': landlordEmail, // The email of the landlord
              'inquiryId': jsonDecode(inquiryResponse.body)['_id'],
            };

            // Send notification request
            final notificationResponse = await http.post(
              Uri.parse('http://192.168.1.8:3000/notification/create'),
              headers: {
                'Authorization': 'Bearer ${widget.token}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(notificationBody),
            );

            // Debugging: Print notification response status and body
            print('Notification Request Status Code: ${notificationResponse.statusCode}');
            print('Notification Request Response Body: ${notificationResponse.body}');

            if (notificationResponse.statusCode == 201) {
              print('Notification sent successfully.');
            } else {
              Fluttertoast.showToast(
                msg: 'Failed to send notification to landlord.',
                backgroundColor: Colors.red,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: 'Failed to fetch landlord email.',
              backgroundColor: Colors.red,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to send request',
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to check inquire status',
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



void _showRentConfirmation(BuildContext context, Map<String, dynamic> room, ThemeController themeController) {
  DateTime? _selectedStartDate;
  TextEditingController _termsController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.2), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm Rent Request',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'geistsans'),
                  ),
                  const SizedBox(height: 5),
                  Text('Room/Unit no. ${room['roomNumber']}', style: TextStyle(fontFamily: 'geistsans', color: const Color.fromARGB(255, 105, 105, 105))),
                  const SizedBox(height: 5),

                  // Date Picker
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedStartDate = picked; // Update the state with the selected date
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            _selectedStartDate != null 
                              ? 'Start Date: ${_selectedStartDate!.toLocal().toString().split(' ')[0]}' 
                              : 'Select Start Date',
                            style: TextStyle(
                              color: _themeController.isDarkMode.value
                                ? const Color.fromARGB(255, 7, 138, 245)
                                : const Color.fromARGB(255, 55, 58, 240),
                              fontFamily: 'geistsans'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Custom Terms Input
                  TextField(
                    controller: _termsController,
                    decoration: const InputDecoration(
                      hintText: 'Optional: Add custom terms or message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShadButton.outline(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 6, 1, 36)
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(), // Cancel button
                      ),
                      ShadButton(
                        backgroundColor: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 5, 16, 44),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 3, 1, 36) : const Color.fromARGB(255, 255, 255, 255)
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (_selectedStartDate == null) {
                            toastNotification.warn('Please select start date!');
                          } else {
                            Navigator.pop(context);
                            _sendRentRequest(context, room, _selectedStartDate, _termsController.text); // Proceed to send rent request
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}


int selectedReservationDuration = 1;
void _showDurationPicker(BuildContext context, Map<String, dynamic> room, ThemeController _themeController) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('Select Reservation Duration'),
        actions: List<CupertinoActionSheetAction>.generate(30, (index) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedReservationDuration = index + 1; // Update duration
              });

              Navigator.pop(context); // Close the picker

              // Show the reservation confirmation dialog
              _showReservationConfirmation(context, room, _themeController, selectedReservationDuration);
            },
            child: Text('${index + 1} Days'),
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context); // Close the picker
          },
          child: const Text('Cancel'),
        ),
      );
    },
  );
}






void _sendReserveRequest(BuildContext context, Map<String, dynamic> room, int selectedReservationDuration) async {
  // Create an instance of ToastNotification

  // Check if the user can inquire before proceeding
  final checkResponse = await http.get(
    Uri.parse('http://192.168.1.8:3000/inquiries/check-pending?userId=$userId'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  if (checkResponse.statusCode == 200) {
    final checkData = jsonDecode(checkResponse.body);
    final bool canInquire = checkData['canInquire'] ?? true; // Updated field for checking if inquiry can be made

    if (!canInquire) {
      toastNotification.error('You already have a pending or approved request for this room');
      return; // Exit early if the user can't inquire
    }

    // Prepare the request body for inquiry
    final requestBody = {
      'roomId': '${room['_id']}',
      'userId': userId,
      'requestType': 'reservation',
      'status': 'pending',
      'reservationDuration': selectedReservationDuration,
    };

    // Debugging: Print request payload
    print('Inquiry Creation Request Payload: $requestBody');

    // Proceed with sending the reservation request
    final inquiryResponse = await http.post(
      Uri.parse('http://192.168.1.8:3000/inquiries/create'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // Debugging: Print response status and body
    print('Inquiry Creation Request Status Code: ${inquiryResponse.statusCode}');
    print('Inquiry Creation Request Response Body: ${inquiryResponse.body}');

    if (inquiryResponse.statusCode == 201) {
      toastNotification.success('Reservation request sent!');

      // Disable further requests
      setState(() {
        room['pendingRequest'] = true; // Mark room as having a pending request
      });

      // Fetch landlord's email using the provided endpoint
      final landlordEmailResponse = await http.get(
        Uri.parse('http://192.168.1.8:3000/rooms/landlord-email/${room['_id']}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (landlordEmailResponse.statusCode == 200) {
        final landlordData = jsonDecode(landlordEmailResponse.body);
        final String landlordEmail = landlordData['landlordEmail']; // Adjust according to the response structure

        // Now send notification to landlord
        final notificationBody = {
          'userId': room['ownerId'],
          'message': 'You have a new reservation inquiry for room ${room['roomNumber']}.',
          'roomId': room['_id'],
          'roomNumber': room['roomNumber'],
          'requesterEmail': landlordEmail, // The email of the landlord
          'inquiryId': jsonDecode(inquiryResponse.body)['_id'],
        };

        // Send notification request
        final notificationResponse = await http.post(
          Uri.parse('http://192.168.1.8:3000/notification/create'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(notificationBody),
        );

        // Debugging: Print notification response status and body
        print('Notification Request Status Code: ${notificationResponse.statusCode}');
        print('Notification Request Response Body: ${notificationResponse.body}');

        if (notificationResponse.statusCode == 201) {
          print('Notification sent successfully.');
        } else {
          toastNotification.error('Failed to send notification to landlord.');
        }
      } else {
        toastNotification.error('Failed to fetch landlord email.');
      }
    } else {
      toastNotification.error('Failed to send request');
    }
  } else {
    toastNotification.error('Failed to check request status');
  }
}


void _showReservationConfirmation(BuildContext context, Map<String, dynamic> room, ThemeController themeController, int selectedReservationDuration) {
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
              Text('Reservation Duration: $selectedReservationDuration Days'), // Show selected duration here
              const SizedBox(height: 16),
              const Text(
                'Warning: The reservation fee might be non-refundable depends on the landlord.',
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
                _sendReserveRequest(context, room, selectedReservationDuration); // Pass selected duration to request
              },
              isDestructiveAction: true,
              child: const Text('Send Reserve Request', style: TextStyle(color: Colors.blue),),
            ),
          ],
        ),
      );
    },
  );
}






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
final Map<String, Color> amenityColors = {
  'WiFi': Colors.blue, // Set your desired color for WiFi
  'Parking': Colors.green, // Set your desired color for Parking
  'Pool': Colors.blueAccent, // Set your desired color for Pool
  'Study lounge': Colors.orange, // Set your desired color for Study lounge
  'Gym': Colors.red, // Set your desired color for Gym
  'Air Conditioning': Colors.lightBlue, // Set your desired color for Air Conditioning
  'Laundry': Colors.purple, // Set your desired color for Laundry
  'Pets Allowed': Colors.brown, // Set your desired color for Pets Allowed
  'Elevator': Colors.grey, // Set your desired color for Elevator
  'CCTV': Colors.yellow, // Set your desired color for CCTV
  // Add more amenities and their respective colors here
};




@override
Widget build(BuildContext context) {
  print(widget.property.amenities); // Ensure amenities data is being passed correctly

  print('$email');
  print(widget.userEmail);
  print(userId);
  
  final photoUrls = [
    widget.property.photo != null ? '${widget.property.photo}' : '',
    widget.property.photo2 != null ? '${widget.property.photo2}' : '',
    widget.property.photo3 != null ? '${widget.property.photo3}' : '',
  ].where((url) => url.isNotEmpty).toList();

  return Scaffold(
    backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34): Colors.white,
    appBar: AppBar(
      backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34): Colors.white,
      scrolledUnderElevation: 0.0,
      title: Text(
        'Property Details',
        style: TextStyle(
          fontFamily: 'GeistSans',
          fontWeight: FontWeight.w800,
        ),
      ),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                      FullscreenImage(imageUrl: photoUrls[_currentPageIndex])));
                    },
                    child: Hero(
                      tag: photoUrls,
                      child: Container(
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
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageIndex = index; // Update current index on page change
                            });
                          },
                        ),
                      ),
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
              Skeletonizer(
                enabled: _loadingRooms, // Use the loading state
                child: rooms.isEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _loadingRooms ? 4 : 0, // Show 4 skeleton items when loading
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300], // Skeleton box color
                            ),
                          );
                        },
                      )
                    : rooms.isEmpty
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
                              final roomStatus = room['roomStatus'];

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
                                      if (roomStatus == 'occupied' || roomStatus == 'reserved')
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            color: roomStatus == 'occupied'
                                                ? const Color.fromARGB(255, 253, 1, 64)
                                                : Colors.orange,
                                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            child: Text(
                                              roomStatus == 'occupied' ? 'Occupied' : 'Reserved',
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
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_pin, color: const Color.fromARGB(255, 252, 3, 3)),
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
                          color: _themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 77, 78, 90)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              amenityIcons[amenity] ?? Icons.check_circle, // Use the appropriate icon, fallback to check_circle
                              color: amenityColors[amenity] ?? Colors.green, // Use the custom color for the amenity
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
      child: SvgPicture.asset(
        _showMap ? 'assets/icons/close.svg' : 'assets/icons/location.svg',
        color: const Color.fromARGB(255, 0, 0, 0),
        width: 36,
        height: 36,
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

}





