// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/AddingRoom.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/landlords/manageProperty.dart';
import 'package:rentcon/pages/landlords/roomCreation.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CurrentListingPage extends StatefulWidget {
  final String token;

  const CurrentListingPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CurrentListingPage> createState() => _CurrentListingPageState();
}

class _CurrentListingPageState extends State<CurrentListingPage> {
  late String userId;
  late String email;
  List<dynamic>? items;
  String? responseBody;
  DateTime? _selectedDueDate;
  Map<String, List<dynamic>> propertyRooms = {};
  Map<String, List<dynamic>> propertyInquiries = {};
  Map<String, dynamic> userProfiles = {};
  final ThemeController _themeController = Get.find<ThemeController>();
  bool _loading = true; // Added state for loading
  String _sortOption = 'None';
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id']?.toString() ?? 'unknown id';
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    getPropertyList(userId);
    _loading = true;
  }

  Future<void> getPropertyList(String userId) async {
    try {
      setState(() {
        _loading = true; // Set loading to true when starting fetch
      });

      var regBody = {"userId": userId};
      var response = await http.post(
        Uri.parse(getProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> properties = jsonResponse['success'] ?? [];
        setState(() {
          items = properties;
          _loading = false; // Set loading to false after fetch
        });

        for (var property in properties) {
          String propertyId = property['_id'];
          fetchRooms(propertyId);
          // Fetch inquiries for each property
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
        setState(() {
          _loading = false; // Set loading to false on error
        });
      }
    } catch (e) {
      print("Error fetching property list: $e");
      setState(() {
        _loading = false; // Set loading to false on error
      });
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.13:3000/user/$userId'));
      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        setState(() {
          userProfiles[userId] =
              user['profile']; // Store profile data by userId
        });
      } else {
        print(
            "Error fetching user profile for $userId: ${response.statusCode}");
      }
    } catch (error) {
      print('Error fetching user profile for $userId: $error');
    }
  }

  Future<void> fetchRoomInquiries(String roomId) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.13:3000/inquiries/rooms/$roomId'));
      if (response.statusCode == 200) {
        final inquiries = json.decode(response.body);
        setState(() {
          propertyInquiries[roomId] = inquiries; // Store inquiries by room ID
        });

        // Fetch user profiles for each inquiry
        for (var inquiry in inquiries) {
          String userId = inquiry['userId'];
          await fetchUserProfile(userId); // Fetch the user profile
        }
      } else {
        print(
            "Error fetching inquiries for room $roomId: ${response.statusCode}");
      }
    } catch (error) {
      print('Error fetching inquiries for room $roomId: $error');
    }
  }

  Future<void> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.13:3000/rooms/properties/$propertyId/rooms'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetch rooms response data: $data');

        if (data['status']) {
          setState(() {
            propertyRooms[propertyId] = data['rooms'] ?? [];
          });

          // Fetch inquiries and user profiles for each room
          for (var room in data['rooms']) {
            String roomId = room['_id'];

            // Fetch inquiries for the room
            await fetchRoomInquiries(roomId);

            // Fetch profiles for the occupants (users and non-users)
            List<dynamic> occupantUsers = room['occupantUsers'] ?? [];
            for (var occupantUserId in occupantUsers) {
              await fetchUserProfile(occupantUserId); // Fetch profile by userId
            }
          }
        } else {
          print(
              'Failed to fetch rooms for property $propertyId. Status: ${data['status']}');
        }
      } else {
        print(
            'Failed to load rooms for property $propertyId. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rooms for property $propertyId: $e');
    }
  }
//  Future<void> fetchRooms(String propertyId) async {
//     try {
//       final response = await http.get(Uri.parse('http://192.168.1.13:3000/rooms/properties/$propertyId/rooms'));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Fetch rooms response data: $data');

//         if (data['status']) {
//           setState(() {
//             propertyRooms[propertyId] = data['rooms'] ?? [];
//           });

