import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../propertyDetailPage.dart';
import '../fullscreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final String userEmail;
  final String imageUrl;
  final List<String> bookmarkedPropertyIds;
  final Function(String) bookmarkProperty;
  final String priceRange;
  final bool isDarkMode;
  final String token; // Assuming you pass the token as a parameter
  final String userId; // Assuming you pass the userId as a parameter

  final ThemeController _themeController = Get.find<ThemeController>();

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

  Future<Map<String, String>> fetchUserProfileStatus() async {
    final url = Uri.parse('http://192.168.1.19:3000/profile/checkProfileCompletion/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
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

        // Check if the property is bookmarked
        final isBookmarked = bookmarkedPropertyIds.contains(property.id);

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
                      token: token,
                      property: property,
                      userEmail: userEmail,
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
                              property.typeOfProperty ?? 'Unknown Property Type',
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
                              'Price range: ₱$priceRange',
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
                                      property.street ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _themeController.isDarkMode.value
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '${property.barangay ?? ''}',
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
                              property.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
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
                                    imageUrl: imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: imageUrl,
                              child: Container(
                                width: 110,
                                height: 100,
                                color: _themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 52, 52, 52)
                                    : const Color.fromARGB(255, 240, 240, 240),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
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
                                  backgroundColor: Color.fromRGBO(124, 0, 254, 1),
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
                                        token: token,
                                        property: property,
                                        userEmail: userEmail,
                                        userRole: userRole,
                                        profileStatus: profileStatus,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeistSans',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            ShadTooltip(
                               builder: (context) => const Text('Save property'),
                              child: IconButton(
                                icon: Icon(
                                  isBookmarked ? Icons.favorite : Icons.favorite_border_outlined,
                                  color: isBookmarked ? const Color.fromARGB(255, 255, 7, 90) : Colors.grey,
                                ),
                                onPressed: () {
                                  
                                  bookmarkProperty(property.id);
                                },
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
