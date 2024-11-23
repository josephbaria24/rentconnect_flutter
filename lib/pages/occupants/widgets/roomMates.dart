// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RoommatesWidget extends StatefulWidget {
  final Map<String, dynamic> roomDetails; // Details of the room and occupants
   final VoidCallback onRefresh;
  const RoommatesWidget({
    Key? key,
    required this.roomDetails,
    required this.onRefresh, 
  }) : super(key: key);

  @override
  _RoommatesWidgetState createState() => _RoommatesWidgetState();
}

class _RoommatesWidgetState extends State<RoommatesWidget> {
  late List<dynamic> allOccupants; // Combined list of occupants
 late ToastNotification toastNotification;
   final ThemeController _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    super.initState();
    allOccupants = [];
    _fetchOccupants();
    toastNotification = ToastNotification(context);
  }


  Future<void> _fetchOccupants() async {
    // Combine occupant IDs
    List<String> occupantIds = List<String>.from(widget.roomDetails['occupantUsers'])
      ..addAll(List<String>.from(widget.roomDetails['occupantNonUsers']));
    
    // Fetch occupant details using IDs
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/occupant/getAll'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          allOccupants = List<Map<String, dynamic>>.from(
            data.where((occupant) => occupantIds.contains(occupant['_id']))
          );
        });
      } else {
        print('Unexpected data structure: ${data.runtimeType}');
      }
    } else {
      print('Failed to load occupants');
    }
  }


Future<void> _addOccupant(String name, String gender, int age, String contactNumber, String emergencyNumber) async {
  final response = await http.post(
    Uri.parse('https://rentconnect.vercel.app/occupant/create/room/${widget.roomDetails["_id"]}'),
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
    toastNotification.success('Roommate successfully added!');
    _fetchOccupants(); // Refresh the occupant list immediately
     widget.onRefresh();
  } else if (response.statusCode == 400) {
    final error = json.decode(response.body);
    if (error['message'] == 'Room capacity exceeded. Cannot add more occupants.') {
      toastNotification.warn('Room capacity is full. Cannot add more occupants.');
      print('Room capacity is full. Cannot add more occupants.');
    } else {
      print('Failed to add occupant: ${error['message']}');
      toastNotification.error('Failed to add occupant: ${error['message']}');
    }
  } else {
    print('Failed to add occupant');
  }
}


  Future<void> _updateOccupant(String id, String newName) async {
    final response = await http.put(
      Uri.parse('https://rentconnect.vercel.app/occupant/update/$id'),
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
      Uri.parse('https://rentconnect.vercel.app/occupant/delete/$id'),
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
      color: _themeController.isDarkMode.value
          ? const Color.fromARGB(255, 255, 255, 255)
          : Colors.black, // Background color based on theme
      borderRadius: BorderRadius.circular(15), // 15 border radius
    ),
    padding: const EdgeInsets.all(16.0), // Padding inside the container
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roommates',
          style: TextStyle(
            color: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 0, 0, 0)
                : Colors.white, // Text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10), // Space between title and list
        // Check if there are any roommates
        allOccupants.isEmpty
            ? Text(
                'No roommates available.',
                style: TextStyle(
                  color: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : Colors.white,
                ),
              )
            : Container(
                height: 70, // Set a fixed height for the scrollable area
                child: Scrollbar( // Wrap with Scrollbar
                  thumbVisibility: allOccupants.length >= 3, // Show scrollbar if 3 or more occupants
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allOccupants.map((occupant) {
                        // Generate a random avatar URL using DiceBear
                        String avatarUrl = 'https://api.dicebear.com/9.x/adventurer/svg?seed=Felix';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector( // Use GestureDetector to capture taps
                            onTap: () => _showEditOrDeleteDialog(occupant['_id'], occupant['name']),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20, // Size of the avatar
                                  backgroundColor: Colors.grey[300], // Default avatar color
                                  backgroundImage: NetworkImage(avatarUrl), // Use the generated avatar
                                  child: Icon(Icons.person_3_rounded, color: Colors.black), // Default icon as fallback
                                ),
                                SizedBox(height: 4),
                                Text(
                                  occupant['name'],
                                  style: TextStyle(
                                    fontFamily: 'manrope',
                                    fontWeight: FontWeight.w500,
                                    color: _themeController.isDarkMode.value
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
        SizedBox(height: 10), // Space before the add button
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : Colors.white,
            ), // Change the button color here
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Set border radius here
              ),
            ),
            overlayColor: MaterialStateProperty.all(Colors.blueAccent.withOpacity(0.5)), // Change the color when pressed
          ),
          onPressed: () => _showAddDialog(),
          child: Text(
            'Add Occupant',
            style: TextStyle(
              color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.black,
            ), // Change text color if needed
          ),
        ),
      ],
    ),
  );
}

// New method to show edit or delete dialog
void _showEditOrDeleteDialog(String id, String currentName) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Manage Occupant'),
        content: Text('What would you like to do with $currentName?'),
        actions: [
          TextButton(
            onPressed: () {
              _deleteOccupant(id); // Delete occupant
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditDialog(id, currentName); // Edit occupant
            },
            child: Text('Edit'),
          ),
        ],
      );
    },
  );
}

final genderOptions = {
  'Male': 'Male',
  'Female': 'Female',
  'Other': 'Other',
};

void _showAddDialog() {
  String name = '';
  String selectedGender = 'Male'; // Changed variable name to avoid conflict
  int age = 0;
  String contactNumber = '';
  String emergencyNumber = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Occupant'),
        content: Scrollbar(
          thickness: 5,
          thumbVisibility: true,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadInput(
                    cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                    onChanged: (value) {
                      name = value; // Capture name input
                    },
                   placeholder: Text('Enter occupant name', style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black)),
                  ),
                  SizedBox(height: 5,),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: ShadSelect<String>(
                      
                      placeholder: Text('Select Gender',
                      style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),),
                      options: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                        
                        ),
                        ...genderOptions.entries.map(
                          (e) => ShadOption(value: e.key, child: Text(e.value)),
                        ),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(genderOptions[value]!,style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedGender = newValue; // Update gender selection
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 5), // Add spacing for better visual structure
                  ShadInput(
                    cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      age = int.tryParse(value) ?? 0; // Capture age input
                    },
                    placeholder: Text('Enter age', style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black)),
                  ),
                  SizedBox(height: 5), // Add spacing for better visual structure
                  ShadInput(
                    cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                    onChanged: (value) {
                      contactNumber = value; // Capture contact number input
                    },
                    placeholder: Text('Enter contact no.', style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black)),
                  ),
                  SizedBox(height: 5), // Add spacing for better visual structure
                  ShadInput(
                    cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                    onChanged: (value) {
                      emergencyNumber = value; // Capture emergency number input
                    },
                    placeholder: Text('Enter emergency no.', style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && age > 0 && contactNumber.isNotEmpty && emergencyNumber.isNotEmpty) {
                _addOccupant(name, selectedGender, age, contactNumber, emergencyNumber); // Add occupant
                Navigator.of(context).pop();
              }
            },
            child: Text('Add', style: TextStyle(fontFamily: 'manrope',fontWeight: FontWeight.w700,color: _themeController.isDarkMode.value? Colors.white:Colors.black),),
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
              child: Text('Update' ,style: TextStyle(fontFamily: 'manrope',fontWeight: FontWeight.w700,color: _themeController.isDarkMode.value? Colors.white:Colors.black),),
            ),
          ],
        );
      },
    );
  }
}
