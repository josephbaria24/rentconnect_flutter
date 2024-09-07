import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // For MIME type detection

class PersonalInformation extends StatefulWidget {
  final String token; // Specify the type of token as String

  const PersonalInformation({required this.token, Key? key}) : super(key: key);

  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _validIdImage;
  final ImagePicker _picker = ImagePicker();
  bool _isProfileComplete = false; // This could be updated based on your logic
  late String email;
  late String userId;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    print("Decoded token - email: $email, userId: $userId");
    _checkProfileCompletion();
  }

Future<void> _checkProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.13:3000/profile/checkProfileCompletion/$userId');
  print("Checking profile completion for userId: $userId");

  try {
    final response = await http.get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
    print("Profile completion response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Profile completion response data: $responseData");

      // Check if 'status' key is present and is a boolean
      if (responseData.containsKey('status') && responseData['status'] is bool) {
        setState(() {
          _isProfileComplete = responseData['status'];
        });
      } else {
        print("Unexpected response data format: $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response format')),
        );
      }
    } else {
      print("Failed to check profile completion. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check profile completion')),
      );
    }
  } catch (error) {
    print("Error checking profile completion: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error checking profile completion')),
    );
  }
}


Future<void> _updateProfileCompletion() async {
  final url = Uri.parse('http://192.168.1.13:3000/profile/updateProfile');
  print("Updating profile for userId: $userId");

  try {
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}', // Ensure the token is included
      },
      body: jsonEncode({
        'userId': userId,
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'isProfileComplete': _isProfileComplete,
      }),
    );
    print("Update profile response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("Update profile response data: $responseData");

      if (responseData['status']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${responseData['message']}')),
        );
      }
    } else {
      print("Failed to update profile. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error')),
      );
    }
  } catch (error) {
    print("Error updating profile: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating profile')),
    );
  }
}


Future<void> _uploadValidId() async {
  if (_validIdImage != null) {
    print('Uploading valid ID image: ${_validIdImage!.path}'); // Debugging log

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('http://192.168.1.13:3000/profile/uploadValidId')
    );

    // Add the userId as a field in the request
    request.fields['userId'] = userId;

    // Add the image file
    String mimeType = lookupMimeType(_validIdImage!.path) ?? 'application/octet-stream';
    var fileExtension = mimeType.split('/').last;

    request.files.add(
      await http.MultipartFile.fromPath(
        'validIdImage', // Ensure this matches the backend field name
        _validIdImage!.path,
        contentType: MediaType('image', fileExtension),
      ),
    );

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload valid ID response status: ${response.statusCode}'); // Debugging log
      print('Upload valid ID response body: $responseBody'); // Debugging log

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Valid ID uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload valid ID: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed with status code: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No valid ID image selected')),
    );
  }
}



  void _selectValidIdImage() async {
    print("Selecting valid ID image");
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _validIdImage = File(pickedFile.path);
      });
      print("Selected valid ID image: ${_validIdImage!.path}");
    } else {
      print("No image selected");
    }
  }

  void _removeValidIdImage() {
    print("Removing valid ID image");
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isProfileComplete)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 85),
                  color: const Color.fromARGB(255, 220, 245, 220),
                  child: Text(
                    'Your profile is complete!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
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
                    SizedBox(height: 20),
                    if (_validIdImage != null)
                      Stack(
                        children: [
                          Image.file(_validIdImage!),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: _removeValidIdImage,
                            ),
                          ),
                        ],
                      )
                    else
                      Text('No valid ID image selected.'),
                    ElevatedButton(
                      onPressed: _selectValidIdImage,
                      child: Text('Select Valid ID Image'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print("Save button pressed");
                        if (_formKey.currentState?.validate() ?? false) {
                          // Set the profile as complete if the form is valid
                          setState(() {
                            _isProfileComplete = true;
                          });
                          print("Form is valid. Setting profile as complete and updating...");
                          _updateProfileCompletion();
                          _uploadValidId();
                        } else {
                          print("Form is invalid");
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
