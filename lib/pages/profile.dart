import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/pages/about.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:rentcon/theme_controller.dart';
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
  bool _isDarkMode = false; // To manage dark mode
  Map<String, dynamic>? userDetails;
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';

    _fetchUserProfile();
    print('Initialized with email: $email and userId: $userId');
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = isDark;
      prefs.setBool('isDarkMode', isDark);
      // Refresh the page
      Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    });
  }

  Future<void> _fetchUserProfile() async {
    final url = Uri.parse(
        'http://192.168.1.17:3000/user/$userId'); // Adjust the endpoint if needed
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userDetails = jsonDecode(response.body);
          _profileImageUrl = data['profilePicture']; // Update the URL variable
        });
      } else {
        print('No profile yet');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Clear all relevant user data
  await prefs.remove('token'); // Remove token
  // Add other data removal if necessary, e.g., user info, settings

  print('Logged out, token removed from SharedPreferences');

  // Ensure the navigation stack is cleared and user is redirected to login page
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your actual login page widget
    (route) => false, // Remove all other routes
  );
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
      final url =
          Uri.parse('http://192.168.1.17:3000/updateProfilePicture/$userId');
      var request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer ${widget.token}';

      String mimeType =
          lookupMimeType(_profileImage!.path) ?? 'application/octet-stream';
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
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('message')) {
          final message = jsonResponse['message'];
          if (message == 'Profile picture updated successfully') {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            _hasImageChanged = false; // Reset the flag after successful upload
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload profile picture')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected response format')));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading profile picture: $error')));
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

  final themeController = Get.put(ThemeController()); // Get theme controller


  @override
Widget build(BuildContext context) {
  return Obx(() => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove the back icon
          backgroundColor: themeController.isDarkMode.value
              ? Color.fromARGB(255, 28, 29, 34)
              : Color.fromRGBO(255, 255, 255, 1),
          actions: [
            IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.nights_stay_outlined
                    : Icons.wb_sunny_outlined, // Moon for dark mode, sun for light mode
                color: themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 108, 151, 245)
                    : const Color.fromARGB(255, 214, 182, 38),
              ),
              onPressed: () {
                themeController.toggleTheme(!themeController
                    .isDarkMode.value); // Toggle between dark and light mode
              },
            ),
          ],
        ),
        backgroundColor: themeController.isDarkMode.value
            ? Color.fromARGB(255, 28, 29, 34)
            : Color.fromRGBO(255, 255, 255, 1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Align children to the start of the column
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: themeController.isDarkMode.value? const Color.fromARGB(255, 42, 43, 36) : Color.fromARGB(125, 42, 43, 36),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _profileImage != null
                              ? Image.file(_profileImage!, fit: BoxFit.cover)
                              : _profileImageUrl != null
                                  ? Image.network(
                                      'http://192.168.1.17:3000/$_profileImageUrl',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset("assets/images/profile.png"),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt_rounded,
                                color: const Color.fromARGB(255, 56, 56, 56),
                                size: 17,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userDetails?['fullName'] ?? email,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black,
                    ),
              ),
              Text(
                '$userId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 177, 177, 177)
                          : Colors.black,
                    ),
              ),
              const SizedBox(height: 20),
              if (_hasImageChanged) // Show the button only if there are changes
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    child: _isUpdating
                        ? GlobalLoadingIndicator()
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                                color: themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 0, 0, 0)),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
              // Menu
              ProfileMenuWidget(
                title: "Personal Information",
                icon: LineAwesomeIcons.user,
                textColor: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePageChecker(token: widget.token),
                    ),
                  );
                },
              ),
              ProfileMenuWidget(
                title: "Account Settings",
                icon: LineAwesomeIcons.cog_solid,
                textColor: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Listing",
                icon: LineAwesomeIcons.list_alt_solid,
                textColor: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CurrentListingPage(token: widget.token),
                    ),
                  );
                },
              ),
              ProfileMenuWidget(
                title: "About",
                icon: LineAwesomeIcons.info_solid,
                textColor: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(token: widget.token),
                    ),
                  );
                },
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
      ));
}
}


class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.42,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class DeviceCard extends StatelessWidget {
  const DeviceCard({
    Key? key,
    required this.deviceName,
    required this.batteryLevel,
  }) : super(key: key);

  final String deviceName;
  final int batteryLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            deviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$batteryLevel%',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
   ProfileMenuWidget({
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
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: double.infinity,
      margin:  EdgeInsets.only(bottom: 10), // Adds space between tiles
      decoration: BoxDecoration(
      
        color: _themeController.isDarkMode.value ? Color.fromARGB(255, 36, 37, 43) :  Color.fromARGB(166, 241, 241, 241) , // Box background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onPress,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color.fromARGB(0, 28, 28, 30), // Icon background
          ),
          child: Icon(
            icon,
            color: _themeController.isDarkMode.value? const Color.fromARGB(255, 226, 226, 226) : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        title: Text(
          title,
          
          style: Theme.of(context)
          
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w400, fontSize: 15)
              ?.apply(color: textColor ?? Colors.white),
        ),
        trailing: endIcon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 28, 28, 30), // Trailing icon box background
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Icon(
                  Icons.arrow_forward_ios,
                  size: 18.0,
                  color: _themeController.isDarkMode.value? const Color.fromARGB(255, 226, 226, 226) : const Color.fromARGB(255, 0, 0, 0),
                ),
              )
            : null,
      ),
    );
  }
}