// ignore_for_file: prefer_const_constructors

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
import 'package:rentcon/pages/landlords/roomCreation.dart';
import 'package:rentcon/pages/map/propertyLocationPicker.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Addlisting extends StatefulWidget {
  final String token;
  const Addlisting({required this.token, Key? key}) : super(key: key);

  @override
  _AddlistingState createState() => _AddlistingState();
}

class _AddlistingState extends State<Addlisting> {
  bool _isSubmitting = false;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController barangayController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController amenitiesController = TextEditingController();
  
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

  final List<String> propertyTypes  = [
    'Apartment',
    'Boarding House',
  ];
  

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

  Future<void> _submitProperty() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.18:3000/storeProperty'));

    request.fields['userId'] = userId;
    request.fields['description'] = descriptionController.text;

    // Set the address fields
    request.fields['street'] = streetController.text.trim();
    request.fields['barangay'] = selectedBarangay.isNotEmpty 
    ? selectedBarangay 
    : '';  // Pass the selected barangay to the request
    request.fields['city'] = 'Puerto Princesa City';



    List<String> selectedAmenitiesList = getSelectedAmenities();
    String otherAmenities = amenitiesController.text.trim();
    if (otherAmenities.isNotEmpty) {
      selectedAmenitiesList.add(otherAmenities); // Add the other amenities to the list
    } 
  // Convert the list to a JSON string
    request.fields['amenities'] = jsonEncode(selectedAmenitiesList);

    // request.fields['amenities'] = amenitiesController.text.split(',').join(',');
    
    request.fields['typeOfProperty'] = _typeOfProperty ?? '';

    var location = {
      'type': 'Point',
      'coordinates': [selectedLocation!.longitude, selectedLocation!.latitude]
    };
    request.fields['location'] = jsonEncode(location);

    // Upload Property Photos
    if (_photo != null) {
      String mimeType = lookupMimeType(_photo!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _photo!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    if (_photo2 != null) {
      String mimeType = lookupMimeType(_photo2!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo2',
          _photo2!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    if (_photo3 != null) {
      String mimeType = lookupMimeType(_photo3!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo3',
          _photo3!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    // Upload Legal Document Photos
    if (_legalDocPhoto != null) {
      String mimeType = lookupMimeType(_legalDocPhoto!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'legalDocPhoto',
          _legalDocPhoto!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    if (_legalDocPhoto2 != null) {
      String mimeType = lookupMimeType(_legalDocPhoto2!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'legalDocPhoto2',
          _legalDocPhoto2!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    if (_legalDocPhoto3 != null) {
      String mimeType = lookupMimeType(_legalDocPhoto3!.path) ?? 'application/octet-stream';
      var fileExtension = mimeType.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'legalDocPhoto3',
          _legalDocPhoto3!.path,
          contentType: MediaType('image', fileExtension),
        ),
      );
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseJson = jsonDecode(responseBody);
      var propertyId = responseJson['propertyId'];

      if (propertyId == null || propertyId.isEmpty) {
        print("Error: propertyId is null or empty");
        return;
      }

      bool confirm = await _showConfirmationDialog();
      if (confirm) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomCreationPage(
              token: widget.token,
              propertyId: propertyId,
            ),
          ),
        );
      }
    } catch (error) {
      print("Error occurred: $error");
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


// Method to show a CupertinoDialog if fields are incomplete
void _showIncompleteFieldsDialog() {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Incomplete Fields'),
        content: Text('Please fill all required fields before proceeding.'),
        actions: <Widget>[
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
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34) : Colors.white ,
    appBar: AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34) : Colors.white ,
      title: Text('Setup Your Property',
      style: TextStyle(
        fontFamily: 'GeistSans',
        fontWeight: FontWeight.bold
      ),),
      leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
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
    body: Padding(
      
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [

          
          ShadInputFormField(
            cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10), 
            style: TextStyle(
              color:_themeController.isDarkMode.value? Colors.white: Colors.black
            ),
            id: 'description',
            label: Text('Description',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
            ),),
            placeholder: const Text('Enter description'),
            description: const Text('Provide a detailed description.'),
            validator: (v) {
              if (v.isEmpty) {
                return 'Description cannot be empty.';
              }
              return null;
            },
            controller: descriptionController,
            minLines: 1, // Start with one line
            maxLines: null, // Expands as the user types
            keyboardType: TextInputType.multiline, // Allow multi-line input
          ),


          ShadInputFormField(
            cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10), 
            id: 'street',
            style: TextStyle(
              color:_themeController.isDarkMode.value? Colors.white: Colors.black
            ),
            label: Text('Street',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
            ),),
            placeholder: const Text('Enter street'),
            
            validator: (v) {
              if (v.isEmpty) {
                return 'Street cannot be empty.';
              }
              return null;
            },
            controller: streetController,
            minLines: 1, // Start with one line
            maxLines: null, // Expands as the user types
            keyboardType: TextInputType.multiline, // Allow multi-line input
          ),
          SizedBox(height: 10,),


          // Barangay Dropdown
          Text(
            'Barangay',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          ShadSelect<String>.withSearch(
  minWidth: 180,
  placeholder: Text(
    'Select Barangay...',
    style: TextStyle(
      color: _themeController.isDarkMode.value
          ? const Color.fromARGB(255, 255, 255, 255)
          : const Color.fromARGB(255, 134, 134, 134),
    ),
  ),
  onSearchChanged: (value) => setState(() => searchValue = value),
  searchPlaceholder: const Text('Search Barangay'),
  options: [
    if (filteredBarangays.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No barangay found'),
      ),
    ...barangayList.map(
      (barangay) {
        return Offstage(
          offstage: !filteredBarangays.containsKey(barangay),
          child: ShadOption(
            value: barangay,
            child: Text(barangay),
          ),
        );
      },
    ),
  ],
  initialValue: selectedBarangay.isNotEmpty ? selectedBarangay : null, // Initialize with the selected value
  onChanged: (value) {
    setState(() {
      selectedBarangay = value ?? ''; // Store the selected barangay
    });
  },
  selectedOptionBuilder: (context, value) => Text(
    value ?? 'Select Barangay',
    style: TextStyle(
      color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
    ),
  ),
),


          SizedBox(height: 10,),

          // City / Municipality (Static Field)
          ShadInputFormField(
             //padding: EdgeInsets.symmetric(vertical: 1), // Adjust this for height
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black
            ),
            controller: cityController,
            enabled: false,
            label: Text('City',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
            ),),
            placeholder: Text('Puerto Princesa City',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black
            ),),
             padding: EdgeInsets.fromLTRB(5, 10, 5, 15), // Adjust this for height
          ),

          SizedBox(height: 20),

          Text(
            'Amenities',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),

          Wrap(
            spacing: 8.0, // Horizontal space between buttons
            runSpacing: 8.0, // Vertical space between buttons
            children: List.generate(amenities.length, (index) {
              return ElevatedButton.icon(
                onPressed: () => toggleAmenity(index),
                icon: Icon(icons[index]),
                label: Text(amenities[index]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAmenities[index] ? const Color.fromARGB(246, 0, 209, 164) : const Color.fromARGB(255, 122, 120, 136), // Button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                  )
                ),
              );
            }),
          ),
        
          SizedBox(height: 16), // Space between buttons and input field
        
        // Other Amenities Input Field
          ShadInput(
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'GeistSans',
              //fontWeight: FontWeight.normal,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
            controller: amenitiesController,
            placeholder: Text('Other:'),
          ),

          SizedBox(height: 20),
          Text(
            'Type Of Property',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          ShadSelect<String>(
          placeholder: Text(
            'Select Type of Property',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          options: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 6, 6),
            ),
            ...propertyTypes.map((type) => ShadOption(value: type, child: Text(type))).toList(),
          ],
          initialValue: _typeOfProperty ?? null,  // Initialize with the selected value
          selectedOptionBuilder: (context, value) => Text(
            value ?? 'Select Type of Property',
            style: TextStyle(
              fontFamily: 'geistsans',
              fontWeight: FontWeight.w500,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _typeOfProperty = newValue; // Store the selected property type
            });
          },
        ),




