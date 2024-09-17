import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/components/property_card.dart';
import 'package:rentcon/pages/components/rangeSlider.dart';
import 'package:rentcon/pages/components/searchField.dart';
import 'package:rentcon/pages/components/setupProfileButton.dart';
import 'package:rentcon/pages/components/showFilterDialog.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:rentcon/pages/search_result.dart';
import 'toast.dart';
import 'package:rentcon/theme_controller.dart';
import '../models/property.dart';
import 'global_loading_indicator.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({required this.token, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String email;
  late String userId;
  late Future<List<Property>> propertiesFuture;
  List<String> bookmarkedPropertyIds = [];
  List<Property> filteredProperties = [];
  late FToast ftoast;
  late ToastNotification toast;
  String searchQuery = '';
  String profileStatus = 'none'; // Default value
  String userRole = '';
  bool hasNewNotifications = true;
  RangeValues _currentRange = RangeValues(100, 500); // Default range
  bool isFilterApplied = false; // Tracks if the filter is applied


  List<String> notifications = [];

  late TextEditingController _searchController;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    ftoast = FToast(); // Initialize FToast
    ftoast.init(context);
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    propertiesFuture = fetchProperties();
    fetchUserBookmarks();
    toast = ToastNotification(ftoast.init(context));
    propertiesFuture.then((properties) {
      setState(() {
        filteredProperties = properties;
      });
    });
     fetchUserProfileStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

Future<void> fetchUserProfileStatus() async {
  final url = Uri.parse('http://192.168.1.8:3000/profile/checkProfileCompletion/$userId'); // Replace with your API endpoint
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      setState(() {
        profileStatus = jsonMap['profileStatus'] ?? 'none';
        userRole = jsonMap['userRole'] ?? 'none';  // Store the user role
      });
      // Fetch notifications based on profile status and role
      if (profileStatus == 'approved' || profileStatus == 'rejected') {
        fetchNotifications();
      }
    } else {
      print('Failed to fetch profile status');
    }
  } catch (error) {
    print('Error fetching profile status: $error');
  }
}


Future<void> fetchUserProfileStatusForNotification() async {
  final url = Uri.parse('http://192.168.1.8:3000/profile/checkProfileCompletion/$userId'); // Your API endpoint
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      // Assuming the API response is in JSON format and contains a 'status' field
      final responseData = json.decode(response.body);
      final responseStatus = responseData['status']; // Parse the profile status

      if (responseStatus == 'approved') {
        setState(() {
          notifications.add('Your profile has been approved!');
          hasNewNotifications = true;
        });
      }
      if (responseStatus == 'rejected') {
        setState(() {
          notifications.add('Your profile has been rejected! Please double check the provided information if correct.');
          hasNewNotifications = true;
        });
      }
    } else {
      // Handle non-200 status codes
      print('Failed to fetch profile status: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occurred during the HTTP request
    print('Error fetching profile status: $e');
  }
}

  //Fetch properties from the API
// Fetch properties from the API and filter based on 'approved' status
Future<List<Property>> fetchProperties() async {
  try {
    final response = await http.get(Uri.parse(getAllProperties));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['success'];

      // Convert JSON data to Property objects
      final properties = data
          .map((json) => Property.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter only properties with the status 'approved'
      final approvedProperties = properties
          .where((property) => property.status.toLowerCase() == 'approved')
          .toList();

      // Reverse the list to show newest properties first
      return approvedProperties.reversed.toList();
    } else {
      throw Exception('Failed to load properties');
    }
  } catch (error) {
    throw Exception('Failed to load properties: $error');
  }
}


Future<List<dynamic>> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.8:3000/rooms/properties/$propertyId/rooms'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          return data['rooms']; // Return the rooms data as List<dynamic>
        }
      }
    } catch (e) {
      print('Failed to load rooms for property $propertyId');
    }
    return []; // Return an empty list if an error occurs or no rooms are found
  }

Future<List<Property>> filterProperties(List<Property> properties) async {
    double? minPrice = double.tryParse(_minPriceController.text);
    double? maxPrice = double.tryParse(_maxPriceController.text);

    List<Property> filtered = [];

    for (Property property in properties) {
      bool matchesDescription = property.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          property.street.toLowerCase().contains(searchQuery.toLowerCase()) ||
          property.barangay.toLowerCase().contains(searchQuery.toLowerCase()) ||
          property.city.toLowerCase().contains(searchQuery.toLowerCase());


      if (!matchesDescription)
        continue; // Skip property if it doesn't match description

      bool matchesPrice = true;

      if (minPrice != null || maxPrice != null) {
        List<dynamic> rooms = await fetchRooms(property.id);

        if (rooms.isNotEmpty) {
          // Ensure all prices are treated as doubles
          double minRoomPrice = rooms.map((r) {
            final price = r['price'];
            return price is int ? price.toDouble() : price as double;
          }).reduce((a, b) => a < b ? a : b);

          double maxRoomPrice = rooms.map((r) {
            final price = r['price'];
            return price is int ? price.toDouble() : price as double;
          }).reduce((a, b) => a > b ? a : b);

          if (minPrice != null && maxRoomPrice < minPrice) {
            matchesPrice = false;
          }
          if (maxPrice != null && minRoomPrice > maxPrice) {
            matchesPrice = false;
          }
        } else {
          matchesPrice = false; // No rooms means no price information
        }
      }

      if (matchesPrice) {
        filtered
            .add(property); // Only add properties that match the price range
      }
    }

    return filtered;
  }

