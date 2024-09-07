import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For file operations
import 'dart:convert'; // For JSON operations
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:http_parser/http_parser.dart'; // For MediaType

class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String email;
  late String userId;
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;
  bool _hasImageChanged = false; // Flag to track if image has changed

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    _fetchUserProfile();
    print('Initialized with email: $email and userId: $userId');
  }

  Future<void> _fetchUserProfile() async {
    final url = Uri.parse('http://192.168.1.13:3000/user/$userId'); // Adjust the endpoint if needed
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profileImageUrl = data['profilePicture']; // Update the URL variable
        });
      } else {
        print('Failed to load profile data');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Logged out, token removed from SharedPreferences');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _pickImage() async {
    print('Picking image...');
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _hasImageChanged = true; // Mark image as changed
      });
      print('Image picked: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage != null) {
      final url = Uri.parse('http://192.168.1.13:3000/updateProfilePicture/$userId');
      var request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer ${widget.token}';

      String mimeType = lookupMimeType(_profileImage!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;

      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          _profileImage!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody'); // Debug print

        // Parse the response
        final jsonResponse = jsonDecode(responseBody);
        print('Decoded response: $jsonResponse'); // Debug print

        // Check the 'message' field
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('message')) {
          final message = jsonResponse['message'];
          if (message == 'Profile picture updated successfully') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            _hasImageChanged = false; // Reset the flag after successful upload
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload profile picture')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected response format')));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading profile picture: $error')));
      }
    }
  }

  Future<void> _handleSave() async {
    print('Save button pressed.');
    setState(() {
      _isUpdating = true;
    });
    await _uploadProfilePicture();
    setState(() {
      _isUpdating = false;
    });
    print('Save button processing completed.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : _profileImageUrl != null
                            ? Image.network('http://192.168.1.13:3000/$_profileImageUrl', fit: BoxFit.cover)
                            : Image.asset("assets/images/profile.png"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white, size: 24),
                  onPressed: _pickImage,
                  padding: EdgeInsets.all(8),
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Joseph',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$email',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            if (_hasImageChanged) // Show the button only if there are changes
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: _isUpdating
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // Menu
            ProfileMenuWidget(
              title: "Personal Information",
              icon: LineAwesomeIcons.user,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePageChecker(token: widget.token),
                  ),
                );
              },
            ),
            ProfileMenuWidget(
              title: "Account Settings",
              icon: LineAwesomeIcons.cog_solid,
              onPress: () {},
            ),
            ProfileMenuWidget(
              title: "Listing",
              icon: LineAwesomeIcons.list_alt_solid,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CurrentListingPage(token: widget.token),
                  ),
                );
              },
            ),
            ProfileMenuWidget(
              title: "About",
              icon: LineAwesomeIcons.info_solid,
              onPress: () {},
            ),
            ProfileMenuWidget(
              title: "Logout",
              icon: LineAwesomeIcons.sign_out_alt_solid,
              textColor: Colors.red,
              endIcon: false,
              onPress: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color.fromRGBO(247, 40, 147, 0.1),
        ),
        child: Icon(
          icon,
          color: Color.fromRGBO(235, 94, 40, 1),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: const Color.fromRGBO(204, 197, 185, 0.2),
              ),
              child: const Icon(
                LineAwesomeIcons.angle_right_solid,
                size: 18.0,
                color: Color.fromRGBO(94, 94, 94, 1),
              ),
            )
          : null,
    );
  }
}
