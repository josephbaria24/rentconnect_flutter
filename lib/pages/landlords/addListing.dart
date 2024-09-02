import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';



class PropertyInsertPage extends StatefulWidget {
  final token;
  const PropertyInsertPage({@required this.token,Key? key}) : super(key: key);

  @override
  State<PropertyInsertPage> createState() => _PropertyInsertPageState();
}

class _PropertyInsertPageState extends State<PropertyInsertPage> {

  late String userId;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController photoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController numberOfRoomsController = TextEditingController();
  TextEditingController amenitiesController = TextEditingController();
  DateTime? availableFromDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
  }
// @override
// void initState() {
//   super.initState();
//   Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

//   if (jwtDecodedToken.containsKey('_id')) {
//     userId = jwtDecodedToken['_id'];
//   } else {
//     print('User ID not found in token');
//     // Handle error, e.g., log out the user or show an error message
//   }
// }

  // Controllers for each form field

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

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     // Perform the insert action here, like making a POST request to your server.
  //     // For now, we'll just print the values to the console.
  //     print('Description: ${descriptionController.text}');
  //     print('Photo URL: ${photoController.text}');
  //     print('Address: ${addressController.text}');
  //     print('Price: ${priceController.text}');
  //     print('Number of Rooms: ${numberOfRoomsController.text}');
  //     print('Amenities: ${amenitiesController.text}');
  //     print('Available From: $availableFromDate');
  //     print('Status: $selectedStatus');
      
  //     // Reset the form after submission
  //     _formKey.currentState!.reset();
  //   }
  // }

    void addProperty() async {
    if(descriptionController.text.isNotEmpty && photoController.text.isNotEmpty && addressController.text.isNotEmpty && priceController.text.isNotEmpty && numberOfRoomsController.text.isNotEmpty) {
      
      var regBody = {
        "userId":userId,
        "description":descriptionController.text,
        "photo":photoController.text,
        "address":addressController.text,
        "price":double.tryParse(priceController.text),
        "numberOfRooms":int.tryParse(numberOfRoomsController.text),
        "amenities":amenitiesController.text.split(','),
        "availableFrom":availableFromDate?.toIso8601String(),
        "status":selectedStatus ?? "available",

      };
    try {
      var response = await http.post(Uri.parse(storeProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        descriptionController.clear();
        photoController.clear();
        addressController.clear();
        priceController.clear();
        numberOfRoomsController.clear();
        amenitiesController.clear();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> CurrentListingPage(token: widget.token)));
        print("Property added successfully");
        // Handle success, e.g., navigate to another page
      } else {
        print("Failed to add property: ${jsonResponse['message']}");
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
              TextFormField(
                controller: photoController,
                decoration: InputDecoration(labelText: 'Photo URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a photo URL';
                  }
                  return null;
                },
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
                  addProperty();
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