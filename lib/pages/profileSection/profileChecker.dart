import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/pages/profileSection/profile_details.dart';
import 'personalInformation.dart'; // Import the PersonalInformation page
 // Import your ProfilePage that displays the profile details

class ProfilePageChecker extends StatefulWidget {
  final String token;
  const ProfilePageChecker({required this.token, Key? key}) : super(key: key);

  @override
  _ProfilePageCheckerState createState() => _ProfilePageCheckerState();
}

class _ProfilePageCheckerState extends State<ProfilePageChecker> {
  late String email;
  late String userId;
  bool? isProfileComplete = false;


  @override
  void initState() {
    super.initState();
    email = JwtDecoder.decode(widget.token)['email']?.toString() ?? 'Unknown email';
    userId = JwtDecoder.decode(widget.token)['_id']?.toString() ?? 'Unknown userId';
    _checkProfileCompletion();
  }

 

  Future<void> _checkProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.18:3000/profile/checkProfileCompletion/$userId');

  try {
    final response = await http.get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Debugging: Print response data
      print('Response data: $responseData');

      setState(() {
        // Handle cases where `isProfileComplete` might be missing
        isProfileComplete = responseData['isProfileComplete'] ?? false;
      });

      // Debugging: Print profile completion status
      print('Profile completion status: $isProfileComplete');

      // Redirect based on profile completion status
      if (isProfileComplete == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetails(token: widget.token),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalInformation(token: widget.token),
          ),
        );
      }
    } else {
      print('Failed to check profile completion. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error checking profile completion: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isProfileComplete == null
            ? CircularProgressIndicator() // Show loading while checking
            : Text('Checking profile completion...'),
      ),
    );
  }
}