Future<void> fetchUserBookmarks() async {
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.8:3000/getUserBookmarks/$userId'), // Adjust endpoint if necessary
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        // Populate the bookmarkedPropertyIds list
        bookmarkedPropertyIds = List<String>.from(
            jsonMap['properties'].map((property) => property['_id']));
      } else {
        throw Exception('Failed to fetch bookmarks');
      }
    } catch (error) {
      print('Error loading user bookmarks: $error');
    }
  }

  // Fetch user email from API
Future<String> fetchUserEmail(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.8:3000/getUserEmail/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['email'];
      } else {
        throw Exception('Failed to load user email');
      }
    } catch (error) {
      throw Exception('Failed to load user email: $error');
    }
  }

  // Refresh function to reload the properties
Future<void> _refreshProperties() async {
    setState(() {
      propertiesFuture = fetchProperties(); // Re-fetch properties on refresh
    });
  }

// Function to bookmark a property
Future<void> bookmarkProperty(String propertyId) async {
    final url = Uri.parse('http://192.168.1.8:3000/addBookmark');
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      if (bookmarkedPropertyIds.contains(propertyId)) {
        // If already bookmarked, remove it
        final removeUrl = Uri.parse('http://192.168.1.8:3000/removeBookmark');
        await http.post(removeUrl,
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        setState(() {
          bookmarkedPropertyIds.remove(propertyId); // Update local state
          filteredProperties = filteredProperties
              .where((property) => property.id != propertyId)
              .toList();
        });

        // Show custom toast for removal
        toast.warn('Property removed from bookmarks!');
      } else {
        // If not bookmarked, add it
        await http.post(url,
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        setState(() {
          bookmarkedPropertyIds.add(propertyId); // Update local state
        });

        // Show custom toast for addition
        toast.success('Property added to bookmarks!');
      }

      // Refresh properties to reflect changes immediately
      await _refreshProperties();
    } catch (error) {
      print('Error toggling bookmark: $error');
      // Show error message with a custom toast
      toast.error('Failed to toggle bookmark');
    }
  }

void _performSearch() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      // Filter properties based on the search query and wait for the result
      final matchingProperties = await filterProperties(filteredProperties);

      // Navigate to the search results page with the matching properties
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(
            query: query,
            properties: matchingProperties,
          ),
        ),
      );
    }
  }

void _handleSearch(String query) async {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredProperties =
          (propertiesFuture as Future<List<Property>>).then((properties) {
        return properties.where((property) {
          return property.description.toLowerCase().contains(searchQuery) ||
              property.street.toLowerCase().contains(searchQuery.toLowerCase()) ||
              property.barangay.toLowerCase().contains(searchQuery.toLowerCase()) ||
              property.city.toLowerCase().contains(searchQuery.toLowerCase());

        }).toList();
      }) as List<Property>;
    });
  }

void _applyFilters() {
  setState(() {
    isFilterApplied = true;
  });
}
void _clearFilters() {
  setState(() {
    _currentRange = RangeValues(100, 500); // Reset to default
    isFilterApplied = false; // No filter applied
  });
}

void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FilterDialog(
        minPriceController: _minPriceController,
        maxPriceController: _maxPriceController,
        applyFilters: _applyFilters,
        clearFilters: _clearFilters,
        initialRange: _currentRange, // Pass the current range
      );
    },
  );
}



Future<void> fetchNotifications() async {
  if (userRole == 'landlord') {
    final url = Uri.parse('http://192.168.1.8:3000/notifications/$userId'); // Your API endpoint for notifications

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          notifications = data.map((notification) => notification['message'] as String).toList();
          hasNewNotifications = notifications.isNotEmpty;
        });
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }
}


 void _clearNotifications() {
    setState(() {
      notifications.clear();
      hasNewNotifications = false;
    });
  }