//           // Fetch inquiries for each room in the fetched property
//           for (var room in data['rooms']) {
//             String roomId = room['_id'];
//             await fetchRoomInquiries(roomId); // Fetch inquiries for the room
//           }
//         } else {
//           print('Failed to fetch rooms for property $propertyId. Status: ${data['status']}');
//         }
//       } else {
//         print('Failed to load rooms for property $propertyId. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching rooms for property $propertyId: $e');
//     }
//   }

  Future<void> deleteProperty(String propertyId) async {
    try {
      var response = await http.delete(
        Uri.parse('http://192.168.1.13:3000/deleteProperty/$propertyId'),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        await getPropertyList(userId); // Refresh property list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully')),
        );
      } else {
        print("Error deleting property: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void showPropertyDetailPage(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Manageproperty(
          token: widget.token,
          property: property,
          userEmail: email,
          userRole: 'none',
          profileStatus: 'none',
        ),
      ),
    );
  }

  Color _getRoomStatusColor(String? status) {
    switch (status) {
      case 'available':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 0, 214, 89)
            : const Color.fromARGB(100, 0, 255, 106);
      case 'occupied':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 0, 132, 255)
            : const Color.fromARGB(100, 0, 217, 255);
      case 'reserved':
        return _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 238, 194, 0)
            : const Color.fromARGB(100, 255, 230, 0);
      default:
        return _themeController.isDarkMode.value
            ? Colors.white70
            : Colors.black54;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      items = null;
      propertyRooms.clear();
      _loading = true; // Set loading to true when refreshing
    });

    await getPropertyList(userId);
  }

  void showRoomDetailPopover(BuildContext context, dynamic room) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        int selectedDay = room['dueDate'] != null
            ? DateTime.parse(room['dueDate']).day
            : 5; // Default to the 5th day
        DateTime? _selectedDueDate;

        void calculateDueDate() {
          DateTime today = DateTime.now();
          _selectedDueDate = DateTime(today.year, today.month, selectedDay);

          // If the selected day has already passed this month, move to next month
          if (today.day > selectedDay) {
            _selectedDueDate =
                DateTime(today.year, today.month + 1, selectedDay);
          }
        }

        calculateDueDate();

        List<String> photos = [
          (room['photo1'] as String?)?.toString() ?? '',
          (room['photo2'] as String?)?.toString() ?? '',
          (room['photo3'] as String?)?.toString() ?? '',
        ].where((photo) => photo.isNotEmpty).toList();

        PageController pageController = PageController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 150,
                        child: photos.isNotEmpty
                            ? PageView.builder(
                                controller: pageController,
                                itemCount: photos.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            'assets/images/placeholder.webp',
                                        image: photos[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(child: Text("No photos available")),
                      ),
                      if (photos.isNotEmpty)
                        Center(
                          child: SmoothPageIndicator(
                            controller: pageController,
                            count: photos.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              dotColor: Colors.grey,
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(
                        'Room No. ${room['roomNumber']?.toString() ?? 'Unknown'}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'GeistSans'),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Capacity: ${room['capacity']?.toString() ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, fontFamily: 'GeistSans'),
                      ),
                      Text(
                        'Occupants: ${room['occupantUsers']?.map((userId) {
                              var profile = userProfiles[userId];
                              return profile != null
                                  ? '${profile['firstName']} ${profile['lastName']}'
                                  : 'N/A';
                            }).join(', ') ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, fontFamily: 'GeistSans'),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 20),
                          SizedBox(width: 5),
                          DropdownButton<int>(
                            value: selectedDay,
                            items: List.generate(31, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('Day ${index + 1}'),
                              );
                            }),
                            onChanged: (int? newDay) {
                              setState(() {
                                selectedDay = newDay!;
                                calculateDueDate();
                              });
                            },
                          ),
                          Text(
                            'Next Due Date: ${DateFormat.yMd().format(_selectedDueDate!)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 3, 13, 22)),
                          ),
                          SizedBox(width: 2),
                          ShadButton(
                            height: 23,
                            width: 22,
                            onPressed: () {
                              updateRoomDueDate(room['_id'], _selectedDueDate!);
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.check,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ShadButton(
                        height: 33,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> updateRoomDueDate(String roomId, DateTime dueDate) async {
    try {
      final response = await http.patch(
        Uri.parse(
            'http://192.168.1.13:3000/rooms/updateRoom/$roomId'), // Ensure the URL is correct
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'dueDate':
              dueDate.toIso8601String(), // Send dueDate in ISO8601 format
        }),
      );

      if (response.statusCode == 200) {
        // Successfully updated the due date
        print('Due date updated successfully');
      } else {
        // Handle error
        print('Failed to update due date');
      }
    } catch (e) {
      // Handle exception
      print('Error updating due date: $e');
    }
  }

  Future<void> updateInquiryStatus(
      String inquiryId, String newStatus, String token) async {
    final url = Uri.parse(
        'http://192.168.1.13:3000/inquiries/update/$inquiryId'); // Match your backend route

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Send authorization token if needed
        },
        body: jsonEncode(
            {'status': newStatus}), // Pass the new status in the request body
      );

      if (response.statusCode == 200) {
        print('Inquiry status updated successfully to $newStatus');
        // Optionally, you can show a success message or refresh the list
      } else {
        print('Failed to update inquiry status: ${response.body}');
        // Optionally, show an error message in the UI
      }
    } catch (error) {
      print('Error updating inquiry status: $error');
      // Optionally, show an error message in the UI
    }
  }

  void _sortProperties(String option) {
    setState(() {
      _sortOption = option;
      if (option == 'Available Rooms') {
        items?.sort((a, b) {
          final aRooms = propertyRooms[a['_id']] ?? [];
          final bRooms = propertyRooms[b['_id']] ?? [];
          final aAvailable =
              aRooms.any((room) => room['roomStatus'] == 'available');
          final bAvailable =
              bRooms.any((room) => room['roomStatus'] == 'available');
          return (bAvailable ? 1 : 0) - (aAvailable ? 1 : 0);
        });
      } else {
        // You can add other sorting options here if needed
      }
    });
  }

