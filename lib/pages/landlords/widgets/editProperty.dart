import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/landlords/roomCreation.dart';
import 'package:rentcon/pages/map/propertyLocationPicker.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To allow photo picking from gallery or camera
import 'package:http/http.dart' as http;

// class EditPropertyScreen extends StatefulWidget {
//   final String propertyId; // Pass the propertyId from the previous page
//   final Map<String, dynamic> propertyDetails; // To populate existing property data

//   EditPropertyScreen({required this.propertyId, required this.propertyDetails});

//   @override
//   _EditPropertyScreenState createState() => _EditPropertyScreenState();
// }

// class _EditPropertyScreenState extends State<EditPropertyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   late TextEditingController _descriptionController;
//   late TextEditingController _streetController;
//   late TextEditingController _barangayController;
//   late TextEditingController _cityController;
//   late TextEditingController _amenitiesController;
//   late TextEditingController _priceController;
//   late TextEditingController _roomCountController;
//   late TextEditingController _bathroomCountController;

//   XFile? _photo;
//   XFile? _photo2;
//   XFile? _photo3;
//   List<XFile?> _photos = [null, null, null]; // Photo array for multiple images

//   @override
//   void initState() {
//     super.initState();
//     // Populate controllers with existing property data
//     _descriptionController = TextEditingController(text: widget.propertyDetails['description']);
//     _streetController = TextEditingController(text: widget.propertyDetails['street']);
//     _barangayController = TextEditingController(text: widget.propertyDetails['barangay']);
//     _cityController = TextEditingController(text: widget.propertyDetails['city']);
//     _amenitiesController = TextEditingController(text: widget.propertyDetails['amenities']?.join(', '));
//     _priceController = TextEditingController(text: widget.propertyDetails['price'].toString());
//     _roomCountController = TextEditingController(text: widget.propertyDetails['rooms'].toString());
//     _bathroomCountController = TextEditingController(text: widget.propertyDetails['bathrooms'].toString());
//   }

//   // Function to pick images
//   Future<void> _pickImage(int index) async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       _photos[index] = pickedFile;
//     });
//   }

