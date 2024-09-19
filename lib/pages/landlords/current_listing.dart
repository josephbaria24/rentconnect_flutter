import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/landlords/manageProperty.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
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
  DateTime? _selectedDueDate;
  Map<String, List<dynamic>> propertyRooms = {};
  final ThemeController _themeController = Get.find<ThemeController>();
  bool _loading = true; // Added state for loading

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

  Future<void> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.6:3000/rooms/properties/$propertyId/rooms'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetch rooms response data: $data');

        if (data['status']) {
          setState(() {
            propertyRooms[propertyId] = data['rooms'] ?? [];
          });
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

  Future<void> deleteProperty(String propertyId) async {
    try {
      var response = await http.delete(
        Uri.parse('http://192.168.1.6:3000/deleteProperty/$propertyId'),
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
        return _themeController.isDarkMode.value? const Color.fromARGB(255, 0, 214, 89):const Color.fromARGB(100, 0, 255, 106);
      case 'occupied':
        return _themeController.isDarkMode.value? const Color.fromARGB(255, 0, 192, 226):const Color.fromARGB(100, 0, 217, 255);
      case 'reserved':
        return _themeController.isDarkMode.value? const Color.fromARGB(255, 238, 194, 0): const Color.fromARGB(100, 255, 230, 0);
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


void showRoomDetailModal(BuildContext context, dynamic room) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      DateTime? _selectedDueDate = room['dueDate'] != null
          ? DateTime.parse(room['dueDate'])
          : null;

      List<String> photos = [
        (room['photo1'] as String?)?.toString() ?? '',
        (room['photo2'] as String?)?.toString() ?? '',
        (room['photo3'] as String?)?.toString() ?? '',
      ].where((photo) => photo.isNotEmpty).toList();

      PageController pageController = PageController();

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            photos[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: photos.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.black,
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Room No. ${room['roomNumber']?.toString() ?? 'Unknown'}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Price: ₱${room['price']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Capacity: ${room['capacity']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Status: ${room['roomStatus']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Occupant: ${room['occupantNonUser']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Due Date: ${room['dueDate']?.toString() ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDueDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDueDate = pickedDate;
                                  print('Selected date: $_selectedDueDate');
                                });
                              } else {
                                print('No date selected');
                              }
                            },
                            child: Text(
                              _selectedDueDate != null
                                  ? 'Due Date: ${DateFormat.yMd().format(_selectedDueDate!)}'
                                  : 'Select Due Date',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedDueDate != null) {
                                // Handle the submission logic here
                                print('Submitting due date: $_selectedDueDate');
                                updateRoomDueDate(room['_id'], _selectedDueDate!); // Pass room ID and date
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please select a due date.'),
                                  ),
                                );
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> updateRoomDueDate(String roomId, DateTime dueDate) async {
  try {
    final response = await http.patch(
      Uri.parse('http://192.168.1.6:3000/rooms/updateRoom/$roomId'), // Ensure the URL is correct
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'dueDate': dueDate.toIso8601String(),  // Send dueDate in ISO8601 format
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








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value
            ? Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _themeController.isDarkMode.value
                ? Colors.white
                : const Color.fromARGB(255, 94, 94, 94),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigationMenu(token: widget.token)));
          },
        ),
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
                                  // onTap: () {
                                  //   showPropertyDetailPage(Property.fromJson(item));
                                  // },
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
                                                  
                                                  const SizedBox(height: 4),
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
                                        Text(
                                          'Room/Unit Available',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(height: 8),
                                        rooms.isEmpty
                                            ? Text('No rooms available.')
                                            : Column(
                                                children: rooms.map((room) {
                                                  final roomPhoto1 =
                                                      '${room['photo1']}';
                                                  return Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: _getRoomStatusColor(room['roomStatus']), // Use your existing function
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: InkWell(
                                                      onTap: () => showRoomDetailModal(context, room),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                        child: Row(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Image.network(roomPhoto1,
                                                                  width: 80, height: 60, fit: BoxFit.cover),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Room No. ${room['roomNumber']?.toString() ?? 'Unknown Room Number'}',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: _themeController.isDarkMode.value
                                                                          ? const Color.fromARGB(255, 0, 0, 0)
                                                                          : Colors.black,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 4),
                                                                  Text(
                                                                    'Price: ₱${room['price']?.toString() ?? 'N/A'}',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: _themeController.isDarkMode.value
                                                                          ? const Color.fromARGB(255, 0, 0, 0)
                                                                          : const Color.fromARGB(255, 0, 0, 0),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'Capacity: ${room['capacity']?.toString() ?? 'N/A'}',
                                                                    style: TextStyle(
                                                                      fontFamily: 'Poppins',
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: _themeController.isDarkMode.value
                                                                          ? const Color.fromARGB(255, 0, 0, 0)
                                                                          : const Color.fromARGB(255, 0, 0, 0),
                                                                    ),
                                                                  ),
                                                                  // Add room status with DatePicker
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'Room Status: ',
                                                                        style: TextStyle(
                                                                          fontFamily: 'Poppins',
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: _themeController.isDarkMode.value
                                                                              ? const Color.fromARGB(255, 0, 0, 0)
                                                                              : const Color.fromARGB(255, 0, 0, 0),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal: 8, vertical: 3),
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
                                                                      // Add InkWell or icon to show modal for room details
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
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
