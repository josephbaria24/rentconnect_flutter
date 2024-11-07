// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rentcon/pages/map/propertyLocationPicker.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UpdateProperty extends StatefulWidget {
  final String token;
  final String propertyId; // Pass the propertyId from the previous page
  final Map<String, dynamic> propertyDetails; // Property details are passed directly

  const UpdateProperty({
    required this.token,
    required this.propertyId,
    required this.propertyDetails,
    Key? key,
  }) : super(key: key);

  @override
  _UpdatePropertyState createState() => _UpdatePropertyState();
}

class _UpdatePropertyState extends State<UpdateProperty> {
  late TextEditingController descriptionController;
  late TextEditingController streetController;
  late TextEditingController barangayController;
  late TextEditingController cityController;
  late TextEditingController typeOfPropertyController;
  late TextEditingController amenitiesController;
  late ToastNotification toastNotification;
    
  String selectedBarangay = '';
  String searchValue = '';
  LatLng? selectedLocation; // Add this to your state variables
  

  //location
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

//




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

  Map<String, String> get filteredBarangays {
    return {
      for (final barangay in barangayList)
        if (barangay.toLowerCase().contains(searchValue.toLowerCase()))
          barangay: barangay
    };
  }




  String? _typeOfProperty; // Changed to nullable for initial value
  final List<String> propertyTypes = [
    'Apartment',
    'Boarding House',
  ];
  final ThemeController _themeController = Get.find<ThemeController>();

  final ImagePicker _picker = ImagePicker();
  File? _photo;
  File? _photo2;
  File? _photo3;
  File? _legalDocPhoto;
  File? _legalDocPhoto2;
  File? _legalDocPhoto3;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add this line




  // Amenities
  // final List<String> amenities = ['WiFi', 'Laundry', 'Parking', 'Pool', 'Study lounge'];
  // final List<IconData> icons = [
  //   Icons.wifi,
  //   Icons.local_laundry_service,
  //   Icons.local_parking,
  //   Icons.pool,
  //   Icons.book,
  // ];
List<String> amenities = ['WiFi', 'Laundry', 'Parking', 'Pool', 'Study lounge'];

List<IconData> icons = [Icons.wifi, Icons.local_laundry_service, Icons.local_parking, Icons.pool, Icons.book];
late List<bool> selectedAmenities;// Initialize with a default value

