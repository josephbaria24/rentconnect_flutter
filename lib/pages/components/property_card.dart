// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/provider/bookmark.dart';
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
  Map<String, dynamic>? userDetails;
  String? _profileImageUrl;



@override
void initState() {
    super.initState();

    // Initialize bookmark state
    isBookmarked = widget.bookmarkedPropertyIds.contains(widget.property.id);

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Set the initial value of the animation
    _controller.value = isBookmarked ? 1.0 : 0.0;

    // Fetch the average rating
    _fetchAverageRating();
    _fetchUserProfile();
  }

@override
void dispose() {
  
  super.dispose();
  _controller.dispose();
  
}



  Future<void> _fetchUserProfile() async {
    final url = Uri.parse(
        'https://rentconnect.vercel.app/user/${widget.property.userId}');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userDetails = jsonDecode(response.body);
          CachedNetworkImage(
            imageUrl: _profileImageUrl = data['profilePicture'],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
          //_profileImageUrl = data['profilePicture']; // Update the URL variable
        });
      } else {
        print('No profile yet');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

void _bookmarkProperty() {
  // Start the animation based on the current bookmark state
  if (!isBookmarked) {
    _controller.forward(); // Start animating to indicate bookmarking
    // Call the actual bookmark function immediately
    setState(() {
      isBookmarked = true; // Update the local state immediately
    });
    // Call the actual bookmark function through the provider
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    bookmarkProvider.bookmarkProperty(context, widget.property.id, widget.token);
  } else {
    _controller.reverse(); // Start animating to indicate unbookmarking
    // Call the actual unbookmark function immediately
    setState(() {
      isBookmarked = false; // Update the local state immediately
    });
    // Call the actual bookmark function through the provider
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    bookmarkProvider.bookmarkProperty(context, widget.property.id, widget.token);
  }
}

void _animationStatusListener(AnimationStatus status) {
  if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
    // Toggle the local bookmark state
    setState(() {
      isBookmarked = !isBookmarked;
    });

    // Call the actual bookmark function through the provider
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    bookmarkProvider.bookmarkProperty(context, widget.property.id, widget.token);

    // Reset the controller to its initial state after animation
    _controller.value = isBookmarked ? 1.0 : 0.0; // Set to completed or not
  }
}
String _calculateTimeAgo(String createdAt) {
  if (createdAt.isEmpty) return 'Unknown';
  
  try {
    // Parse the `created_at` timestamp
    DateTime createdDate = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    // Calculate the difference in days, months, and years
    int years = now.year - createdDate.year;
    int months = now.month - createdDate.month;
    if (months < 0) {
      months += 12; // Adjust if the month difference is negative
      years -= 1;   // Adjust the year difference
    }
    Duration difference = now.difference(createdDate);

    // Return the appropriate string based on the time difference
    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''} ago'; // Return years
    } else if (months > 0) {
      return '$months mo${months > 1 ? 's' : ''} ago'; // Return months
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago'; // Return in days
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago'; // Return in hours
    } else {
      return 'Just now'; // For moments less than an hour
    }
  } catch (e) {
    return 'Invalid date'; // Handle parsing errors
  }
}


