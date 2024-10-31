// ignore_for_file: depend_on_referenced_packages, unused_import, library_private_types_in_public_api, use_super_parameters, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For MIME type detection

class PersonalInformation extends StatefulWidget {
  final String token; // Specify the type of token as String

  const PersonalInformation({required this.token, Key? key}) : super(key: key);

  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _gender = 'Male'; // Default gender value
  String _selectedRole = 'occupant'; // Default role value
  File? _validIdImage;
  final ImagePicker _picker = ImagePicker();
  bool _isProfileComplete = false;
  String _profileStatus = 'none';
  late String email;
  late String userId;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    _checkProfileCompletion();
    _fetchUserDetails();
  }

Future<void> _checkProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.5:3000/profile/checkProfileCompletion/$userId');
  try {
    final response = await http.get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('isProfileComplete') && responseData['isProfileComplete'] is bool) {
        setState(() {
          _isProfileComplete = responseData['isProfileComplete'];
        });
      }
      if (responseData.containsKey('profileStatus') && responseData['profileStatus'] is String) {
        setState(() {
          _profileStatus = responseData['profileStatus'];
        });
      }
    }
  } catch (error) {
    print("Error checking profile completion: $error");
  }
}


Future<void> _submitProfileAndId() async {
  if (_formKey.currentState!.validate()) {
    // Set isProfileComplete to false and profileStatus to pending
    _isProfileComplete = false; // Profile is incomplete until admin approval
    await _updateProfileCompletion();
    await _updateRole();

    if (_validIdImage != null) {
      await _uploadValidId();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid ID image selected')),
      );
    }

    // Show modal regardless of profile completion status
    _showThankYouModal();
  }
}


void _showThankYouModal() {
  showCupertinoDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text("Profile Submitted"),
        content: Text("Thank you for filling out your profile! Please wait for the admin to approve it."),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close the modal
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => NavigationMenu(token: widget.token), // Redirect to Home after submission
                ),
              );
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}




Future<void> _updateProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.5:3000/profile/updateProfile');
  try {
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'userId': userId,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'gender': _gender,
        'isProfileComplete': false,  // Profile is not complete yet
        'profileStatus': 'pending',  // Set profile status to pending
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile submitted and pending approval')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit profile')),
      );
    }
  } catch (error) {
    print("Error updating profile: $error");
  }
}



  Future<void> _updateRole() async {
    final url = Uri.parse('http://192.168.1.5:3000/updateUserInfo');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'userId': userId,
          'email' : email,
          'role' : _selectedRole
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role')),
        );
      }
    } catch (error) {
      print("Error updating profile: $error");
    }
  }

Map<String, dynamic>? userDetails;
Future<void> _fetchUserDetails() async {
  final url = Uri.parse('http://192.168.1.5:3000/user/$userId'); // Your new endpoint
  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      setState(() {
        userDetails = jsonDecode(response.body);

        // Populate the controllers with user data
        _firstNameController.text = userDetails?['profile']?['firstName'] ?? '';
        _lastNameController.text = userDetails?['profile']?['lastName'] ?? '';
        _phoneController.text = userDetails?['profile']?['contactDetails']['phone'] ?? '';
        _addressController.text = userDetails?['profile']?['contactDetails']['address'] ?? '';
        _gender = userDetails?['profile']?['gender'] ?? 'Male'; // Default to 'Male'
        _selectedRole = userDetails?['role'] ?? 'occupant'; // Default to 'occupant'
      });
    } else {
      print("Failed to load user details. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching user details: $e");
  }
}



  Future<void> _uploadValidId() async {
    if (_validIdImage != null) {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://192.168.1.5:3000/profile/uploadValidId')
      );
      request.fields['userId'] = userId;
      String mimeType = lookupMimeType(_validIdImage!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'validIdImage',
          _validIdImage!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Valid ID uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload valid ID')),
          );
        }
      } catch (error) {
        print("Error uploading valid ID: $error");
      }
    }
  }