  // final List<bool> selectedAmenities = [false, false, false, false, false];
void toggleAmenity(int index) {
  setState(() {
    selectedAmenities[index] = !selectedAmenities[index];
    print('Toggled amenity at index $index: ${selectedAmenities[index]}'); // Debugging line
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
     initializeSelectedAmenities();
     initializeAmenitiesString();
     toastNotification = ToastNotification(context);
     print('Selected amenities after initialization: $selectedAmenities');
    // Use the passed property details to initialize the form fields
    descriptionController = TextEditingController(text: widget.propertyDetails['description']);
    streetController = TextEditingController(text: widget.propertyDetails['street']);
    barangayController = TextEditingController(text: widget.propertyDetails['barangay']);
    cityController = TextEditingController(text: widget.propertyDetails['city']);
    typeOfPropertyController = TextEditingController(text: widget.propertyDetails['typeOfProperty']);
    amenitiesController = TextEditingController(
    text: '', 
  );
  
  }


  late String amenitiesString; // Declare the variable to hold the formatted string

  void initializeAmenitiesString() {
    // Join the amenities into a user-friendly string
    amenitiesString = amenities.join(', ');
  }


void initializeSelectedAmenities() {
  // Debugging: Print the raw amenities data
  var amenitiesData = widget.propertyDetails['amenities'];
  print('Raw amenities data: $amenitiesData'); // Debugging line

  // Ensure amenitiesData is a non-empty List and contains another List
  if (amenitiesData is List && amenitiesData.isNotEmpty && amenitiesData[0] is List) {
    // Extract the first inner list of amenities
    List<String> fetchedAmenities = (amenitiesData[0] as List<dynamic>).cast<String>();

    // Debugging: Print fetched amenities
    print('Fetched amenities: $fetchedAmenities');

    // Initialize selectedAmenities based on the fetched amenities
    selectedAmenities = List.generate(amenities.length, (index) {
      // Check if the amenity exists in the fetched list and return true if it does
      bool isSelected = fetchedAmenities.contains(amenities[index]);
      print('Checking if "${amenities[index]}" is in fetched amenities: $isSelected'); // Debugging line
      return isSelected;
    });

    // Debugging: Print initialized selected amenities
    print('Initialized selected amenities: $selectedAmenities');
  } else {
    // Initialize selectedAmenities with false if no amenities are available
    selectedAmenities = List.filled(amenities.length, false);
    print('No amenities found, initialized to false: $selectedAmenities');
  }
}



Future<void> _selectPhoto(int index) async {
   final ImagePicker _picker = ImagePicker();

  // Show a modal or bottom sheet to let the user choose between gallery and camera
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery', style: TextStyle(fontFamily: 'manrope')),
              onTap: () async {
                Navigator.of(context).pop();

                // Use FilePicker to select an image from the gallery
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );

                if (result != null && result.files.single.path != null) {
                  setState(() {
                    switch (index) {
                      case 1:
                        _photo = File(result.files.single.path!);
                        break;
                      case 2:
                        _photo2 = File(result.files.single.path!);
                        break;
                      case 3:
                        _photo3 = File(result.files.single.path!);
                        break;
                    }
                  });
                  print('Photo selected from gallery for index $index: ${result.files.single.path}');
                } else {
                  print('No photo selected from gallery.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo', style: TextStyle(fontFamily: 'manrope')),
              onTap: () async {
                Navigator.of(context).pop();

                // Use ImagePicker to capture an image using the camera
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
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
                  print('Photo captured with camera for index $index: ${pickedFile.path}');
                } else {
                  print('No photo captured.');
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


 Future<void> _selectLegalDocPhoto(int index) async {
  final ImagePicker _picker = ImagePicker();

  // Show a modal or bottom sheet to let the user choose between gallery and camera
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery', style: TextStyle(fontFamily: 'manrope')),
              onTap: () async {
                Navigator.of(context).pop();

                // Use FilePicker to select an image from the gallery
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );

                if (result != null && result.files.single.path != null) {
                  setState(() {
                    switch (index) {
                      case 1:
                        _legalDocPhoto = File(result.files.single.path!);
                        break;
                      case 2:
                        _legalDocPhoto2 = File(result.files.single.path!);
                        break;
                      case 3:
                        _legalDocPhoto3 = File(result.files.single.path!);
                        break;
                    }
                  });
                  print('Legal document photo selected from gallery for index $index: ${result.files.single.path}');
                } else {
                  print('No legal document photo selected from gallery.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo', style: TextStyle(fontFamily: 'manrope')),
              onTap: () async {
                Navigator.of(context).pop();

                // Use ImagePicker to capture an image using the camera
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
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
                  print('Legal document photo captured with camera for index $index: ${pickedFile.path}');
                } else {
                  print('No legal document photo captured.');
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
 Future<void> updateProperty() async {
    // Collect the selected amenities
    List<String> selectedAmenitiesList = getSelectedAmenities();
    String amenitiesJson = jsonEncode(selectedAmenitiesList); // Convert selected amenities to JSON

    final Uri uri = Uri.parse('https://rentconnect.vercel.app/properties/${widget.propertyId}');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer ${widget.token}';

    // Add the text fields
    request.fields['description'] = descriptionController.text;
    request.fields['street'] = streetController.text;
    request.fields['barangay'] = selectedBarangay; // Use selectedBarangay for the barangay field
    request.fields['city'] = cityController.text;
    request.fields['typeOfProperty'] = _typeOfProperty ?? ''; // Add selected property type
    request.fields['amenities'] = amenitiesJson; // Add amenities as JSON

      // Add location to the request

     var location = {
      'type': 'Point',
      'coordinates': [selectedLocation!.longitude, selectedLocation!.latitude]
    };
    request.fields['location'] = jsonEncode(location);


    // Add the photo files if they are selected
    if (_photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _photo!.path, contentType: MediaType('image', 'jpeg')));
    }
    if (_photo2 != null) {
      request.files.add(await http.MultipartFile.fromPath('photo2', _photo2!.path, contentType: MediaType('image', 'jpeg')));
    }
    if (_photo3 != null) {
      request.files.add(await http.MultipartFile.fromPath('photo3', _photo3!.path, contentType: MediaType('image', 'jpeg')));
    }
    if (_legalDocPhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('legalDocPhoto', _legalDocPhoto!.path, contentType: MediaType('image', 'jpeg')));
    }
    if (_legalDocPhoto2 != null) {
      request.files.add(await http.MultipartFile.fromPath('legalDocPhoto2', _legalDocPhoto2!.path, contentType: MediaType('image', 'jpeg')));
    }
    if (_legalDocPhoto3 != null) {
      request.files.add(await http.MultipartFile.fromPath('legalDocPhoto3', _legalDocPhoto3!.path, contentType: MediaType('image', 'jpeg')));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Property updated successfully
        toastNotification.success('Property updated successfully!');
        Navigator.pop(context); // Optionally navigate back
      } else {
        // Handle error
        final responseBody = await response.stream.bytesToString();
        print('Failed to update property: $responseBody');
        toastNotification.warn('Failed to update property.');
      }
    } catch (error) {
      print('Error updating property: $error');
      toastNotification.error('Error updating property.');
    }
  }


  @override
  Widget build(BuildContext context) {
    print("Property details: ${widget.propertyDetails}");
    return Scaffold(
      backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 28, 29, 34) : Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 28, 29, 34) : Colors.white,
        title: Text(
          'Update Property',
          style: TextStyle(
            fontFamily: 'manrope',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40, 
            width: 40, 
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Wrap the ListView in a Form widget
          child: ListView(
            children: [
              const SizedBox(height: 10),
              ShadInputFormField(
                cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10), 
                style: TextStyle(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                id: 'description',
                label: Text(
                  'Description',
                  style: TextStyle(
                    color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                placeholder: const Text('Enter description'),
                description: const Text('Provide a detailed description.'),
                validator: (v) {
                  if (v.isEmpty) {
                    return 'Description cannot be empty.';
                  }
                  return null;
                },
                controller: descriptionController,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 10),
              ShadInputFormField(
                cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                style: TextStyle(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                id: 'street',
                label: Text(
                  'Street',
                  style: TextStyle(
                    color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                placeholder: const Text('Enter street'),
                validator: (v) {
                  if (v.isEmpty) {
                    return 'Street cannot be empty.';
                  }
                  return null;
                },
                controller: streetController,
              ),
              const SizedBox(height: 10),
              // Barangay selection using ShadSelect
              Text(
            'Barangay',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'manrope',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
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
              const SizedBox(height: 10),
              Text(
            'Type Of Property',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'manrope',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
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
                initialValue: _typeOfProperty, // Initialize with the selected value
                selectedOptionBuilder: (context, value) => Text(
                  value ?? 'Select Type of Property',
                  style: TextStyle(
                    fontFamily: 'manrope',
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
              const SizedBox(height: 10),

              Text(
            'Amenities',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Colors.black,
              fontSize: 20,
              fontFamily: 'manrope',
              fontWeight: FontWeight.bold,
            ),
          ),
              Text(
            'Press to select',
            style: TextStyle(
              color: _themeController.isDarkMode.value? const Color.fromARGB(255, 182, 182, 182): const Color.fromARGB(255, 122, 122, 122),
              fontSize: 13,
              fontFamily: 'manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
               // Amenities selection
              // Your UI widget for displaying amenities
Wrap(
  spacing: 8.0, // Horizontal space between buttons
  runSpacing: 8.0, // Vertical space between buttons
  children: List.generate(amenities.length, (index) {
    return ElevatedButton.icon(
      onPressed: () => toggleAmenity(index),
      icon: Icon(icons[index]),
      label: Text(amenities[index]),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedAmenities[index]
            ? const Color.fromARGB(246, 0, 209, 164) // Selected color
            : const Color.fromARGB(255, 122, 120, 136), // Unselected color
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }),
),







              const SizedBox(height: 16), // Space between buttons and input field

              // Other Amenities Input Field
// Assuming fetchedAmenities is already defined somewhere in your code


Text(
  'Available Amenities: $amenitiesString',
  style: TextStyle(
    fontSize: 16,
    fontFamily: 'manrope',
    fontWeight: FontWeight.w500,
    color: _themeController.isDarkMode.value 
      ? const Color.fromARGB(255, 182, 182, 182) 
      : const Color.fromARGB(255, 97, 97, 97),
  ),
),
const SizedBox(height: 10), // Space between text and input field

Text(
  'Type other amenities if needed:',
  style: TextStyle(
    fontSize: 13,
    fontFamily: 'manrope',
    fontWeight: FontWeight.w500,
    color: _themeController.isDarkMode.value 
      ? const Color.fromARGB(255, 182, 182, 182) 
      : const Color.fromARGB(255, 97, 97, 97),
  ),
),
ShadInput(
  style: TextStyle(
    fontSize: 16,
    fontFamily: 'manrope',
    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
  ),
  controller: amenitiesController,
  placeholder: Text('Other:'),
),
              const SizedBox(height: 10),

              Text(
            'Select Location',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'manrope',
              fontWeight: FontWeight.bold,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          ShadButton(
            backgroundColor: _themeController.isDarkMode.value
                ? Color.fromARGB(255, 255, 255, 255)
                : Color.fromARGB(255, 13, 0, 40),
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
                    color: selectedLocation == null
                        ? _themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.white
                        : Colors.green, // Change text color based on selection
                  ),
                ),
                Icon(Icons.add_location_alt_outlined, color: const Color.fromARGB(255, 7, 255, 160),)
              ],
            ),
          ),

              const SizedBox(height: 20),
          SizedBox(height: 20),
          Text(
            'Property Photos',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'manrope',
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
              fontFamily: 'manrope',
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
                ],
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text('Other Permit'),
                  _buildPhotoBox(3, _legalDocPhoto3, _selectLegalDocPhoto),
                ],
              ),
            ],
          ),
              const SizedBox(height: 20),
              SizedBox(
                child: ShadButton(
                  backgroundColor:  Colors.greenAccent,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      updateProperty();
                    }
                  },
                  child: Text('Update Property', style: TextStyle(
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.w700
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    descriptionController.dispose();
    streetController.dispose();
    barangayController.dispose();
    cityController.dispose();
    typeOfPropertyController.dispose();
    amenitiesController.dispose();
    super.dispose();
  }
  // Helper method to build photo boxes

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