//   // Handle form submission
  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     Map<String, dynamic> updatedData = {
  //       'description': _descriptionController.text,
  //       'street': _streetController.text,
  //       'barangay': _barangayController.text,
  //       'city': _cityController.text,
  //       'amenities': _amenitiesController.text.split(',').map((e) => e.trim()).toList(),
  //       'price': double.parse(_priceController.text),
  //       'rooms': int.parse(_roomCountController.text),
  //       'bathrooms': int.parse(_bathroomCountController.text),
  //     };

  //     // Add the photos only if they are selected
  //     for (int i = 0; i < _photos.length; i++) {
  //       if (_photos[i] != null) {
  //         updatedData['photo${i + 1}'] = _photos[i]!.path; // Send photo paths
  //       }
  //     }

  //     try {
  //       // Make an HTTP request to update the property details in the database
  //       final response = await http.put(
  //         Uri.parse('http://192.168.1.115:3000/properties/${widget.propertyId}'), // Edit API endpoint
  //         headers: {
  //           'Content-Type': 'application/json',
  //           // Add any authorization headers if needed
  //         },
  //         body: json.encode(updatedData),
  //       );

  //       if (response.statusCode == 200) {
  //         // Success
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Property updated successfully')),
  //         );
  //         Navigator.pop(context);
  //       } else {
  //         // Handle error response
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to update property')),
  //         );
  //       }
  //     } catch (e) {
  //       // Handle any exceptions during the HTTP request
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred: $e')),
  //       );
  //     }
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Property'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _submitForm,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Property Description
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a property description';
//                   }
//                   return null;
//                 },
//               ),
//               // Street
//               TextFormField(
//                 controller: _streetController,
//                 decoration: InputDecoration(labelText: 'Street'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the street';
//                   }
//                   return null;
//                 },
//               ),
//               // Barangay
//               TextFormField(
//                 controller: _barangayController,
//                 decoration: InputDecoration(labelText: 'Barangay'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the barangay';
//                   }
//                   return null;
//                 },
//               ),
//               // City
//               TextFormField(
//                 controller: _cityController,
//                 decoration: InputDecoration(labelText: 'City'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the city';
//                   }
//                   return null;
//                 },
//               ),
//               // Price
//               TextFormField(
//                 controller: _priceController,
//                 decoration: InputDecoration(labelText: 'Price'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the price';
//                   }
//                   return null;
//                 },
//               ),
//               // Number of rooms
//               TextFormField(
//                 controller: _roomCountController,
//                 decoration: InputDecoration(labelText: 'Number of rooms'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the number of rooms';
//                   }
//                   return null;
//                 },
//               ),
//               // Number of bathrooms
//               TextFormField(
//                 controller: _bathroomCountController,
//                 decoration: InputDecoration(labelText: 'Number of bathrooms'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the number of bathrooms';
//                   }
//                   return null;
//                 },
//               ),
//               // Amenities
//               TextFormField(
//                 controller: _amenitiesController,
//                 decoration: InputDecoration(labelText: 'Amenities (comma-separated)'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter amenities';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               // Photos Section
//               Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(3, (index) {
//                   return Column(
//                     children: [
//                       _photos[index] != null
//                           ? Image.file(File(_photos[index]!.path), height: 50, width: 50)
//                           : Icon(Icons.image, size: 50),
//                       IconButton(
//                         icon: Icon(Icons.camera_alt),
//                         onPressed: () => _pickImage(index),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//               SizedBox(height: 20),
//               // Save Button
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// ignore_for_file: prefer_const_constructors


class EditProperty extends StatefulWidget {
  final String token;
  final String propertyId; // Pass the propertyId from the previous page
  final Map<String, dynamic> propertyDetails; 

  const EditProperty({required this.token, required this.propertyId, required this.propertyDetails, Key? key}) : super(key: key);

  @override
  _EditPropertyState createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController descriptionController;
  late TextEditingController streetController;
  late TextEditingController barangayController;
  late TextEditingController cityController;
  late TextEditingController amenitiesController;

  final ThemeController _themeController = Get.find<ThemeController>();

  File? _photo;
  File? _photo2;
  File? _photo3;
  File? _legalDocPhoto;
  File? _legalDocPhoto2;
  File? _legalDocPhoto3;
  String? _typeOfProperty;
  late String email;
  late String userId;
  final ImagePicker _picker = ImagePicker();
  LatLng? selectedLocation;
  var searchValue = '';

  final List<String> propertyTypes = [
    'Apartment',
    'Boarding House',
  ];

  


   Map<String, String> get filteredBarangays => {
        for (final barangay in barangayList)
          if (barangay.toLowerCase().contains(searchValue.toLowerCase()))
            barangay: barangay
      };



    final List<String> amenities = ['WiFi', 'Laundry', 'Parking', 'Pool', 'Study lounge'];
  final List<IconData> icons = [
    LineAwesomeIcons.wifi_solid,
    Icons.local_laundry_service,
    Icons.local_parking,
    Icons.pool,
    LineAwesomeIcons.book_open_solid
  ];
  final List<bool> selectedAmenities = [false, false, false, false, false];

  void toggleAmenity(int index) {
    setState(() {
      selectedAmenities[index] = !selectedAmenities[index];
    });
  }

  List<String> getSelectedAmenities() {
    List<String> selectedList = [];
    for (int i = 0; i < selectedAmenities.length; i++) {
      if (selectedAmenities[i]) {
        selectedList.add(amenities[i]);
      }
    }
    return selectedList;
  }

  @override
 void initState() {
  super.initState();
  final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
  descriptionController = TextEditingController(text: widget.propertyDetails['description']);
  streetController = TextEditingController(text: widget.propertyDetails['street']);
  barangayController = TextEditingController(text: widget.propertyDetails['barangay']);
  cityController = TextEditingController(text: widget.propertyDetails['city']);
  amenitiesController = TextEditingController(text: widget.propertyDetails['amenities']?.join(', '));
  email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
  userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
}


  Future<void> _selectPhoto(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (index) {
          case 1:
            _photo = File(pickedFile.path);
            break;
          case 2:
            _photo2 = File(pickedFile.path);
            break;
          case 3:
            _photo3 = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _selectLegalDocPhoto(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (index) {
          case 1:
            _legalDocPhoto = File(pickedFile.path);
            break;
          case 2:
            _legalDocPhoto2 = File(pickedFile.path);
            break;
          case 3:
            _legalDocPhoto3 = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _pickLocation() async {
    LatLng? location = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyLocationPicker(
          onLocationSelected: (LatLng loc) {
            setState(() {
              selectedLocation = loc;
            });
          },
        ),
      ),
    );

    if (location != null) {
      setState(() {
        selectedLocation = location;
      });
    }
  }

Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    Map<String, dynamic> updatedData = {
      'description': descriptionController.text,
      'street': streetController.text,
      'barangay': barangayController.text,
      'city': cityController.text,
      'amenities': amenitiesController.text.split(',').map((e) => e.trim()).toList(),
    };

    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.115:3000/properties/${widget.propertyId}'), // Edit API endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Check if the widget is still mounted before showing a SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Property updated successfully')),
          );
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CurrentListingPage(token: widget.token)));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update property')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }
}

  Future<void> _addPhotoToRequest(http.MultipartRequest request, File? photo, String fieldName) async {
    if (photo != null) {
      String mimeType = lookupMimeType(photo.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          photo.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to proceed to add rooms?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              child: Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showIncompleteFieldsDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Incomplete Fields'),
          content: Text('Please fill in all required fields.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

@override
void dispose() {
  descriptionController.dispose();
  streetController.dispose();
  barangayController.dispose();
  cityController.dispose();
  amenitiesController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Setup Your Property'),
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description', hintText: 'Enter description'),
            validator: (v) {
              if (v!.isEmpty) return 'Description cannot be empty.';
              return null;
            },
            maxLines: null, // Expands as the user types
          ),
          TextFormField(
            controller: streetController,
            decoration: InputDecoration(labelText: 'Street', hintText: 'Enter street'),
            validator: (v) {
              if (v!.isEmpty) return 'Street cannot be empty.';
              return null;
            },
            maxLines: null,
          ),
          // Barangay Dropdown
          DropdownButton<String>(
            value: selectedBarangay.isNotEmpty ? selectedBarangay : null,
            hint: Text('Select Barangay...'),
            items: barangayList.map((barangay) {
              return DropdownMenuItem(
                value: barangay,
                child: Text(barangay),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBarangay = value ?? '';
              });
            },
          ),
          TextFormField(
            controller: cityController,
            decoration: InputDecoration(labelText: 'City', hintText: 'Puerto Princesa City'),
            enabled: false,
          ),
          // Amenities selection
          Text('Amenities'),
          Wrap(
            children: List.generate(amenities.length, (index) {
              return ElevatedButton(
                onPressed: () => toggleAmenity(index),
                child: Text(amenities[index]),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    selectedAmenities[index] ? Colors.green : Colors.grey,
                  ),
                ),
              );
            }),
          ),
          TextFormField(
            controller: amenitiesController,
            decoration: InputDecoration(hintText: 'Other:'),
          ),
          // Type of Property
          DropdownButton<String>(
            value: _typeOfProperty,
            hint: Text('Select Type of Property'),
            items: propertyTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _typeOfProperty = newValue;
              });
            },
          ),
          // Select Location
          ElevatedButton(
            onPressed: _pickLocation,
            child: Text(selectedLocation == null ? 'Select Location' : 'Location Selected'),
          ),
          // Property Photos
          Text('Property Photos'),
          Row(
            children: [
              _buildPhotoBox(1, _photo, _selectPhoto),
              SizedBox(width: 10),
              _buildPhotoBox(2, _photo2, _selectPhoto),
              SizedBox(width: 10),
              _buildPhotoBox(3, _photo3, _selectPhoto),
            ],
          ),
          // Legal Document Photos
          Text('Legal Document Photos'),
          Row(
            children: [
              Column(
                children: [
                  Text('Business Permit'),
                  _buildPhotoBox(1, _legalDocPhoto, _selectLegalDocPhoto),
                ],
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text('FSIC'),
                  _buildPhotoBox(2, _legalDocPhoto2, _selectLegalDocPhoto),
                ],
              ),
            ],
          ),
           ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Changes'),
              ),
        ],
        
      ),
      
    ),
  );
}

  String selectedBarangay = '';
  final List<String> barangayList = [
    'Babuyan',
    'Bacungan',
    'Bagong Bayan',
    'Bagong Pag-Asa',
    'Bagong Sikat',
    'Bagong Silang',
    'Bahile',
    'Bancao-bancao',
    'Binduyan',
    'Buenavista',
    'Cabayugan',
    'Concepcion',
    'Inagawan',
    'Inagawan Sub-Colony',
    'Irawan',
    'Iwahig',
    'Kalipay',
    'Kamuning',
    'Langogan',
    'Liwanag',
    'Lucbuan',
    'Luzviminda',
    'Mabuhay',
    'Macarascas',
    'Magkakaibigan',
    'Maligaya',
    'Manalo',
    'Mandaragat',
    'Manggahan',
    'Mangingisda',
    'Maningning',
    'Maoyon',
    'Marufinas',
    'Maruyogon',
    'Masigla',
    'Masikap',
    'Masipag',
    'Matahimik',
    'Matiyaga',
    'Maunlad',
    'Milagrosa',
    'Model',
    'Montible',
    'Napsan',
    'New Panggangan',
    'Pagkakaisa',
    'Princesa',
    'Salvacion',
    'San Jose',
    'San Manuel',
    'San Miguel',
    'San Pedro',
    'San Rafael',
    'Santa Cruz',
    'Santa Lourdes',
    'Santa Lucia',
    'Santa Monica',
    'San Isidro',
    'Sicsican',
    'Simpocan',
    'Tagabinet',
    'Tagburos',
    'Tagumpay',
    'Tanabag',
    'Tanglaw',
    'Tiniguiban',
  ];


bool _areFieldsFilled() {
            // Add your validation logic here, for example:
            return selectedLocation != null 
            && _typeOfProperty != null 
            && _photo != null 
            && _legalDocPhoto != null // Example condition
            && selectedBarangay != null // Example condition
            && descriptionController != null
            && streetController != null
            && amenitiesController != null
            && descriptionController != null;
          }

          // Function to show Cupertino Dialog
          void _showCupertinoDialog(BuildContext context) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Incomplete Fields'),
                  content: const Text('Please fill in all the required fields before proceeding.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }

Widget _buildPhotoBox(int index, File? photo, Function(int) onSelectPhoto) {
  return GestureDetector(
    onTap: () => onSelectPhoto(index),
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
      ),
      child: photo == null
          ? Center(child: Text('Photo $index',
          style: TextStyle(
            fontFamily: 'manrope',
            color: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(255, 255, 255, 255),
          ),))
          : ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Ensures image respects the same border radius
              child: Image.file(
                photo,
                fit: BoxFit.cover,
              ),
            ),
    ),
  );
}

}








