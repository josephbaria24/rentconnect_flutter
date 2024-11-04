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
    final url = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/user/$userId');
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
        title: Text('Profile Details', style: TextStyle(fontFamily: 'Manrope')),
        backgroundColor: const Color.fromARGB(0, 247, 247, 247),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  width: 0.90,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                size: 16,
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
                      color: const Color.fromARGB(255, 0, 0, 0),
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
                                style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Manrope'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Profile Details
                  Text('Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                  SizedBox(height: 8),
                  ListTile(
                    title: Text('User ID', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['_id'] ?? 'N/A', style: TextStyle(fontFamily: 'Manrope')),
                  ),
                  ListTile(
                    title: Text('Email', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['email'] ?? 'N/A', style: TextStyle(fontFamily: 'Manrope')),
                  ),
                  ListTile(
                    title: Text('Role', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['role'] ?? 'N/A', style: TextStyle(fontFamily: 'Manrope')),
                  ),
                  ListTile(
                    title: Text('Phone', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['profile']?['contactDetails']?['phone'] ?? 'N/A', style: TextStyle(fontFamily: 'Manrope')),
                  ),
                  ListTile(
                    title: Text('Address', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['profile']?['contactDetails']?['address'] ?? 'N/A', style: TextStyle(fontFamily: 'Manrope')),
                  ),
                  ListTile(
                    title: Text('Profile Complete', style: TextStyle(fontFamily: 'Manrope')),
                    subtitle: Text(userDetails?['isProfileComplete'] == true ? "Yes" : "No", style: TextStyle(fontFamily: 'Manrope')),
                  ),
                ],
              ),
            ),
    );
  }
}