          SizedBox(height: 20),
          
          Text(
            'Select Location',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          ShadButton(
            backgroundColor: _themeController.isDarkMode.value?
            Color.fromARGB(255, 255, 255, 255): Color.fromARGB(255, 13, 0, 40),
            onPressed: _pickLocation,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Ensures the Row takes up minimum space
              children: [
                if (selectedLocation != null) ...[
                  Icon(Icons.check, color: Colors.green), // Check icon displayed if location is selected
                  const SizedBox(width: 4), // Small space between icon and text
                ],
                Text(
                  selectedLocation == null
                      ? 'Select Location'
                      : 'Location Selected',
                  style: TextStyle(
                    color: selectedLocation == null ? _themeController.isDarkMode.value? const Color.fromARGB(255, 0, 0, 0): Colors.white : Colors.green, // Change text color based on selection
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          Text(
            'Property Photos',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          Row(
            children: [
              _buildPhotoBox(1, _photo, _selectPhoto),
              SizedBox(width: 10),
              _buildPhotoBox(2, _photo2, _selectPhoto),
              SizedBox(width: 10),
              _buildPhotoBox(3, _photo3, _selectPhoto),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Legal Document Photos',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
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
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text('other permit'),
                  _buildPhotoBox(3, _legalDocPhoto3, _selectLegalDocPhoto),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ShadButton(
              height: 50,
              width: 10,
              backgroundColor: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 13, 0, 40),
              onPressed: () async {
                if (_areFieldsFilled()) {
                  setState(() {
                    _isSubmitting = true; // Set to true when the button is pressed
                  });
                  
                  await _submitProperty(); // Wait for the submission to complete

                  setState(() {
                    _isSubmitting = false; // Reset to false after submission
                  });
                } else {
                  _showCupertinoDialog(context);
                }
              },
              child: _isSubmitting // Check if submitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Proceed to room',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: _themeController.isDarkMode.value
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ],
                    ),
            )
          // Function to check if fields are filled
          

        ],
      ),
    ),
  );
}

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
            fontFamily: 'geistsans',
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