void _showNotificationsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: notifications.isEmpty
              ? Text('No new notifications.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: notifications
                      .map((notif) => ListTile(
                            title: Text(notif),
                          ))
                      .toList(),
                ),
          actions: [
            TextButton(
              child: Text('Clear All'),
              onPressed: () {
                _clearNotifications();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


@override
Widget build(BuildContext context) {
  ftoast = FToast();
  ftoast.init(context);
  toast = ToastNotification(ftoast);
  final NavigationController controller = Get.find<NavigationController>();

  return Scaffold(
    backgroundColor: _themeController.isDarkMode.value
        ? Color.fromARGB(255, 28, 29, 34) // 67, 66, 73
        : Color.fromRGBO(255, 255, 255, 1),
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 27),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Home",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: _themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              profileStatus == null
                  ? CircularProgressIndicator() // Show loading spinner until status is fetched
                  : profileStatus == 'none'
                      ? Setupprofilebutton(
                          token: widget.token,
                        )
                      : SizedBox.shrink(),
              Row(
                children: [
                  // Conditionally display either house or listing icon
                  profileStatus == 'approved' && userRole == 'occupant'
                      ? IconButton(
                          onPressed: () {
                            // Navigate to occupant-specific page
                          },
                          icon: SvgPicture.asset('assets/icons/coloredhome.svg',
                             // House icon for occupant
                            
                            height: 24,
                          ),
                        )
                      : profileStatus == 'approved' && userRole == 'landlord'
                          ? IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> CurrentListingPage(token: widget.token)));
                              },
                              icon: Icon(
                                Icons.list, // Listing icon for landlord
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                                size: 24,
                              ),
                            )
                          : SizedBox.shrink(),
                  // Notification Icon with Badge
                  Stack(
                    children: [
                      IconButton(
                        onPressed: _showNotificationsModal, // Show notifications modal on bell click
                        icon: SvgPicture.asset(
                          'assets/icons/bell.svg',
                          color: _themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.black,
                          height: 24,
                          width: 24,
                        ),
                      ),
                      if (hasNewNotifications) // Check if there are new notifications
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notifications.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
            SizedBox(height: 1),
            SearchFieldWidget(
            searchController: _searchController,
            isDarkMode: _themeController.isDarkMode.value,
            handleSearch: _handleSearch,
            performSearch: _performSearch,
            showFilterDialog: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FilterDialog(
                    minPriceController: _minPriceController,
                    maxPriceController: _maxPriceController,
                    applyFilters: _applyFilters,
                    initialRange: RangeValues(
                      double.tryParse(_minPriceController.text) ?? 0.0,
                      double.tryParse(_maxPriceController.text) ?? 10000.0,
                    ),
                    clearFilters: () {
                      _minPriceController.text = '0';
                      _maxPriceController.text = '10000';
                      // Notify the dialog of the cleared filters
                      setState(() {
                        isFilterApplied = false; // Assuming you have this state to reflect the filter status
                      });
                    },
                  );
                },
              );
            },
            isFilterApplied: isFilterApplied,
          ),

            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProperties,
                child: FutureBuilder<List<Property>>(
                  future: propertiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return GlobalLoadingIndicator();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No properties available.'));
                    } else {
                      final properties = searchQuery.isEmpty
                          ? snapshot.data!
                          : filteredProperties;

                      return ListView.builder(
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          final imageUrl = property.photo.startsWith('http')
                              ? property.photo
                              : 'http://192.168.1.8:3000/${property.photo}';

                          return FutureBuilder<List<dynamic>>(
                            future: fetchRooms(property.id),
                            builder: (context, roomsSnapshot) {
                              if (roomsSnapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox.shrink(); // Just return an empty widget here
                              } else if (roomsSnapshot.hasError || !roomsSnapshot.hasData) {
                                return Center(child: Text('No rooms available.'));
                              }
                              final rooms = roomsSnapshot.data!;
                              final priceRange = rooms.isNotEmpty
                                  ? '${rooms.map((r) => r['price']).reduce((a, b) => a < b ? a : b)} - ${rooms.map((r) => r['price']).reduce((a, b) => a > b ? a : b)}'
                                  : 'N/A';
                              return FutureBuilder<String>(
                                future: fetchUserEmail(property.userId),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox.shrink(); // Just return an empty widget here
                                  } else if (userSnapshot.hasError) {
                                    return Center(child: Text('Error: ${userSnapshot.error}'));
                                  } else if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                                    return Center(child: Text('No user email found.'));
                                  } else {
                                    final userEmail = userSnapshot.data!;
                                    return PropertyCard(
                                      userId: userId,
                                      token: widget.token,
                                      property: property,
                                      userEmail: userEmail,
                                      imageUrl: imageUrl,
                                      bookmarkedPropertyIds: bookmarkedPropertyIds,
                                      bookmarkProperty: bookmarkProperty,
                                      priceRange: priceRange,
                                      isDarkMode: _themeController.isDarkMode.value,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


 

  
}

// Controller for the search field
final TextEditingController _searchController = TextEditingController();
