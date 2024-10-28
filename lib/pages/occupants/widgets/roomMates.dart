// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoommatesWidget extends StatefulWidget {
  final Map<String, dynamic> roomDetails; // Details of the room and occupants

  const RoommatesWidget({
    Key? key,
    required this.roomDetails,
  }) : super(key: key);

  @override
  _RoommatesWidgetState createState() => _RoommatesWidgetState();
}

class _RoommatesWidgetState extends State<RoommatesWidget> {
  late List<dynamic> allOccupants; // Combined list of occupants

  @override
  void initState() {
    super.initState();
    allOccupants = List.from(widget.roomDetails['occupantUsers'])
      ..addAll(widget.roomDetails['occupantNonUsers']); // Combine user and non-user occupants  // Fetch all occupants
    _fetchOccupants();
  }

Future<void> _fetchOccupants() async {
    final response = await http.get(Uri.parse('http://192.168.1.8:3000/occupant/getAll'));
    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Adjust according to your actual data structure
        if (data is List) { // Check if data is a list
            setState(() {
                allOccupants = data; // Update the list of occupants
            });
        } else {
            // Handle unexpected structure
            print('Expected a list but got: ${data.runtimeType}');
        }
    } else {
        // Handle error
        print('Failed to load occupants');
    }
}

  Future<void> _addOccupant(String name, String gender, int age, String contactNumber, String emergencyNumber) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.8:3000/occupant/create/room/{$widget.roomDetails}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'gender': gender,
        'age': age,
        'contactNumber': contactNumber,
        'emergencyNumber': emergencyNumber,
        // Add other fields as necessary
      }),
    );

    if (response.statusCode == 201) {
      _fetchOccupants(); // Refresh the occupant list
    } else {
      // Handle error
      print('Failed to add occupant');
    }
  }

  Future<void> _updateOccupant(String id, String newName) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.8:3000/occupant/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': newName}),
    );

    if (response.statusCode == 200) {
      _fetchOccupants(); // Refresh the occupant list
    } else {
      // Handle error
      print('Failed to update occupant');
    }
  }

  Future<void> _deleteOccupant(String id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.8:3000/occupant/delete/$id'),
    );

    if (response.statusCode == 200) {
      _fetchOccupants(); // Refresh the occupant list
    } else {
      // Handle error
      print('Failed to delete occupant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Black background
        borderRadius: BorderRadius.circular(15), // 15 border radius
      ),
      padding: const EdgeInsets.all(16.0), // Padding inside the container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Roommates',
            style: TextStyle(
              color: Colors.white, // Text color
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10), // Space between title and list
          // Check if there are any roommates
          allOccupants.isEmpty
              ? Text(
                  'No roommates available.',
                  style: TextStyle(color: Colors.white),
                )
              : ListView.builder(
                  itemCount: allOccupants.length,
                  shrinkWrap: true, // To avoid infinite height
                  physics: NeverScrollableScrollPhysics(), // Disable scrolling
                  itemBuilder: (context, index) {
                    final occupant = allOccupants[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            occupant['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOccupant(occupant['_id']), // Delete occupant
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditDialog(occupant['_id'], occupant['name']); // Pass id and name to edit
                            }, // Edit occupant
                          ),
                        ],
                      ),
                    );
                  },
                ),
          SizedBox(height: 10), // Space before the add button
          ElevatedButton(
            onPressed: () => _showAddDialog(),
            child: Text('Add Occupant'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String name = '';
    String gender = 'Male';
    int age = 0;
    String contactNumber = '';
    String emergencyNumber = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Occupant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  name = value; // Capture name input
                },
                decoration: InputDecoration(hintText: 'Enter occupant name'),
              ),
              DropdownButton<String>(
                value: gender,
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  age = int.tryParse(value) ?? 0; // Capture age input
                },
                decoration: InputDecoration(hintText: 'Enter age'),
              ),
              TextField(
                onChanged: (value) {
                  contactNumber = value; // Capture contact number input
                },
                decoration: InputDecoration(hintText: 'Enter contact number'),
              ),
              TextField(
                onChanged: (value) {
                  emergencyNumber = value; // Capture emergency number input
                },
                decoration: InputDecoration(hintText: 'Enter emergency number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && age > 0 && contactNumber.isNotEmpty && emergencyNumber.isNotEmpty) {
                  _addOccupant(name, gender, age, contactNumber, emergencyNumber); // Add occupant
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(String id, String currentName) {
    String newName = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Occupant'),
          content: TextField(
            onChanged: (value) {
              newName = value; // Capture new name input
            },
            decoration: InputDecoration(hintText: 'Enter new occupant name'),
            controller: TextEditingController(text: currentName), // Pre-fill with current name
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  _updateOccupant(id, newName); // Update occupant
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
