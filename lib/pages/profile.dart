// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/colorController.dart';
import 'package:rentcon/main.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/about.dart';
import 'package:rentcon/pages/account_settings.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/pages/global_loading_indicator.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
   late ToastNotification toastNotification;

  @override
  void initState() {
    super.initState();
      toastNotification = ToastNotification(context);
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
        'https://rentconnect-backend-nodejs.onrender.com/user/$userId'); // Adjust the endpoint if needed
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
        'https://rentconnect-backend-nodejs.onrender.com/profile/checkProfileCompletion/$userId'); // Replace with your API endpoint
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



Future<void> _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Clear all session data
  await prefs.clear();

  // Show a toast notification before navigating to the login page
  toastNotification.success('You have been logged out successfully.');

  // Wait for a brief moment to let the toast display
  await Future.delayed(Duration(seconds: 2));

  Navigator.pushNamed(
    context, 
    '/login', // Remove all other routes to ensure no back navigation
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
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/updateProfilePicture/$userId');
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
          // Use your custom toast notification here
          ToastNotification(context).success('Profile picture updated successfully');
          _hasImageChanged = false; // Reset the flag after successful upload
        } else {
          // Use your custom toast notification for errors
          ToastNotification(context).error('Failed to upload profile picture');
        }
      } else {
        // Handle unexpected response format
        ToastNotification(context).error('Unexpected response format');
      }
    } catch (error) {
      // Use your custom toast notification for errors
      ToastNotification(context).error('Error uploading profile picture: $error');
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
      _fetchUserProfile();
    });
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
          appBar: AppBar(
  scrolledUnderElevation: 0,
  backgroundColor: _isDarkMode
      ? const Color.fromARGB(0, 0, 0, 0)
      : const Color.fromARGB(0, 241, 212, 212),
        actions: [
          Align(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                Visibility(
                  visible: !themeController.isDarkMode.value,
                  child: Text(
                    'Darkmode Off',
                    style: TextStyle(
                      fontFamily: 'geistsans',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Visibility(
                  visible: themeController.isDarkMode.value,
                  child: Text(
                    'Darkmode On',
                    style: TextStyle(
                      fontFamily: 'geistsans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.6,
                  child: CupertinoSwitch(
                    value: themeController.isDarkMode.value,
                    onChanged: (bool value) {
                      themeController.toggleTheme(value);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationMenu(
                            token: widget.token,
                            currentIndex: 4,
                          ),
                        ),
                      );
                    },
                    activeColor: const Color.fromARGB(255, 0, 233, 194),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    height: 0,
                  ),
                  GestureDetector(
                  onTap: () {
                    if (_profileImageUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenImage(imageUrl: _profileImageUrl!),
                        ),
                      );
                    }
                  },
                  child: Hero(
                    tag: _profileImageUrl ?? 'default_tag', // Provide a default tag if null
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 97, 97, 97)
                            : Color.fromARGB(190, 196, 196, 196),
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
                                            _profileImageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset("assets/images/profile.png"),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: SizedBox(
                                height: 31,
                                width: 31,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 100, 100, 100),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt_rounded,
                                      color: const Color.fromARGB(255, 255, 255, 255),
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
                  ShadTooltip(
                    showDuration:Duration(milliseconds: 1000),
                    builder: (context) => const Text('Your profile is verified'),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: themeController.isDarkMode.value?Colors.white: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        color: themeController.isDarkMode.value? const Color.fromARGB(255, 26, 26, 26):Color.fromARGB(255, 245, 245, 245),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0), // Adds some padding inside the container
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Ensures the row only takes the required space
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color.fromARGB(255, 0, 236, 157), // Check icon with green color
                              size: 16.0, // Icon size
                            ),
                            const SizedBox(width: 4), // Space between icon and text
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontFamily: 'geistsans',
                                fontWeight: FontWeight.w700,
                                color: themeController.isDarkMode.value
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ShadTooltip(
                    showDuration:Duration(milliseconds: 1000),
                    builder: (context) => const Text('Your profile is not verified yet.'),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: themeController.isDarkMode.value?Colors.white: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                        color: themeController.isDarkMode.value? const Color.fromARGB(255, 26, 26, 26):Color.fromARGB(255, 245, 245, 245),
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
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 20),
                  if (_hasImageChanged)
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 17.0), // Add padding for better touch target
                          elevation: 0, // Add shadow for depth
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          backgroundColor: themeController.isDarkMode.value
                              ? const Color.fromARGB(146, 77, 245, 181) // Dark background
                              : const Color.fromARGB(255, 77, 245, 181), // Light background
                        ),
                        child: _isUpdating
                            ? CupertinoActivityIndicator()
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
                    DeviceCard1(
                      title: "Listing",
                      icon: SvgPicture.asset('assets/icons/listing2.svg',
                          height: 20,
                          color: themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 253, 253, 253)
                              : const Color.fromARGB(255, 0, 0, 0)),
                      
                      textColor: themeController.isDarkMode.value
                          ? Colors.white
                          : const Color.fromARGB(255, 255, 255, 255),
                      endIcon: true,
                      icon2: Icon(Icons.chevron_right_outlined,
                          size: 20,
                          color: themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 253, 253, 253)
                              : const Color.fromARGB(255, 0, 0, 0)),
                      
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
                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Adaptable DeviceCard1
    Flexible(
      child: DeviceCard1(
        icon: SvgPicture.asset(
          'assets/icons/occupanthome.svg',
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 0, 0, 0),
          height: 20,
          width: 20,
        ),
        title: "My Home",
        textColor: themeController.isDarkMode.value
            ? Colors.white
            : const Color.fromARGB(255, 0, 0, 0),
        icon2: Icon(
          Icons.chevron_right_outlined,
          size: 20,
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(213, 253, 253, 253)
              : const Color.fromARGB(146, 0, 0, 0),
        ),
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OccupantInquiries(
                userId: userId,
                token: widget.token,
              ),
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 10), // Space between the two DeviceCards
    // Adaptable DeviceCard2
    Flexible(
      child: DeviceCard2(
        icon: SvgPicture.asset(
          'assets/icons/roommate.svg',
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 0, 0, 0),
          height: 20,
        ),
        title: "Roommates",
        textColor: themeController.isDarkMode.value
            ? Colors.black
            : Colors.black,
        icon2: Icon(
          Icons.chevron_right_outlined,
          size: 20,
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(213, 253, 253, 253)
              : const Color.fromARGB(146, 0, 0, 0),
        ),
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OccupantInquiries(
                userId: userId,
                token: widget.token,
              ),
            ),
          );
        },
      ),
    ),
  ],
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
class DeviceCard1 extends StatelessWidget {
  DeviceCard1({
    Key? key,
    required this.title,
    required this.icon,
    this.icon2,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final SvgPicture icon;
  final Icon? icon2;
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
            padding: const EdgeInsets.fromLTRB(2, 10, 3, 10),
            width: MediaQuery.of(context).size.width * 0.40,
            decoration: BoxDecoration(
              color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 0, 202, 169)
                  : const Color.fromARGB(255, 208, 252, 244),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: icon,
                ),
                // Wrap the text and icon in Flexible to prevent overflow
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'geistsans',
                      overflow: TextOverflow.ellipsis, // Add ellipsis to avoid overflow
                    ),
                  ),
                ),
                if (icon2 != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(8, 0, 0, 0),
                      ),
                      child: icon2,
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


