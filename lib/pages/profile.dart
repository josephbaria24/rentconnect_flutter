import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/main.dart';
import 'package:rentcon/pages/about.dart';
import 'package:rentcon/pages/account_settings.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For file operations
import 'dart:convert'; // For JSON operations
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = false;
  late String email;
  late String userId;
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;
  bool _hasImageChanged = false; // Flag to track if image has changed
  bool _isDarkMode = false; // To manage dark mode
  Map<String, dynamic>? userDetails;
  String profileStatus = 'none'; // Default value
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    fetchUserProfileStatus();
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
        'http://192.168.1.31:3000/user/$userId'); // Adjust the endpoint if needed
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

  Future<void> fetchUserProfileStatus() async {
    final url = Uri.parse(
        'http://192.168.1.31:3000/profile/checkProfileCompletion/$userId'); // Replace with your API endpoint
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
      } else {
        print('Failed to fetch profile status');
      }
    } catch (error) {
      print('Error fetching profile status: $error');
    }
  }

  // Future<void> _logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Clear all relevant user data
  //   await prefs.clear(); // Use clear to remove all stored data

  //   // You can also clear specific values if needed:
  //   await prefs.remove('token');
  //   await prefs.remove('userId');
  //   await prefs.remove('email');

  //   print('Logged out, all session data removed from SharedPreferences');

  //   // If your app has any in-memory user/session data, make sure to reset them here
  //   // For example:
  //   // themeController.reset();  // Reset any in-memory state (e.g., theme, user settings)

  //   // Ensure the navigation stack is cleared and user is redirected to the login page
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) =>
  //             LoginPage()), // Replace with your actual login page widget
  //     (route) => false, // Remove all other routes to ensure no back navigation
  //   );
  // }

