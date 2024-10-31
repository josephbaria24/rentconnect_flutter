import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfileDetails extends StatefulWidget {
  final String token;
  const ProfileDetails({required this.token, Key? key}) : super(key: key);

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  late String email;
  late String userId;
  Map<String, dynamic>? userDetails;
  final ThemeController _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final url = Uri.parse('http://192.168.1.5:3000/user/$userId'); // Your new endpoint
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        setState(() {
          userDetails = jsonDecode(response.body);
        });
      } else {
        print("Failed to load user details. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
        backgroundColor: const Color.fromARGB(0, 247, 247, 247),
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
      body: userDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Profile Header
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(136, 76, 245, 208),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: userDetails?['profilePicture'] != null
                              ? NetworkImage('${userDetails?['profilePicture']}')
                              : null,
                          child: userDetails?['profilePicture'] == null
                              ? Icon(Icons.person, size: 40)
                              : null,  
                        ),
                        

                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userDetails?['profile']?['firstName'] ?? email} ${userDetails?['profile']?['lastName'] ?? ''}',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Profile Details
                  Text('Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ListTile(
                    title: Text('User ID'),
                    subtitle: Text(userDetails?['_id'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text(userDetails?['email'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: Text('Role'),
                    subtitle: Text(userDetails?['role'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: Text('Phone'),
                    subtitle: Text(userDetails?['profile']?['contactDetails']?['phone'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: Text('Address'),
                    subtitle: Text(userDetails?['profile']?['contactDetails']?['address'] ?? 'N/A'),
                  ),
                  ListTile(
                    title: Text('Profile Complete'),
                    subtitle: Text(userDetails?['isProfileComplete'] == true ? "Yes" : "No"),
                  ),
                ],
              ),
            ),
    );
  }
}