class DeviceCard2 extends StatelessWidget {
  DeviceCard2({
    Key? key,
    required this.title,
    required this.icon,
    this.icon2,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final SvgPicture icon;
  final Icon? icon2;
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
            padding: const EdgeInsets.fromLTRB(1, 10, 3, 10),
            width: MediaQuery.of(context).size.width * 0.40,
            decoration: BoxDecoration(
              color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 0, 202, 108)
                  : const Color.fromARGB(255, 208, 252, 212),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: icon,
                ),
                // Make title flexible to avoid overflow
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'geistsans',
                      overflow: TextOverflow.ellipsis, // Avoid overflow with ellipsis
                    ),
                  ),
                ),
                if (icon2 != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(8, 0, 0, 0),
                      ),
                      child: icon2,
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
  height: 55,
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 10), // Adds space between tiles
  decoration: BoxDecoration(
    color: _themeController.isDarkMode.value
        ? const Color.fromARGB(255, 36, 37, 43)
        : const Color.fromARGB(255, 241, 241, 241), // Box background color
    borderRadius: BorderRadius.circular(12),
  ),
  child: Center( // Center the ListTile within the Container
    child: ListTile(
      onTap: onPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Adjust vertical padding
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: 'GeistSans',
            )?.apply(color: textColor ?? Colors.white),
      ),
      trailing: endIcon
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 28, 28, 30), // Trailing icon box background
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.chevron_right_outlined,
                size: 20.0,
                color: _themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 226, 226, 226)
                    : const Color.fromARGB(255, 0, 0, 0),
              ),
            )
          : null,
    ),
  ),
);

  }
}