Future<void> _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Clear all session data
  await prefs.clear();

  // Navigate to login page
  MyApp.restartApp(context);
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => LoginPage(),
    ),
    (route) => false, // Remove all other routes to ensure no back navigation
  );

  // Restart the app after navigating to login page
  
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
          Uri.parse('http://192.168.1.31:3000/updateProfilePicture/$userId');
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

  void _refreshProfile() async {
    setState(() {
      _loading = true;
    });

    // Fetch profile data or perform your data fetching logic here
    await _fetchUserProfile();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? Color.fromARGB(255, 28, 29, 34)
              : Color.fromRGBO(255, 255, 255, 1),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Skeletonizer(
              enabled: _loading,
              enableSwitchAnimation: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  // Dark mode toggle icon placed at the top-right corner
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.scale(
                      scale: 0.8, // Adjust the scale to match iOS switch size
                      child: Switch(
                        value: themeController
                            .isDarkMode.value, // Reflect current mode
                        onChanged: (bool value) {
                          themeController
                              .toggleTheme(value); // Toggle dark/light mode
                        },
                        activeColor: const Color.fromARGB(255, 108, 151,
                            245), // Active thumb color for dark mode
                        inactiveThumbColor: const Color.fromARGB(
                            255, 214, 182, 38), // Thumb color for light mode

                        // Set thumbIcon property using your WidgetStateProperty for custom icon behavior
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Icon(
                                Icons.nights_stay,
                                color: Colors.black,
                              ); // Moon icon for dark mode
                            }
                            return const Icon(
                                Icons.wb_sunny); // Sun icon for light mode
                          },
                        ),

                        activeTrackColor: Colors.blue
                            .withOpacity(0.2), // Track color when active
                        inactiveTrackColor: Colors.yellow
                            .withOpacity(0.2), // Track color when inactive
                      ),
                    ),
                  ),

                  // Rest of the UI components
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 42, 43, 36)
                          : Color.fromARGB(125, 42, 43, 36),
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
                                  ? Image.file(_profileImage!,
                                      fit: BoxFit.cover)
                                  : _profileImageUrl != null
                                      ? Image.network(
                                          '$_profileImageUrl',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          "assets/images/profile.png"),
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
                                    color:
                                        const Color.fromARGB(255, 56, 56, 56),
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
                    '${userDetails?['profile']?['firstName'] ?? email} ${userDetails?['profile']?['lastName'] ?? ''}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GeistSans',
                          color: themeController.isDarkMode.value
                              ? Colors.white
                              : Colors.black,
                        ),
                  ),
                  if (profileStatus == 'approved')
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.isDarkMode.value? Colors.white:Color.fromARGB(255, 6, 0, 20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0), // Adds some padding inside the container
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Ensures the row only takes the required space
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green, // Check icon with green color
                            size: 16.0, // Icon size
                          ),
                          const SizedBox(width: 4), // Space between icon and text
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontFamily: 'geistsans',
                              fontWeight: FontWeight.w700,
                              color: themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.isDarkMode.value? Colors.white:Color.fromARGB(255, 6, 0, 20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0), // Adds some padding inside the container
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Ensures the row only takes the required space
                        children: [
                          const Icon(
                            Icons.not_interested_rounded,
                            color: Colors.red, // Check icon with green color
                            size: 16.0, // Icon size
                          ),
                          const SizedBox(width: 4), // Space between icon and text
                          Text(
                            'Unverified',
                            style: TextStyle(
                              fontFamily: 'geistsans',
                              fontWeight: FontWeight.w700,
                              color: themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  : const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  const SizedBox(height: 20),
                  if (_hasImageChanged)
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
                                        ? const Color.fromARGB(
                                            255, 255, 255, 255)
                                        : const Color.fromARGB(255, 0, 0, 0)),
                              ),
                      ),
                    ),
                  SizedBox(height: 20),
                  if (userRole == 'landlord' &&
                      profileStatus == 'approved') ...[
                    DeviceCard(
                      title: "Listing",
                      icon: SvgPicture.asset('assets/icons/listing2.svg',
                          height: 24,
                          color: themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 109, 50, 248)
                              : const Color.fromARGB(255, 253, 1, 77)),
                      textColor: themeController.isDarkMode.value
                          ? Colors.white
                          : const Color.fromARGB(255, 255, 255, 255),
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
                  ] else if (userRole == 'occupant' &&
                      profileStatus == 'approved') ...[
                    DeviceCard(
                      icon: SvgPicture.asset(
                        'assets/icons/occupanthome.svg',
                        color: themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Colors.white,
                        height: 24,
                        width: 24,
                      ),
                      title: "My Home",
                      textColor: themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black,
                      onPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OccupantInquiries(
                                    userId: userId, token: widget.token)));
                        // Navigate to "My Home" page
                      },
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
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
                    icon: Icons.settings,
                    textColor: themeController.isDarkMode.value
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 0, 0),
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AccountSettings(token: widget.token),
                        ),
                      );
                    },
                  ),
                  ProfileMenuWidget(
                    title: "About",
                    icon: Icons.info_outline_rounded,
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
                  icon: Icons.logout_rounded,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    _logout(context); // Pass context manually here
                  },
                ),

                ],
              ),
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
  DeviceCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final SvgPicture icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.42,
            decoration: BoxDecoration(
              color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 36, 37, 43)
                  : Color.fromARGB(255, 10, 0, 40),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: icon,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      margin: EdgeInsets.only(bottom: 10), // Adds space between tiles
      decoration: BoxDecoration(
        color: _themeController.isDarkMode.value
            ? Color.fromARGB(255, 36, 37, 43)
            : Color.fromARGB(166, 241, 241, 241), // Box background color
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
            color: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 226, 226, 226)
                : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: 'GeistSans')
              ?.apply(color: textColor ?? Colors.white),
        ),
        trailing: endIcon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      0, 28, 28, 30), // Trailing icon box background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18.0,
                  color: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 226, 226, 226)
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              )
            : null,
      ),
    );
  }
}
