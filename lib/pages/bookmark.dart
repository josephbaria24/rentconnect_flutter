import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:rentcon/theme_controller.dart';
import 'toast.dart';
import 'global_loading_indicator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/models/property.dart';
import 'package:fluttertoast/fluttertoast.dart';
 // Make sure to import your theme controller

Future<List<Property>> getBookmarkedProperties(String token, String userId) async {
  final url = Uri.parse('https://rentconnect.vercel.app/getUserBookmarks/$userId'); 

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['status'] == true) {
        final List<dynamic> properties = data['properties'];
        return properties.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookmarked properties: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to load bookmarked properties. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error loading bookmarked properties: $error');
    throw Exception('Error loading bookmarked properties: $error');
  }
}

Future<void> removeBookmark(String token, String userId, String propertyId) async {
  final url = Uri.parse('https://rentconnect.vercel.app/removeBookmark');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'propertyId': propertyId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        print('Bookmark removed successfully');
      } else {
        print('Failed to remove bookmark: ${responseData['error']}');
        throw Exception('Failed to remove bookmark');
      }
    } else {
      print('Failed to remove bookmark. Status Code: ${response.statusCode}');
      throw Exception('Failed to remove bookmark');
    }
  } catch (error) {
    print('Error removing bookmark: $error');
    throw Exception('Error removing bookmark: $error');
  }
}

class BookmarkPage extends StatefulWidget {
  final String token;

  const BookmarkPage({required this.token, Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<Property>> bookmarkedProperties;
  late String email;
  late String userId;
  late FToast ftoast;
  late ToastNotification toast;
  final ThemeController _themeController = Get.find<ThemeController>();
 late ToastNotification toastNotification;
   String userRole = '';
  String profileStatus = 'none'; 
  @override
  void initState() {
    super.initState();
    ftoast = FToast();
    ftoast.init(context);
    toastNotification = ToastNotification(context);
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userID';
    bookmarkedProperties = getBookmarkedProperties(widget.token, userId);
  }


  Future<void> refreshBookmarks() async {
    setState(() {
      bookmarkedProperties = getBookmarkedProperties(widget.token, userId);
    });
  }

  Future<void> handleRemoveBookmark(String propertyId) async {
    try {
      await removeBookmark(widget.token, userId, propertyId);
      toastNotification.success("Successfully removed from bookmark!");
      await refreshBookmarks(); // Refresh the list after removing
    } catch (error) {
      toastNotification.error("Failed to remove from bookmarks!");
    }
  }

 Future<void> fetchUserProfileStatus() async {
    final url = Uri.parse('https://rentconnect.vercel.app/profile/checkProfileCompletion/$userId');
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
          userRole = jsonMap['userRole'] ?? 'none';
        });
      } else {
        print('Failed to fetch profile status');
      }
    } catch (error) {
      print('Error fetching profile status: $error');
    }
  }



    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Color.fromRGBO(252, 252, 252, 1),
        title: Row(
          children: [
            Text('Bookmark', style: TextStyle(
              fontFamily: 'manrope',
              fontSize: 22,
              fontWeight: FontWeight.w700
            ),),
            SizedBox(width: 5,),
            Lottie.asset('assets/icons/bookmarking2.json',
            repeat: false,
            height: 30)
          ],
        ),
      ),
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 28, 29, 34)
          : Color.fromRGBO(252, 252, 252, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: bookmarkedProperties,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Lottie.asset("assets/icons/houseloading2.json", height: 60));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the children vertically
                        crossAxisAlignment: CrossAxisAlignment.center, // Center the children horizontally
                        children: [
                          Lottie.asset('assets/icons/noBookmark.json', height: 240),
                          SizedBox(height: 20), // Space between icon and text
                          Text(
                            'No bookmarked properties.',
                            style: TextStyle(
                              fontFamily: 'manrope',
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Font size for the text
                              color:_themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black, // Text color
                            ),
                          ),
                        ],
                      ),
                    );

                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final property = snapshot.data![index];
                      final imageUrl = property.photo.startsWith('http')
                          ? property.photo
                          : 'https://rentconnect.vercel.app/${property.photo}';

                      return Card(
                        borderOnForeground: true,
                        color: _themeController.isDarkMode.value
                            ? Color.fromARGB(255, 36, 37, 43)
                            : const Color.fromARGB(255, 230, 230, 230),
                        elevation: 0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: ListTile(
                          title: Text(
                            property.description,
                            style: TextStyle(
                              fontFamily: 'manrope',
                              fontWeight: FontWeight.w600,
                              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${property.street}, Barangay ${property.barangay}',
                            style: TextStyle(
                              color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
                              fontFamily: 'manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0), // Set the radius here
                            child: Image.network(
                              imageUrl,
                              width: 80, // Adjust width if needed
                              height: 140, // Set the desired height here
                              fit: BoxFit.cover, // Ensure the image fits properly
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: const Color.fromARGB(255, 240, 8, 66)),
                            onPressed: () async {
                              await handleRemoveBookmark(property.id);
                            },
                          ),
                           onTap: () {
                            // Navigate to the PropertyDetails page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailPage(
                                  userRole: userRole,
                                  profileStatus: profileStatus,
                                  userEmail: email,
                                  token: widget.token,
                                  property: property
                                  ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}