// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../propertyDetailPage.dart';
import '../fullscreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final String userEmail;
  final String imageUrl;
  final List<String> bookmarkedPropertyIds;
  final Function(String propertyId) bookmarkProperty;
  final String priceRange;
  final bool isDarkMode;
  final String token; // Assuming you pass the token as a parameter
  final String userId;
  PropertyCard({
    required this.property,
    required this.userEmail,
    required this.imageUrl,
    required this.bookmarkedPropertyIds,
    required this.bookmarkProperty,
    required this.priceRange,
    required this.isDarkMode,
    required this.token,
    required this.userId,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> with SingleTickerProviderStateMixin{
 // Assuming you pass the userId as a parameter
  final ThemeController _themeController = Get.find<ThemeController>();
  late final AnimationController  _controller;
   bool isBookmarked = false;
    double averageRating = 0.0; // Variable to hold the average rating

@override
void initState() {
  super.initState();

      // Initialize bookmark state
    isBookmarked = widget.bookmarkedPropertyIds.contains(widget.property.id);

  _controller = AnimationController(
    duration: Duration(milliseconds: 1600),
    vsync: this);
     isBookmarked = widget.bookmarkedPropertyIds.contains(widget.property.id);
      if (isBookmarked) {
      _controller.value = 1.0; // Reverse position, indicating it's bookmarked
    } else {
      _controller.value = 0.0; // Initial position, indicating it's not bookmarked
    }
     // Fetch the average rating
    _fetchAverageRating();
}

@override
void dispose() {
  
  super.dispose();
  _controller.dispose();
}


 void _fetchAverageRating() async {
  // Replace with your actual API endpoint
  final url = Uri.parse('http://192.168.1.8:3000/averageRating/${widget.property.id}');
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
        // Adjusted the assignment to handle both int and double types
        averageRating = (jsonMap['averageRating'] is int)
            ? (jsonMap['averageRating'] as int).toDouble() // Convert int to double
            : (jsonMap['averageRating'] as double); // Keep as double
      });
    } else {
      print('Failed to fetch average rating');
    }
  } catch (error) {
    print('Error fetching average rating: $error');
  }
}


  // Function to handle bookmarking without full page refresh
void _bookmarkProperty() {
  // Set up a listener to call widget.bookmarkProperty after animation completes
  _controller.addStatusListener((status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      // Toggle the local bookmark state
      setState(() {
        isBookmarked = !isBookmarked;
      });
      
      // Call the actual bookmark function (API, etc.)
      widget.bookmarkProperty(widget.property.id);
      
      // Remove listener to avoid repeated calls
      _controller.removeStatusListener((_) {});
    }
  });

  // Start the animation
  if (!isBookmarked) {
    _controller.forward();
  } else {
    _controller.reverse();
  }
}


  Future<Map<String, String>> fetchUserProfileStatus() async {
    final url = Uri.parse('http://192.168.1.8:3000/profile/checkProfileCompletion/${widget.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return {
          'profileStatus': jsonMap['profileStatus'] ?? 'none',
          'userRole': jsonMap['userRole'] ?? 'none',
        };
      } else {
        print('Failed to fetch profile status');
        return {'profileStatus': 'none', 'userRole': 'none'};
      }
    } catch (error) {
      print('Error fetching profile status: $error');
      return {'profileStatus': 'none', 'userRole': 'none'};
    }
  }



@override
Widget build(BuildContext context) {
  return FutureBuilder<Map<String, String>>(
    future: fetchUserProfileStatus(),
    
    builder: (context, snapshot) {
      bool _loading = snapshot.connectionState == ConnectionState.waiting;

      if (snapshot.hasError) {
        return Center(child: Text('Error fetching user data'));
      } else {
        final profileStatus = snapshot.data?['profileStatus'] ?? 'none';
        final userRole = snapshot.data?['userRole'] ?? 'none';

        return Skeletonizer(
          enabled: _loading,
          child: Card(
            color: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 36, 38, 43)
                : const Color.fromARGB(255, 255, 255, 255),
            elevation: 5.0,
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailPage(
                      token: widget.token,
                      property: widget.property,
                      userEmail: widget.userEmail,
                      userRole: userRole,
                      profileStatus: profileStatus,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.typeOfProperty ?? 'Unknown Property Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Price range: ₱${widget.priceRange}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: _themeController.isDarkMode.value
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.property.street ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _themeController.isDarkMode.value
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '${widget.property.barangay ?? ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _themeController.isDarkMode.value
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.property.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                             // Star Rating Row
                                Row(
                                  children: [
                                    for (int i = 0; i < 5; i++) 
                                      if (averageRating >= i + 1) 
                                        Icon(
                                          Icons.star, // Full star
                                          size: 16,
                                          color: Colors.amber,
                                        )
                                      else if (averageRating >= i + 0.1) 
                                        Icon(
                                          Icons.star_half, // Half star
                                          size: 16,
                                          color: Colors.amber,
                                        )
                                      else 
                                        Icon(
                                          Icons.star_border, // Empty star
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${averageRating.toStringAsFixed(1)} / 5', // Show average rating
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _themeController.isDarkMode.value
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullscreenImage(
                                    imageUrl: widget.imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: widget.imageUrl,
                              child: Container(
                                width: 110,
                                height: 100,
                                color: _themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 52, 52, 52)
                                    : const Color.fromARGB(255, 240, 240, 240),
                                child: widget.imageUrl.isNotEmpty
                                    ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                                    : const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              height: 27,
                              width: 60,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(0, 54, 231, 1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailPage(
                                        token: widget.token,
                                        property: widget.property,
                                        userEmail: widget.userEmail,
                                        userRole: userRole,
                                        profileStatus: profileStatus,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'GeistSans',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            ShadTooltip(
                              builder: (context) => const Text('Save property'),
                              child: GestureDetector(
                                onTap: _bookmarkProperty,
                                child: Lottie.network(
                                  'https://lottie.host/03753c90-78ba-4e39-b02c-c590287b7f36/VBizI5alvT.json',
                                  height: 40,
                                  controller: _controller,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    },
  );
}

}