// Approve and update the room
  Future<void> updateInquiryStatusAndRoom(
      Map<String, dynamic> inquiry,
      String inquiryId,
      String status,
      String roomId,
      String userId,
      String token) async {
    // Construct the request body
    var requestBody = {
      'status': status,
      'requestType': inquiry['requestType'], // Now inquiry is defined
      'roomId': roomId,
      'userId': userId
    };

    final response = await http.patch(
      Uri.parse('http://192.168.1.13:3000/inquiries/update/$inquiryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody), // Encode the body correctly
    );

    if (response.statusCode == 200) {
      // Handle successful update
      print('Inquiry and room updated successfully');
    } else {
      throw Exception('Failed to update inquiry: ${response.body}');
    }
  }

// Reject and delete the inquiry
  Future<void> rejectAndDeleteInquiry(String inquiryId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.13:3000/inquiries/delete/$inquiryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        print('Inquiry rejected and deleted.');
      } else {
        print('Failed to delete inquiry: ${response.statusCode}');
      }
    } catch (error) {
      print('Error rejecting and deleting inquiry: $error');
    }
  }

  void _markPropertiesOrRooms() {
    // Implement your logic to mark properties or rooms here
    // You can display a dialog to confirm the action if necessary
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mark Property/Room'),
          content:
              Text('Would you like to mark the selected property or room?'),
          actions: [
            TextButton(
              onPressed: () {
                // Add your marking logic here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _deletePropertiesOrRooms() {
    // Implement your logic to delete properties or rooms here
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Property/Room'),
          content: Text(
              'Are you sure you want to delete the selected property or room?'),
          actions: [
            TextButton(
              onPressed: () {
                // Add your deletion logic here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        title: Text(
          'Listed properties',
          style: TextStyle(
            color:
                _themeController.isDarkMode.value ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _themeController.isDarkMode.value
                ? Colors.white
                : const Color.fromARGB(255, 94, 94, 94),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert, // Changed icon for more options
              color: _themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
            onSelected: (value) {
              if (value == 'mark') {
                // Handle mark action
                _markPropertiesOrRooms();
              } else if (value == 'delete') {
                // Handle delete action
                _deletePropertiesOrRooms();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'mark', child: Text('Mark Property/Room')),
              PopupMenuItem(
                  value: 'delete', child: Text('Delete Property/Room')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Skeletonizer(
          enableSwitchAnimation: true,
          enabled: _loading, // Enable skeleton loader based on _loading state
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _themeController.isDarkMode.value
                        ? Color.fromARGB(255, 28, 29, 34)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: items == null
                        ? Center(child: GlobalLoadingIndicator())
                        : ListView.builder(
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              final item = items![index];
                              final propertyId = item['_id'];
                              final rooms = propertyRooms[propertyId] ?? [];
                              final photoUrl = item['photo'] != null &&
                                      item['photo'].isNotEmpty
                                  ? (item['photo'].startsWith('http')
                                      ? item['photo']
                                      : '$url${item['photo']}')
                                  : 'https://via.placeholder.com/150'; // Fallback URL

                              return Card(
                                color: _themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 36, 38, 43)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                elevation: 5.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['typeOfProperty'] ??
                                                        'Unknown Property Type',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: _themeController
                                                              .isDarkMode.value
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: _themeController
                                                                .isDarkMode
                                                                .value
                                                            ? const Color
                                                                .fromARGB(
                                                                255, 255, 0, 0)
                                                            : const Color
                                                                .fromARGB(
                                                                255, 255, 0, 0),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${item['street'] ?? 'No Address'}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: _themeController
                                                                  .isDarkMode
                                                                  .value
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    item['description'] ??
                                                        'No Description',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: _themeController
                                                              .isDarkMode.value
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                photoUrl,
                                                width: 110,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Room/Unit Available',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color:  _themeController.isDarkMode.value?  Colors.white: Colors.black
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Addingroom(token: widget.token, propertyId: propertyId)));
                                                      },
                                                      child: Icon(Icons.add, 
                                                      color: _themeController.isDarkMode.value?  Colors.black: Colors.white,),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        rooms.isEmpty
                                            ? Text('No rooms available.')
                                            : Column(
                                                children: rooms.map((room) {
                                                  final roomPhoto1 =
                                                      '${room['photo1']}';
                                                  final roomId = room[
                                                      '_id']; // Get room ID for inquiries
                                                  final inquiries =
                                                      propertyInquiries[
                                                              roomId] ??
                                                          []; // Fetch inquiries for this room

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        //border: Border.all(width: 0.4),
                                                        color: _themeController
                                                                .isDarkMode
                                                                .value
                                                            ? const Color
                                                                .fromARGB(
                                                                174, 68, 67, 82)
                                                            : const Color
                                                                .fromARGB(170,
                                                                241, 241, 241),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: InkWell(
                                                          onTap: () =>
                                                              showRoomDetailPopover(
                                                                  context,
                                                                  room),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      child: Image.network(
                                                                          roomPhoto1,
                                                                          width:
                                                                              80,
                                                                          height:
                                                                              60,
                                                                          fit: BoxFit
                                                                              .cover),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            12),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Room No. ${room['roomNumber']?.toString() ?? 'Unknown Room Number'}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 4),
                                                                          Text(
                                                                            'Price: ₱${room['price']?.toString() ?? 'N/A'}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Capacity: ${room['capacity']?.toString() ?? 'N/A'}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Poppins',
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                'Room Status: ',
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Poppins',
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                                decoration: BoxDecoration(
                                                                                  color: _getRoomStatusColor(room['roomStatus']),
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                ),
                                                                                child: Text(
                                                                                  '${room['roomStatus']?.toString().toUpperCase() ?? 'N/A'}',
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Poppins',
                                                                                    fontWeight: FontWeight.w800,
                                                                                    fontSize: 12,
                                                                                    color: const Color.fromARGB(255, 5, 5, 5),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                // Only show inquiries if the room status is 'available'
                                                                if (room[
                                                                        'roomStatus'] ==
                                                                    'available') ...[
                                                                  Text(
                                                                    'Inquiries',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                      color: _themeController
                                                                              .isDarkMode
                                                                              .value
                                                                          ? const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255)
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8),
                                                                  inquiries
                                                                          .isEmpty
                                                                      ? Text(
                                                                          'No inquiries yet.')
                                                                      : Column(
                                                                          children:
                                                                              inquiries.map((inquiry) {
                                                                            String
                                                                                userId =
                                                                                inquiry['userId'];
                                                                            var profile =
                                                                                userProfiles[userId]; // Get the user profile

                                                                            // Default to "Unknown User" if profile is not available
                                                                            String userName = (profile != null)
                                                                                ? '${profile['firstName']} ${profile['lastName']}'
                                                                                : 'Unknown User';

                                                                            return Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: DecoratedBox(
                                                                                decoration: BoxDecoration(
                                                                                  color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(59, 187, 187, 187),
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        'Inquiry from $userName', // Display user name
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 14,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 4),
                                                                                      Text(
                                                                                        'Request Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inquiry['requestDate']))}',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 4),
                                                                                      Text(
                                                                                        'Request Type: ${inquiry['requestType']?.toString().toUpperCase() ?? 'N/A'}',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(height: 8),

                                                                                      // Approve and Reject Buttons
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          // Approve Button
                                                                                          ElevatedButton(
                                                                                            style: ElevatedButton.styleFrom(
                                                                                              backgroundColor: const Color.fromARGB(255, 0, 255, 106),
                                                                                              shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                              ),
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              bool? confirm = await showCupertinoDialog(
                                                                                                context: context,
                                                                                                builder: (BuildContext context) {
                                                                                                  return CupertinoAlertDialog(
                                                                                                    title: Text("Approve Inquiry"),
                                                                                                    content: Text("Are you sure you want to approve this inquiry?"),
                                                                                                    actions: <Widget>[
                                                                                                      CupertinoDialogAction(
                                                                                                        child: Text("Cancel"),
                                                                                                        onPressed: () {
                                                                                                          Navigator.of(context).pop(false);
                                                                                                        },
                                                                                                      ),
                                                                                                      CupertinoDialogAction(
                                                                                                        isDestructiveAction: true,
                                                                                                        child: Text("Approve"),
                                                                                                        onPressed: () {
                                                                                                          Navigator.of(context).pop(true);
                                                                                                        },
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                },
                                                                                              );

                                                                                              if (confirm == true) {
                                                                                                // Call the function to approve inquiry and update room
                                                                                                try {
                                                                                                  await updateInquiryStatusAndRoom(inquiry, inquiry['_id'], 'approved', roomId, userId, widget.token);
                                                                                                  setState(() {
                                                                                                    responseBody = jsonEncode(responseBody); // Use responseBody to store the JSON data
                                                                                                  });
                                                                                                } catch (error) {
                                                                                                  print('Error: $error');
                                                                                                }
                                                                                              }
                                                                                            },
                                                                                            child: Text(
                                                                                              'Approve',
                                                                                              style: TextStyle(
                                                                                                color: Colors.black,
                                                                                              ),
                                                                                            ),
                                                                                          ),

                                                                                          const SizedBox(width: 8),

                                                                                          // Reject Button
                                                                                          ElevatedButton(
                                                                                            style: ElevatedButton.styleFrom(
                                                                                              backgroundColor: const Color.fromARGB(255, 255, 3, 78), // Button color for Reject
                                                                                              shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                              ),
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              bool? confirm = await showCupertinoDialog(
                                                                                                context: context,
                                                                                                builder: (BuildContext context) {
                                                                                                  return CupertinoAlertDialog(
                                                                                                    title: Text("Reject Inquiry"),
                                                                                                    content: Text("Are you sure you want to reject this inquiry?"),
                                                                                                    actions: <Widget>[
                                                                                                      CupertinoDialogAction(
                                                                                                        child: Text("Cancel"),
                                                                                                        onPressed: () {
                                                                                                          Navigator.of(context).pop(false); // Return false
                                                                                                        },
                                                                                                      ),
                                                                                                      CupertinoDialogAction(
                                                                                                        isDestructiveAction: true,
                                                                                                        child: Text("Reject"),
                                                                                                        onPressed: () {
                                                                                                          Navigator.of(context).pop(true); // Return true
                                                                                                        },
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                },
                                                                                              );

                                                                                              if (confirm == true) {
                                                                                                // Call API to reject inquiry and delete it
                                                                                                print('Reject button clicked for inquiry by $userName');
                                                                                                if (inquiry['_id'] != null && widget.token != null) {
                                                                                                  await rejectAndDeleteInquiry(inquiry['_id'], widget.token);
                                                                                                } else {
                                                                                                  print('Error: Inquiry ID or token is null');
                                                                                                }
                                                                                              }
                                                                                            },
                                                                                            child: Text(
                                                                                              'Reject',
                                                                                              style: TextStyle(
                                                                                                color: Colors.black,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                        ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addlisting(token: widget.token),
            ),
          );
        },
        child: ImageIcon(AssetImage('assets/icons/add.png')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