void _selectValidIdImage() async {
  // Check and request permission
  final status = await Permission.photos.status;

  if (status.isDenied) {
    // Request permission if not granted
    final result = await Permission.photos.request();
    if (result.isDenied) {
      // If the user denies permission again, show a message
      print('Permission denied. Cannot select ID image.');
      return;
    }
  }

  // Proceed with picking the image
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _validIdImage = File(pickedFile.path);
    });
    print('ID image selected: ${pickedFile.path}');
  } else {
    print('No ID image selected.');
  }
}

  void _removeValidIdImage() {
    setState(() {
      _validIdImage = null;
    });
  }
bool _isFormComplete() {
  return _formKey.currentState!.validate() &&
         _validIdImage != null &&
         _gender != null &&
         _selectedRole != null;
}
@override
Widget build(BuildContext context) {
  print(userDetails?['profile']?['firstName']);
  return Scaffold(
    appBar: AppBar(
      title: Text('Personal Information', style: TextStyle(
        fontSize: 20.0,
        fontFamily: 'geistsans',
        fontWeight: FontWeight.w700,
        color: _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 255, 255, 255)
            : const Color.fromARGB(255, 0, 0, 0),
      ),),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
        child: SizedBox(
          height: 40, // Set a specific height for the button
          width: 40, // Set a specific width to make it a square button
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
    body: _profileStatus == 'pending'
        ? 
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your profile is currently being reviewed.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'geistsans',
                      fontWeight: FontWeight.w700,
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Please wait for the approval, Thank you!',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'geistsans',
                      fontWeight: FontWeight.w500,
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 198, 198, 198)
                          : const Color.fromARGB(255, 73, 73, 73),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50.0),
                  // Add the Lottie animation here
                  Lottie.network(
                    'https://lottie.host/5f367402-5bb5-4034-8d24-e7afdc572eef/lwQlfdeQpt.json', // Update the path to your Lottie JSON file
                   height: 300,
                  ),
                  SizedBox(height: 20.0), // Space between icon and text
                  ShadButton(
                    backgroundColor:_themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                  onPressed: () {
                    // Add your navigation logic here, for example:
                    Navigator.pop(context); // This will go back to the previous screen
                  },
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0, // Adjust font size as needed
                     color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 255, 255, 255),// Change text color if necessary
                    ),
                  ),
                )

                ],
              ),
            ),
          )

        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ShadInputFormField(
                            controller: _firstNameController,
                            placeholder: const Text('Enter your Firstname'),
                            label: Text(
                              'Firstname',
                              style: TextStyle(
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                            ),
                            cursorColor: _themeController.isDarkMode.value
                                ? Colors.black
                                : Colors.black, // Cursor color
                            style: TextStyle(
                              color: _themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black,
                            ), // Text input color
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16), // Add spacing between the two input fields
                        Expanded(
                          child: ShadInputFormField(
                            controller: _lastNameController,
                            placeholder: const Text('Enter your Lastname'),
                            label: Text(
                              'Last Name',
                              style: TextStyle(
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                            ),
                            cursorColor: _themeController.isDarkMode.value
                                ? Colors.white
                                : Colors.black, // Cursor color
                            style: TextStyle(
                              color: _themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black,
                            ), // Text input color
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ShadInputFormField(
                      controller: _phoneController,
                      placeholder: const Text('Enter your Phone Number'),
                      label: Text(
                        'Phone',
                        style: TextStyle(
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                      ),
                      cursorColor: _themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black, // Cursor color
                      style: TextStyle(
                        color: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                      ), // Text input color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    ShadInputFormField(
                      controller: _addressController,
                      placeholder: const Text('Enter your Address'),
                      label: Text(
                        'Address',
                        style: TextStyle(
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                      ),
                      cursorColor: _themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black, // Cursor color
                      style: TextStyle(
                        color: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                      ), // Text input color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10,),
                    // Gender selection using ShadSelect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gender", style: TextStyle(
                              fontFamily: 'geistsans',
                              color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 170),
                              child: ShadSelect<String>(
                                placeholder: Text('Select Gender',style: TextStyle(
                                  fontFamily: 'geistsans',
                                  color: _themeController.isDarkMode.value
                                                ? Colors.white
                                                : Colors.black,
                                  fontSize: 13,
                                  
                                ),),
                                options: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    
                                  ),
                                  ShadOption(value: 'Male', child: const Text('Male')),
                                  ShadOption(value: 'Female', child: const Text('Female')),
                                ],
                                selectedOptionBuilder: (context, value) => Text(value,style: TextStyle(
                                   color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                                    fontFamily: 'geistsans',
                                ),),
                                onChanged: (newValue) {
                                  setState(() {
                                    _gender = newValue!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Role", style: TextStyle(
                                      fontFamily: 'geistsans',
                                      color: _themeController.isDarkMode.value
                                                    ? Colors.white
                                                    : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                    ),),
                                SizedBox(width: 10,),
                                GestureDetector(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoPageScaffold(
                                         
                                          child: RoleSelectionDialog(),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "What is role?",
                                    style: TextStyle(
                                      fontFamily: 'geistsans',
                                      color: _themeController.isDarkMode.value
                                          ? const Color.fromARGB(255, 0, 150, 250)
                                          : const Color.fromARGB(255, 0, 87, 250),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Role selection using ShadSelect
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 170),
                              child: ShadSelect<String>(
                                
                                placeholder: Text('Select Role', style: TextStyle(
                                  fontFamily: 'geistsans',
                                  color: _themeController.isDarkMode.value
                                                ? Colors.white
                                                : Colors.black,
                                  fontSize: 13,
                                  
                                ),),
                                options: [
                                  
                                  ShadOption(value: 'occupant', child: const Text('Occupant')),
                                  ShadOption(value: 'landlord', child: const Text('Landlord')),
                                ],
                                selectedOptionBuilder: (context, value) => Text(value, style: TextStyle(
                                   color: _themeController.isDarkMode.value
                                            ? Colors.white
                                            : Colors.black,
                                    fontFamily: 'geistsans',
                                ),),
                                
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedRole = newValue!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black, // Background color based on theme
                        foregroundColor: _themeController.isDarkMode.value
                            ? Colors.black
                            : Colors.white, // Text and icon color based on theme
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                        ),
                      ),
                      onPressed: _validIdImage != null
                          ? _removeValidIdImage
                          : _selectValidIdImage,
                      icon: Icon(
                        _validIdImage != null ? Icons.delete : Icons.upload,
                      ),
                      label: Text(
                        _validIdImage != null ? 'Remove ID Image' : 'Upload ID Image',
                      ),
                    ),
                    if (_validIdImage != null)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 1, color: _themeController.isDarkMode.value? Colors.white: Colors.black)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(_validIdImage!.path), // Display the image
                              height: 200, // Set the height to your preference
                              fit: BoxFit.fitHeight, // Adjust image fit as needed
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0), // Add some spacing
                        
                      ],
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.green, // Background color based on theme
                      foregroundColor: _themeController.isDarkMode.value
                          ? Colors.black
                          : Colors.white, // Text color based on theme
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                      ),
                    ),
                    onPressed: () {
                      if (_isFormComplete()) {
                        _submitProfileAndId(); // Proceed with form submission
                      } else {
                        showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Incomplete Form'),
                            content: Text('Please fill in all fields and upload a valid ID image.'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                      }
                    },
                    child: Text('Submit'),
                  ),

                  ],
                ),
              ),
            ),
          ),
  );
}



}
// Create a stateful widget to handle role selection
class RoleSelectionDialog extends StatefulWidget {
  @override
  _RoleSelectionDialogState createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
    final ThemeController _themeController = Get.find<ThemeController>();

