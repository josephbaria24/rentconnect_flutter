import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // To allow photo picking from gallery or camera
import 'package:http/http.dart' as http;

class EditPropertyScreen extends StatefulWidget {
  final String propertyId; // Pass the propertyId from previous page
  final Map<String, dynamic> propertyDetails; // To populate existing property data

  EditPropertyScreen({required this.propertyId, required this.propertyDetails});

  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _descriptionController;
  late TextEditingController _streetController;
  late TextEditingController _barangayController;
  late TextEditingController _cityController;
  late TextEditingController _amenitiesController;
  
  XFile? _photo;
  XFile? _photo2;
  XFile? _photo3;

  @override
  void initState() {
    super.initState();
    // Populate controllers with existing property data
    _descriptionController = TextEditingController(text: widget.propertyDetails['description']);
    _streetController = TextEditingController(text: widget.propertyDetails['street']);
    _barangayController = TextEditingController(text: widget.propertyDetails['barangay']);
    _cityController = TextEditingController(text: widget.propertyDetails['city']);
    _amenitiesController = TextEditingController(text: widget.propertyDetails['amenities']?.join(', '));
  }

  Future<void> _pickImage(int photoIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (photoIndex == 1) _photo = pickedFile;
      if (photoIndex == 2) _photo2 = pickedFile;
      if (photoIndex == 3) _photo3 = pickedFile;
    });
  }

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    Map<String, dynamic> updatedData = {
      'description': _descriptionController.text,
      'street': _streetController.text,
      'barangay': _barangayController.text,
      'city': _cityController.text,
      'amenities': _amenitiesController.text.split(',').map((e) => e.trim()).toList(),
      'photo': _photo?.path, 
      'photo2': _photo2?.path,
      'photo3': _photo3?.path,
    };

    try {
      // Make an HTTP request to update the property details in the database
      final response = await http.put(
        Uri.parse('http://192.168.1.18:3000/properties/${widget.propertyId}'), // API endpoint to update property
        headers: {
          'Content-Type': 'application/json',
          // Add any authorization headers if needed
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property updated successfully')),
        );
        Navigator.pop(context);
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update property')),
        );
      }
    } catch (e) {
      // Handle any exceptions during the HTTP request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Property'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Property Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a property description';
                  }
                  return null;
                },
              ),
              // Street
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(labelText: 'Street'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the street';
                  }
                  return null;
                },
              ),
              // Barangay
              TextFormField(
                controller: _barangayController,
                decoration: InputDecoration(labelText: 'Barangay'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the barangay';
                  }
                  return null;
                },
              ),
              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
              ),
              // Amenities
              TextFormField(
                controller: _amenitiesController,
                decoration: InputDecoration(labelText: 'Amenities (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amenities';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Photos Section
              Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  _photo != null
                      ? Image.file(File(_photo!.path), height: 50, width: 50)
                      : Icon(Icons.image),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(1),
                  ),
                  SizedBox(width: 10),
                  _photo2 != null
                      ? Image.file(File(_photo2!.path), height: 50, width: 50)
                      : Icon(Icons.image),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(2),
                  ),
                  SizedBox(width: 10),
                  _photo3 != null
                      ? Image.file(File(_photo3!.path), height: 50, width: 50)
                      : Icon(Icons.image),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(3),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
