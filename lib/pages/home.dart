import 'dart:convert';
import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/models/user_class.dart';
import 'package:rentcon/pages/components/awesome_snackbar.dart';
import 'package:rentcon/pages/components/filterChips.dart';
import 'package:rentcon/pages/components/notification_stream.dart';
import 'package:rentcon/pages/components/property_card.dart';
import 'package:rentcon/pages/components/rangeSlider.dart';
import 'package:rentcon/pages/components/searchField.dart';
import 'package:rentcon/pages/components/setupProfileButton.dart';
import 'package:rentcon/pages/components/shadNotif.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:rentcon/pages/search_result.dart';
import 'package:rentcon/pages/services/appUpdate.dart';
import 'package:rentcon/provider/notification.dart';
import 'package:rentcon/provider/properties.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'toast.dart';
import 'package:rentcon/theme_controller.dart';
import '../models/property.dart';
import 'global_loading_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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
  late ToastNotification toastNotification;
  String? _profileImageUrl;
  Map<String, dynamic>? userDetails;
  List<dynamic> notifications = [];

  late TextEditingController _searchController;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final ThemeController _themeController = Get.find<ThemeController>();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    toastNotification = ToastNotification(context);
    _searchController = TextEditingController();
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    propertiesFuture = fetchProperties();
    fetchUserBookmarks();
    propertiesFuture.then((properties) {
    if (mounted) {
      setState(() {
        filteredProperties = properties;
      });
    }
  });
    fetchUserProfileStatus();
    initPlatform();
    _updateNotifications();

    UserSession().userRole =
        userRole; // Assuming userRole is retrieved from the token
    UserSession().profileStatus =
        profileStatus; // Assuming profileStatus is set properly
    _fetchUserProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker().checkForUpdates(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();

    super.dispose();
  }

 Future<void> _fetchUserProfile() async {
  final url = Uri.parse('https://rentconnect.vercel.app/user/$userId');
  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          userDetails = data; 
          _profileImageUrl = data['profilePicture'];
        });
      }
    } else {
      print('No profile yet');
    }
  } catch (error) {
    print('Error fetching profile data: $error');
  }
}


 Future<void> incrementPropertyViews(String propertyId) async {
  if (!mounted) return;

  final url = Uri.parse('https://192.168.1.12:3000/properties/$propertyId/view');
  try {
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('View count incremented: ${data['views']}');
    } else {
      print('Failed to increment views. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}


  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    ftoast = FToast();
    ftoast.init(context);
    final NavigationController controller = Get.find<NavigationController>();
    final propertiesProvider = Provider.of<PropertiesProvider>(context);
    if (!propertiesProvider.isLoading && propertiesProvider.properties.isEmpty) {
      propertiesProvider.fetchProperties();
    }
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: _themeController.isDarkMode.value
                ? Color.fromARGB(255, 28, 29, 34)
                : Colors.white,
            title: Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _profileImageUrl != null
                          ? Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Lottie.network(
                              "https://lottie.host/175e3a4e-4de1-4e63-9e56-d0d88cfa8ccb/bJoOA5DkNU.json",
                            ),
                    ),
                  ),
                  SizedBox(width: 10.0), // Space between the image and the name
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getGreeting() + '!',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'manrope',
                              color: _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 238, 238, 255)
                                  : const Color.fromARGB(255, 10, 0, 40),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            userDetails != null &&
                                    userDetails?['profile']?['firstName'] != null
                                ? '${userDetails?['profile']?['firstName']} ${userDetails?['profile']?['lastName']}' // Display user's first and last name
                                : email ?? 'User', // Fallback if the userDetails or email is not available yet
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'manrope',
                              color: _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 238, 238, 255)
                                  : const Color.fromARGB(255, 10, 0, 40),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0,top: 10),
                child: Row(
                  children: [
                    profileStatus == 'approved' && userRole == 'occupant'
                        ? ShadTooltip(
                            builder: (context) =>
                                const Text('See your inquiries'),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OccupantInquiries(
                                      userId: userId,
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/occupanthome.svg',
                                color: _themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 10, 0, 40),
                                height: 24,
                              ),
                            ),
                          )
                        : profileStatus == 'approved' && userRole == 'landlord'
                            ? ShadTooltip(
                                builder: (context) =>
                                    const Text('See Your Listing'),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CurrentListingPage(
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/listing2.svg',
                                    color: _themeController.isDarkMode.value
                                        ? const Color.fromARGB(255, 255, 255, 255)
                                        : const Color.fromARGB(255, 10, 0, 40),
                                    height: 24,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: SizedBox(
                        height: 37,
                        width: 38,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _themeController.isDarkMode.value
                                ? const Color.fromARGB(139, 75, 76, 97)
                                : const Color.fromARGB(255, 10, 0, 40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FutureBuilder<List<dynamic>>(
                            future: fetchNotifications(userId, widget.token),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CupertinoActivityIndicator(
                                  color: _themeController.isDarkMode.value
                                      ? Colors.white
                                      : Colors.white,
                                );
                              } else if (snapshot.hasError) {
                                return IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text('Failed to load notifications'),
                                    ));
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/bell3.svg',
                                    color: _themeController.isDarkMode.value
                                        ? const Color.fromARGB(255, 255, 255, 255)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255),
                                    height: 20,
                                    width: 20,
                                  ),
                                );
                              } else {
                                final notifications = snapshot.data ?? [];
                                final hasNewNotifications = notifications.isNotEmpty;
                                return Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: SizedBox(
                                                width: 380,
                                                child: CardNotifications(
                                                  userId: userId,
                                                  token: widget.token,
                                                  onNotificationsUpdated:
                                                      onNotificationsUpdated,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/icons/bell3.svg',
                                        color: _themeController.isDarkMode.value
                                            ? const Color.fromARGB(
                                                255, 255, 255, 255)
                                            : const Color.fromARGB(
                                                255, 255, 255, 255),
                                        height: 24,
                                        width: 24,
                                      ),
                                    ),
                                    if (hasNewNotifications) // Check if there are new notifications
                                      Positioned(
                                        right: 4,
                                        top: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(3),
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
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: _themeController.isDarkMode.value
            ? Color.fromARGB(255, 28, 29, 34)
            : Color.fromRGBO(255, 255, 255, 1),
        body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          setState(() {
                            isFilterApplied = false;
                          });
                        },
                      );
                    },
                  );
                },
                isFilterApplied: isFilterApplied,
              ),
              const SizedBox(height: 10),
              FilterChips(
                filters: filters,
                selectedFilter: selectedFilter,
                onSelected: onSelected,
              ),
              const SizedBox(height: 5),
              Expanded(
                child: RefreshIndicator(
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await propertiesProvider.fetchProperties();
                  },
                  child: Builder(
                    builder: (context) {
                      if (propertiesProvider.isLoading) {
                        return Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    color: _themeController.isDarkMode.value
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (propertiesProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/noInternet.png', // Replace with your PNG path
                                width: 200,
                                height: 200,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                propertiesProvider.errorMessage!,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _themeController.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'manrope',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ShadButton(
                                onPressed: () async {
                                  await propertiesProvider.fetchProperties();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (propertiesProvider.properties.isEmpty) {
                        return const Center(
                          child: Text('No properties available.'),
                        );
                      }

                      final properties = searchQuery.isEmpty
                          ? propertiesProvider.properties
                          : filteredProperties; // Adjust filtering logic as needed.

                      return ListView.builder(
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          final imageUrl = property.photo.startsWith('http')
                              ? property.photo
                              : 'https://rentconnect.vercel.app/${property.photo}';

                          return FutureBuilder<List<dynamic>>(
                            future: fetchRooms(property.id),
                            builder: (context, roomsSnapshot) {
                              if (roomsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }

                              final rooms = roomsSnapshot.data ?? [];
                              final priceRange = rooms.isNotEmpty
                                  ? '${rooms.map((r) => r['price']).reduce((a, b) => a < b ? a : b)} - ${rooms.map((r) => r['price']).reduce((a, b) => a > b ? a : b)}'
                                  : 'N/A';

                              return FutureBuilder<String>(
                                future: fetchUserEmail(property.userId),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }

                                  final userEmail = userSnapshot.data ?? '';

                                  return PropertyCard(
                                    userId: userId,
                                    token: widget.token,
                                    property: property,
                                    userEmail: userEmail,
                                    imageUrl: imageUrl,
                                    bookmarkedPropertyIds:
                                        bookmarkedPropertyIds,
                                    bookmarkProperty: (propertyId) {
                                      bookmarkProperty(
                                        propertyId,
                                        (bool isBookmarked) {},
                                      );
                                    },
                                    priceRange: priceRange,
                                    isDarkMode:
                                        _themeController.isDarkMode.value,
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              profileStatus == 'none'
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Setupprofilebutton(
                        token: widget.token,
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ),
  );
  }

  Stream<List<dynamic>> notificationStream =
      NotificationStream().stream.cast<List<dynamic>>();

  // Method to fetch notifications and update state
  Future<void> _updateNotifications() async {
    // Your logic to fetch notifications goes here
    final fetchedNotifications =
        await fetchNotifications(userId, widget.token); // Implement this
    setState(() {
      notifications = fetchedNotifications;
      hasNewNotifications = notifications.isNotEmpty;
    });
  }

  void onNotificationsUpdated(List<dynamic> updatedNotifications) {
    setState(() {
      notifications = updatedNotifications;
      hasNewNotifications = notifications.isNotEmpty;
    });
  }

  Future<void> initPlatform() async {
    OneSignal.initialize("af1220cb-edec-447f-a4e2-8bc6b7638322");
    await OneSignal.User.getOnesignalId().then(
      (value) => {
        print(value),
      },
    );
  }

  Future<void> fetchUserProfileStatus() async {
    final url = Uri.parse(
        'https://rentconnect.vercel.app/profile/checkProfileCompletion/$userId'); // Replace with your API endpoint
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
          userRole = jsonMap['userRole'] ?? 'none'; // Store the user role
        });
        // Fetch notifications based on profile status and role
        if (profileStatus == 'approved' || profileStatus == 'rejected') {
          fetchNotifications(userId, widget.token);
        }
      } else {
        print('Failed to fetch profile status');
      }
    } catch (error) {
      print('Error fetching profile status: $error');
    }
  }

  Future<void> fetchUserProfileStatusForNotification() async {
    final url = Uri.parse(
        'https://rentconnect.vercel.app/profile/checkProfileCompletion/$userId'); // Your API endpoint
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
        final responseStatus =
            responseData['status']; // Parse the profile status

        if (responseStatus == 'approved') {
          setState(() {
            notifications.add('Your profile has been approved!');
            hasNewNotifications = true;
          });
        }
        if (responseStatus == 'rejected') {
          setState(() {
            notifications.add(
                'Your profile has been rejected! Please double check the provided information if correct.');
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
Future<List<Property>>? _cachedPropertiesFuture;

Future<List<Property>> fetchProperties() async {
  // If the Future is already cached, return it
  if (_cachedPropertiesFuture != null) {
    return _cachedPropertiesFuture!;
  }

  // Otherwise, cache the result of the fetch operation
  _cachedPropertiesFuture = _fetchPropertiesFromApi();
  return _cachedPropertiesFuture!;
}

Future<List<Property>> _fetchPropertiesFromApi() async {
  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('No internet connection');
  }

  try {
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/getAllProperties'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print('Response body: ${response.body}');
      final List<dynamic> data = json['success'];
      print('Success data: $data');

      final properties = data
          .map((json) => Property.fromJson(json as Map<String, dynamic>))
          .toList();

      final approvedProperties = properties
          .where((property) => property.status.toLowerCase() == 'approved')
          .toList();

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
          'https://rentconnect.vercel.app/rooms/properties/$propertyId/rooms'));
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
  if (bookmarkedPropertyIds.isNotEmpty) return; // Use cached data
  try {
    final response = await http.get(
      Uri.parse('https://rentconnect.vercel.app/getUserBookmarks/$userId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      setState(() {
        bookmarkedPropertyIds = List<String>.from(
          jsonMap['properties'].map((property) => property['_id']),
        );
      });
    }
  } catch (error) {
    print('Error loading user bookmarks: $error');
  }
}

  // Fetch user email from API
  Future<String> fetchUserEmail(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('https://rentconnect.vercel.app/getUserEmail/$userId'));

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
  Future<void> _refreshProperties() async {
    try {
      final properties = await fetchProperties();
      fetchUserBookmarks();
      setState(() {
        filteredProperties = properties;
      });
    } catch (error) {
      print('Error refreshing properties: $error');
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
            userEmail: email,
            userRole: userRole,
            profileStatus: profileStatus,
            token: widget.token,
            userId: userId,
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
              property.street
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              property.barangay
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
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

  Future<List<dynamic>> fetchNotifications(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://rentconnect.vercel.app/notification/unread/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('notifications') &&
            data['notifications'] is List) {
          print('Notifications fetched: ${data['notifications']}');
          return data['notifications']; // Return the notifications list
        } else {
          print('No notifications found or invalid format');
          return [];
        }
      } else {
        print('Failed to load notifications. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  final List<String> filters = ['All', 'Boarding House', 'Apartment'];
  String selectedFilter = 'All';
  void onSelected(String filter) async {
    setState(() {
      selectedFilter = filter; // Update the selected filter
    });
    final properties =
        await propertiesFuture;
    List<Property> filteredProperties;
    if (selectedFilter == 'All') {
      filteredProperties = properties; // No filtering, show all
    } else {
      filteredProperties = properties
          .where((property) =>
              property.typeOfProperty?.toLowerCase() ==
              selectedFilter.toLowerCase())
          .toList();
    }
    setState(() {
      this.filteredProperties =
          filteredProperties;
    });
  }

  Future<void> bookmarkProperty(
      String propertyId, Function(bool isBookmarked) onUpdate) async {
    final url = Uri.parse('https://rentconnect.vercel.app/addBookmark');
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      if (bookmarkedPropertyIds.contains(propertyId)) {
        // If already bookmarked, remove it
        final removeUrl = Uri.parse('https://rentconnect.vercel.app/removeBookmark');
        await http.post(removeUrl,
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        // Immediately trigger the callback to indicate removal
        onUpdate(false);

        // Show success toast for removal
        toastNotification.warn("Successfully removed from bookmark!");

        // Update state after a 1.5-second delay
        await Future.delayed(Duration(milliseconds: 0));
        setState(() {
          bookmarkedPropertyIds.remove(propertyId);
          // filteredProperties = filteredProperties.where((property) => property.id != propertyId).toList();
        });
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

        // Immediately trigger the callback to indicate addition
        onUpdate(true);

        // Show success toast for addition
        toastNotification.success("Successfully added to bookmark!");

        // Update state after a 1.5-second delay
        await Future.delayed(Duration(milliseconds: 0));
        setState(() {
          bookmarkedPropertyIds.add(propertyId);
        });
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Error toggling bookmark!',
        duration: Duration(milliseconds: 1500),
      );
    }
  }
}