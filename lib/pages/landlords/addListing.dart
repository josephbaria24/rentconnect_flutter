import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:rentcon/pages/landlords/roomCreation.dart';
import 'package:rentcon/pages/map/propertyLocationPicker.dart';

class Addlisting extends StatefulWidget {
  final String token;
  const Addlisting({required this.token, Key? key}) : super(key: key);

  @override
  _AddlistingState createState() => _AddlistingState();
}

class _AddlistingState extends State<Addlisting> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController barangayController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController amenitiesController = TextEditingController();
  DateTime? availableFromDate;
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

  final List<String> _propertyTypes = [
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

  Future<void> _selectAvailableFromDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != availableFromDate) {
      setState(() {
        availableFromDate = pickedDate;
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
    var request = http.MultipartRequest('POST', Uri.parse('https://rentconnect-backend-nodejs.onrender.com/storeProperty'));

    request.fields['userId'] = userId;
    request.fields['description'] = descriptionController.text;

    // Set the address fields
    request.fields['street'] = streetController.text.trim();
    request.fields['barangay'] = selectedBarangay;
    request.fields['city'] = 'Puerto Princesa City';

    request.fields['availableFrom'] = availableFromDate?.toIso8601String() ?? '';
    request.fields['amenities'] = amenitiesController.text.split(',').join(',');
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
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to proceed to add rooms?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                labelText: 'Street',
                hintText: 'Enter the street',
              ),
            ),
            SizedBox(height: 10),

            // Barangay Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Barangay'),
              value: selectedBarangay.isEmpty ? null : selectedBarangay,
              items: barangayList.map((String barangay) {
                return DropdownMenuItem<String>(
                  value: barangay,
                  child: Text(barangay),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBarangay = newValue!;
                });
              },
            ),
            SizedBox(height: 10),

            // City / Municipality (Static Field)
            TextField(
              controller: cityController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'Puerto Princesa City',
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: amenitiesController,
              decoration: InputDecoration(labelText: 'Amenities'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _typeOfProperty,
              hint: Text('Select Type of Property'),
              items: _propertyTypes.map((String type) {
                return DropdownMenuItem<String>(
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
            SizedBox(height: 10),
            Text('Available From:'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _selectAvailableFromDate,
                  child: Text(
                    availableFromDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(availableFromDate!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Select Location:'),
            ElevatedButton(
              onPressed: _pickLocation,
              child: Text(
                selectedLocation == null
                    ? 'Select Location'
                    : 'Location Selected (${selectedLocation!.latitude}, ${selectedLocation!.longitude})',
              ),
            ),
            SizedBox(height: 20),
            Text('Property Photos:'),
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
            Text('Legal Document Photos:'),
            Row(
              children: [
                _buildPhotoBox(1, _legalDocPhoto, _selectLegalDocPhoto),
                SizedBox(width: 10),
                _buildPhotoBox(2, _legalDocPhoto2, _selectLegalDocPhoto),
                SizedBox(width: 10),
                _buildPhotoBox(3, _legalDocPhoto3, _selectLegalDocPhoto),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProperty,
              child: Text('Submit Property'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(int index, File? photo, Function(int) onSelectPhoto) {
    return GestureDetector(
      onTap: () => onSelectPhoto(index),
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: photo == null
            ? Center(child: Text('Photo $index'))
            : Image.file(
                photo,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