  // Add a state variable to manage the selected tab
  String _selectedTab = 'occupant';
   PageController _pageController1 = PageController();
   PageController _pageController2 = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Learn more about Roles',
        style: TextStyle(
          fontFamily: 'GeistSans',
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
        child: SizedBox(
          height: 40,  // Set a specific height for the button
          width: 40,   // Set a specific width to make it a square button
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
    resizeToAvoidBottomInset: true,
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ShadTabs<String>(
            value: _selectedTab,
            onChanged: (newTab) {
              setState(() {
                _selectedTab = newTab;
              });
            },
            tabBarConstraints: const BoxConstraints(maxWidth: 400),
            contentConstraints: const BoxConstraints(maxWidth: 400),
            tabs: [
              ShadTab(
                value: 'occupant',
                child: const Text('Occupant'),
                content: ShadCard(
                  backgroundColor: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 255, 255, 255),
                  title: Text(
                    'What is an Occupant?',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  description: const Text(
                    "Occupants are tenants who rent properties and enjoy the facilities offered by landlords.",
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
                        child: PageView(
                          controller: _pageController1,
                          onPageChanged: _onPageChanged,
                          children: [
                            // Page 1
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                Image.asset(
                                  'assets/icons/manage.png',
                                  height: 200,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Access available properties\n"
                                  "• Make reservations\n"
                                  "• Manage payments and inquiries",
                                  style: TextStyle(
                                    fontFamily: 'GeistSans',
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            // Page 2
                            Column(
                              children: [
                                const SizedBox(height: 24),
                                SvgPicture.asset(
                                  'assets/icons/interact.svg',
                                  height: 200,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Interact with landlords\n"
                                  "• Receive notifications for updates\n"
                                  "• Manage monthly payment through the app",
                                  style: TextStyle(
                                    fontFamily: 'GeistSans',
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            // Page 3
                            Column(
                              children: [
                                const SizedBox(height: 24),
                                SvgPicture.asset(
                                  'assets/icons/agreement.svg',
                                  height: 200,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "• Access documentation\n"
                                  "• Track lease agreements and conditions",
                                  style: TextStyle(
                                    fontFamily: 'GeistSans',
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16), // Space between PageView and indicator
                      // Smooth Page Indicator
                      SmoothPageIndicator(
                        controller: _pageController1,
                        count: 3,
                        effect: ExpandingDotsEffect(
                          activeDotColor: const Color.fromARGB(255, 255, 1, 85),
                          dotColor: Colors.grey,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ShadTab(
      value: 'landlord',
      child: const Text('Landlord'),
      content: ShadCard(
        backgroundColor: _themeController.isDarkMode.value
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'What is a Landlord?',
          style: TextStyle(
            color: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        description: const Text(
          "Landlords manage properties, interact with potential tenants, and oversee rental agreements.",
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
              child: PageView(
                controller: _pageController2,
                onPageChanged: _onPageChanged,
                children: [
                  // Page 1
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/icons/listmanage.png',
                        height: 200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• List and manage properties\n"
                        "• Approve or reject reservations\n"
                        "• Handle tenant inquiries",
                        style: TextStyle(
                          fontFamily: 'GeistSans',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  // Page 2
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/icons/track.png',
                        height: 200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Track rent payments\n"
                        "• Communicate with tenants\n"
                        "• Schedule property inspections",
                        style: TextStyle(
                          fontFamily: 'GeistSans',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  // Page 3
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/icons/viewpayment.png',
                        height: 200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• View payment history\n"
                        "• Manage documentation\n"
                        "• Oversee rental conditions",
                        style: TextStyle(
                          fontFamily: 'GeistSans',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Space between PageView and indicator
            // Smooth Page Indicator
            SmoothPageIndicator(
              controller: _pageController2,
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color.fromARGB(255, 255, 1, 85),
                dotColor: Colors.grey,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
              ),
            ),
          ],
        ),
      ),
    ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
