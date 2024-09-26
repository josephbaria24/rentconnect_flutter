import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/theme_controller.dart'; // For MIME type detection

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
  }

Future<void> _checkProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.13:3000/profile/checkProfileCompletion/$userId');
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
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Profile Submitted"),
        content: Text("Thank you for filling out your profile! Please wait for the admin to approve it."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the modal
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => NavigationMenu(token: widget.token), // Redirect to Home after submission
              ));
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}




Future<void> _updateProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.13:3000/profile/updateProfile');
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
    final url = Uri.parse('http://192.168.1.13:3000/updateUserInfo');
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

  Future<void> _uploadValidId() async {
    if (_validIdImage != null) {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://192.168.1.13:3000/profile/uploadValidId')
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _validIdImage = File(pickedFile.path);
      });
    }
  }

  void _removeValidIdImage() {
    setState(() {
      _validIdImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: _profileStatus == 'pending'
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your profile is currently being reviewed, please wait for the result.',
                style: TextStyle(fontSize: 18.0, color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255):const Color.fromARGB(255, 0, 0, 0)),
                textAlign: TextAlign.center,
              ),
            ),
          )
      :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: ['occupant', 'landlord'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _validIdImage != null ? _removeValidIdImage : _selectValidIdImage,
                  icon: Icon(_validIdImage != null ? Icons.delete : Icons.upload),
                  label: Text(_validIdImage != null ? 'Remove ID Image' : 'Upload ID Image'),
                ),
                if (_validIdImage != null) Text('ID image selected: ${_validIdImage!.path}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitProfileAndId,
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