@override
Widget build(BuildContext context) {
  final bookmarkProvider = Provider.of<BookmarkProvider>(context);
  print("property id: ${widget.property.userId}");
  print("UserDetails: ${userDetails}");

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
                ? const Color.fromARGB(255, 28, 29, 34)
                : const Color.fromARGB(255, 255, 255, 255),
            elevation: 0.0,
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                await triggerView();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with owner name and time
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundImage: _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/icons/persn.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 170,
                          child: Text(
                                '${userDetails?['profile']['firstName'] ?? 'unknown'} ${userDetails?['profile']['lastName'] ?? ''}'.trim(),
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _themeController.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                        ),
                        const Spacer(),
                        
                      SizedBox(
                        width: 60,
                        child: Text(
                          _calculateTimeAgo(userDetails?['created_at'] ?? ''),
                          style: TextStyle(
                            fontFamily: 'manrope',
                             overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                            color: _themeController.isDarkMode.value
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),

                  // Property Image with price overlay
                  Stack(
                    children: [
                      Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.imageUrl.isNotEmpty ? widget.imageUrl : '',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 80, // Adjust the height of the fade
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6), // Adjust the opacity as needed
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                     Positioned(
                        top: 5,
                        left: 5,
                        child: ClipPath(
                          clipper: PriceTagClipper(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.8), // Dark background
                            ),
                            child: Text(
                              '₱${widget.priceRange}',
                              style: const TextStyle(
                                fontFamily: 'manrope',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 170,
                        left: 2,
                        child: 
                        Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: const Color.fromARGB(235, 236, 8, 65),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200), // Set max width
                            child: Text(
                              '${widget.property.street ?? ''}, ${widget.property.barangay ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis, // Add ellipsis if overflow
                              maxLines: 1, // Ensure only one line
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              )
                      )
                    ],
                  ),
                  // Details Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                        color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                ShadTooltip(
                                builder: (context) => const Text('Save property'),
                                child: GestureDetector(
                                  onTap: _bookmarkProperty,
                                  child: Lottie.asset(
                                   _themeController.isDarkMode.value? 'assets/icons/whitebm.json': 'assets/icons/blackbm.json',
                                    height: 40,
                                    controller: _controller,
                                    onLoaded: (composition) {
                                      _controller.duration = composition.duration;
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                                          Text(
                              widget.property.typeOfProperty ?? 'Unknown Property Type',
                              style: TextStyle(
                                fontFamily: 'manrope',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _themeController.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                        const SizedBox(height: 5),
                        ExpandableDescription(
                          description: widget.property.description,
                        ),
                      ],
                    ),
                  ),
                   const Divider(
                    indent: 10,
                    endIndent: 10,
      thickness: 0.6,
      height: 0.0,
    ),
                ],
              ),
            ),
          ),
        );
      }
    },
  );
}

 Future<Map<String, String>> fetchUserProfileStatus() async {
    final url = Uri.parse('https://rentconnect.vercel.app/profile/checkProfileCompletion/${widget.userId}');
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




Future<void> triggerView() async {
    final userId = widget.userId; // Get the current user's ID from your auth system

    final response = await http.post(
      Uri.parse('https://rentconnect.vercel.app/properties/${widget.property.id}/view'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_JWT_TOKEN', // If you're using JWT for auth
      },
      body: jsonEncode({'userId': userId}), // Include userId in the request body
    );

    if (response.statusCode == 200) {
      // Successfully triggered the view
      print('View recorded!');
    } else {
      // Handle the error
      print('Failed to record view: ${response.body}');
    }
}



 void _fetchAverageRating() async {
  // Replace with your actual API endpoint
  final url = Uri.parse('https://rentconnect.vercel.app/averageRating/${widget.property.id}');
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

}
class PriceTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
     const double radius = 8.0;
     const double arrowWidth = 12.0; // Width of the arrow
    path.moveTo(0, 0); // Top-left corner
    path.lineTo(size.width - 10, 0); // Top-right before the arrow
    path.lineTo(size.width, size.height / 2); // Arrow tip
    path.lineTo(size.width - 10, size.height); // Bottom-right after the arrow
    
    path.lineTo(0, size.height); // Bottom-left corner
    path.close(); // Complete the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



class ExpandableDescription extends StatefulWidget {
  final String description;

  const ExpandableDescription({required this.description});

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = true; // Set initial state to expanded (Show Less)

  @override
  Widget build(BuildContext context) {
    // Check if the description is long enough to require expansion
    final isTextLongEnough = widget.description.split('\n').length > 1 || widget.description.length > 100; // Adjust this condition based on your needs

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          maxLines: _isExpanded ? null : 10000, // Show only 3 lines when collapsed
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontFamily: 'manrope'),
        ),
        // Only show the "Show More" button if the text exceeds one line
        if (isTextLongEnough)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show more' : 'Show less',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}


//  @override
//   Widget build(BuildContext context) {
//     final bookmarkProvider = Provider.of<BookmarkProvider>(context);
//     print("property id: ${widget.property.id}");
    
//     return FutureBuilder<Map<String, String>>(
//       future: fetchUserProfileStatus(),
//       builder: (context, snapshot) {
//         bool _loading = snapshot.connectionState == ConnectionState.waiting;

//         if (snapshot.hasError) {
//           return Center(child: Text('Error fetching user data'));
//         } else {
//           final profileStatus = snapshot.data?['profileStatus'] ?? 'none';
//           final userRole = snapshot.data?['userRole'] ?? 'none';

//           return Skeletonizer(
//             enabled: _loading,
//             child: Card(
//               color: _themeController.isDarkMode.value
//                   ? const Color.fromARGB(255, 36, 38, 43)
//                   : const Color.fromARGB(255, 255, 255, 255),
//               elevation: 0.0,
//               margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: InkWell(
//                 onTap: () async {
//                   await triggerView();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PropertyDetailPage(
//                         token: widget.token,
//                         property: widget.property,
//                         userEmail: widget.userEmail,
//                         userRole: userRole,
//                         profileStatus: profileStatus,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.property.typeOfProperty ?? 'Unknown Property Type',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Price range: ₱${widget.priceRange}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_on,
//                                     size: 16,
//                                     color: _themeController.isDarkMode.value ? const Color.fromARGB(235, 236, 8, 65) : const Color.fromARGB(235, 236, 8, 65),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         widget.property.street ?? '',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${widget.property.barangay ?? ''}',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 widget.property.description,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               // Star Rating Row
//                               Row(
//                                 children: [
//                                   for (int i = 0; i < 5; i++)
//                                     if (averageRating >= i + 1)
//                                       Icon(
//                                         Icons.star, // Full star
//                                         size: 16,
//                                         color: Colors.amber,
//                                       )
//                                     else if (averageRating >= i + 0.1)
//                                       Icon(
//                                         Icons.star_half, // Half star
//                                         size: 16,
//                                         color: Colors.amber,
//                                       )
//                                     else
//                                       Icon(
//                                         Icons.star_border, // Empty star
//                                         size: 16,
//                                         color: Colors.grey,
//                                       ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '${averageRating.toStringAsFixed(1)} / 5', // Show average rating
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => FullscreenImage(
//                                       imageUrl: widget.imageUrl,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Hero(
//                                 tag: widget.imageUrl,
//                                 child: Container(
//                                   width: 110,
//                                   height: 100,
//                                   color: _themeController.isDarkMode.value
//                                       ? const Color.fromARGB(255, 52, 52, 52)
//                                       : const Color.fromARGB(255, 240, 240, 240),
//                                   child: widget.imageUrl.isNotEmpty
//                                       ? Image.network(widget.imageUrl, fit: BoxFit.cover)
//                                       : const Icon(Icons.image, color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               SizedBox(
//                                 height: 27,
//                                 width: 60,
//                                 child: TextButton(
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: Color.fromRGBO(0, 54, 231, 1),
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(vertical: 4),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => PropertyDetailPage(
//                                           token: widget.token,
//                                           property: widget.property,
//                                           userEmail: widget.userEmail,
//                                           userRole: userRole,
//                                           profileStatus: profileStatus,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: const Text(
//                                     'View',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'manrope',
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 2),
//                               ShadTooltip(
//                                 builder: (context) => const Text('Save property'),
//                                 child: GestureDetector(
//                                   onTap: _bookmarkProperty,
//                                   child: Lottie.asset(
//                                    _themeController.isDarkMode.value? 'assets/icons/whitebm.json': 'assets/icons/blackbm.json',
//                                     height: 40,
//                                     controller: _controller,
//                                     onLoaded: (composition) {
//                                       _controller.duration = composition.duration;
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }