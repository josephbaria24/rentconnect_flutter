import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // Add this line

class PropertyInsertPage extends StatefulWidget {
  final token;
  const PropertyInsertPage({@required this.token, Key? key}) : super(key: key);

  @override
  State<PropertyInsertPage> createState() => _PropertyInsertPageState();
}

class _PropertyInsertPageState extends State<PropertyInsertPage> {
  late String userId;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController numberOfRoomsController = TextEditingController();
  TextEditingController amenitiesController = TextEditingController();
  DateTime? availableFromDate;
  File? _image;
  File? _legalDocImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
  }

  void _selectImage({required bool isLegalDoc}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLegalDoc) {
          _legalDocImage = File(pickedFile.path);
        } else {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  String? selectedStatus;
  final List<String> statusOptions = ['available', 'reserved', 'rented'];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != availableFromDate)
      setState(() {
        availableFromDate = picked;
      });
  }

  void _submitForm() async {
    if (descriptionController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        numberOfRoomsController.text.isNotEmpty) {

      var request = http.MultipartRequest('POST', Uri.parse(storeProperty));
      request.fields['userId'] = userId;
      request.fields['description'] = descriptionController.text;
      request.fields['address'] = addressController.text;
      request.fields['price'] = priceController.text;
      request.fields['numberOfRooms'] = numberOfRoomsController.text;
      request.fields['amenities'] = amenitiesController.text.split(',').join(',');
      request.fields['availableFrom'] = availableFromDate?.toIso8601String() ?? '';

      if (_image != null) {
        // Get the MIME type of the selected image
        String mimeType = lookupMimeType(_image!.path) ?? 'application/octet-stream';
        var fileExtension = mimeType.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', 
            _image!.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }

      if (_legalDocImage != null) {
        String mimeType = lookupMimeType(_legalDocImage!.path) ?? 'application/octet-stream';
        var fileExtension = mimeType.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            'legalDocPhoto', 
            _legalDocImage!.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var jsonResponse = jsonDecode(responseBody);

          if (jsonResponse['status']) {
            descriptionController.clear();
            addressController.clear();
            priceController.clear();
            numberOfRoomsController.clear();
            amenitiesController.clear();
            setState(() {
              _image = null; // Clear the selected image
              _legalDocImage = null; // Clear the legal document image
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CurrentListingPage(token: widget.token)),
            );
            print("Property added successfully");
          } else {
            print("Failed to add property: ${jsonResponse['message']}");
          }
        } else {
          print("Failed with status code: ${response.statusCode}");
        }
      } catch (error) {
        print("Error occurred: $error");
      }
    } else {
      print("Please fill all required fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Property'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: () => _selectImage(isLegalDoc: false),
                child: Text('Select Property Image'),
              ),
              SizedBox(height: 10),
              _legalDocImage == null
                  ? Text('No legal document image selected.')
                  : Image.file(_legalDocImage!),
              ElevatedButton(
                onPressed: () => _selectImage(isLegalDoc: true),
                child: Text('Select Legal Document Image'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: numberOfRoomsController,
                decoration: InputDecoration(labelText: 'Number of Rooms'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of rooms';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: amenitiesController,
                decoration: InputDecoration(
                  labelText: 'Amenities (comma separated)',
                ),
              ),
              ListTile(
                title: Text('Available From: ${availableFromDate != null ? availableFromDate!.toLocal().toString().split(' ')[0] : 'Select Date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status'),
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                items: statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
