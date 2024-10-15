import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rentcon/pages/landlords/room_unit_widget.dart';
import 'package:rentcon/models/room_unit.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RoomCreationPage extends StatefulWidget {
  final String token;
  final String propertyId;
  
  const RoomCreationPage({required this.token, required this.propertyId, Key? key}) : super(key: key);

  @override
  _RoomCreationPageState createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  final List<RoomUnit> roomUnits = [];
  final ImagePicker _picker = ImagePicker();
  late String email;
  late String userId;
  final ThemeController _themeController = Get.find<ThemeController>();
   int _expandedRoomIndex = -1;

  @override
  void initState() {
    super.initState();
    print("Received propertyId: ${widget.propertyId}");
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    print("Decoded token: email = $email, userId = $userId");
  }

void _addRoom() {
  setState(() {
    roomUnits.add(RoomUnit(
      priceController: TextEditingController(),
      roomNumberController: TextEditingController(),
      capacityController: TextEditingController(),
      depositController: TextEditingController(),
      advanceController: TextEditingController(),
      reservationFeeController: TextEditingController(),
      roomPhotos: [null, null, null], // Initialize with 3 null values
    ));
    // Automatically expand the newly added room
    _expandedRoomIndex = roomUnits.length - 1; 
  });
  print("Added room: Total rooms now = ${roomUnits.length}");
}

void _submitRooms() async {
  // Validate fields for all rooms
  for (int i = 0; i < roomUnits.length; i++) {
    RoomUnit room = roomUnits[i];

    // Check if any field is empty
    if (room.roomNumberController.text.isEmpty ||
        room.priceController.text.isEmpty ||
        room.capacityController.text.isEmpty ||
        room.depositController.text.isEmpty ||
        room.advanceController.text.isEmpty ||
        room.reservationFeeController.text.isEmpty ||
        room.roomPhotos.isEmpty) {

      // Show a Cupertino alert dialog for missing fields
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              'Incomplete Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.destructiveRed,
              ),
            ),
            content: Text(
              'It looks like some fields for Room ${i + 1} are not filled out yet. Please complete all the required information before submitting.',
              style: TextStyle(fontSize: 13, fontFamily: 'geistsans'),
            ),

            actions: <CupertinoDialogAction>[
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

      // Stop the submission process
      return;
    }
  }

  // If all fields are valid, proceed to submit the form
  var request = http.MultipartRequest('POST', Uri.parse('https://rentconnect-backend-nodejs.onrender.com/rooms/createRoom'));

  // Prepare data for all rooms
  for (int i = 0; i < roomUnits.length; i++) {
    RoomUnit room = roomUnits[i];

    // Attach room data
    request.fields.addAll({
      'rooms[$i][propertyId]': widget.propertyId,
      'rooms[$i][roomNumber]': room.roomNumberController.text,
      'rooms[$i][price]': room.priceController.text,
      'rooms[$i][capacity]': room.capacityController.text,
      'rooms[$i][deposit]': room.depositController.text,
      'rooms[$i][advance]': room.advanceController.text,
      'rooms[$i][reservationFee]': room.reservationFeeController.text,
    });

    for (int j = 0; j < room.roomPhotos.length; j++) {
      if (room.roomPhotos[j] != null) {
        String mimeType = lookupMimeType(room.roomPhotos[j]!.path) ?? 'application/octet-stream';
        var fileExtension = mimeType.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            'rooms[$i][photo${j + 1}]',
            room.roomPhotos[j]!.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }
    }
  }

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      print("Rooms added successfully: $responseBody");
      Navigator.pushReplacementNamed(
        context,
        '/current-listing',
        arguments: widget.token,
      );
    } else {
      var responseBody = await response.stream.bytesToString();
      print("Failed with status code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 400) {
        // Show a Cupertino alert dialog for backend validation error
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Missing Field'),
              content: Text('Please complete all required fields'),
              actions: <CupertinoDialogAction>[
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
    }
  } catch (error) {
    print("Error occurred: $error");

    // Show a Cupertino alert dialog for unexpected errors
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred: $error'),
          actions: <CupertinoDialogAction>[
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
}
  Future<void> _deleteProperty() async {
    try {
      final response = await http.delete(
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/deleteProperty/${widget.propertyId}'),
      );

      if (response.statusCode == 200) {
        print("Property ID for deletion: ${widget.propertyId}");
        print("Property deleted successfully.");
      } else {
        print("Failed to delete property with status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error occurred while deleting property: $error");
    }
  }
 // Your existing initState and other methods...

  void _removeRoom(int index) {
    setState(() {
      roomUnits.removeAt(index); // Remove the room at the specified index
    });
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      await _deleteProperty(); // Delete the property when navigating back
      return true; // Allow the back navigation to proceed
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor:_themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34): Colors.white,
        scrolledUnderElevation: 0,
        title: Text('Add Rooms',style: 
        TextStyle(
          fontFamily: 'geistsans',
        fontSize: 22,
        fontWeight: FontWeight.w600
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
      backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34):Colors.white,
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...roomUnits.asMap().entries.map((entry) {
              int index = entry.key;
              RoomUnit room = entry.value;
              return RoomUnitWidget(
                room: room,
                onRemove: _removeRoom,
                roomIndex: index, // Pass the index here
                onImageSelected: (image, index) {
                  setState(() {
                    room.roomPhotos[index] = image;
                  });
                },
                onExpand: (int expandedIndex) {
                  setState(() {
                    // If the same room is clicked, collapse it, else expand the new one
                    _expandedRoomIndex = _expandedRoomIndex == expandedIndex ? -1 : expandedIndex;
                  });
                },
                isExpanded: _expandedRoomIndex == index, // Check if the current index is expanded
              );
            }).toList(),
            ShadButton(
              backgroundColor: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 13, 0, 40),
              onPressed: _addRoom,
              child: Row(
                children: [
                  Text(
                    'Add Room',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.add_home,
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : const Color.fromARGB(255, 255, 255, 255),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (roomUnits.isNotEmpty)
            ShadButton(
  backgroundColor: _themeController.isDarkMode.value
      ? const Color.fromARGB(255, 255, 255, 255)
      : const Color.fromARGB(255, 255, 0, 85),
  onPressed: () async {
    // Check if any room is missing photos
    bool missingPhoto = false;

    for (var room in roomUnits) {
      if (room.roomPhotos.isEmpty) { // Check if the room has no photos
        missingPhoto = true;
        break; // Exit the loop if we find a room without photos
      }
    }

    if (missingPhoto) {
      // Show an alert dialog if a room is missing photos
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              'Missing Photos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.destructiveRed,
              ),
            ),
            content: Text(
              'Please upload at least one photo for all rooms before submitting.',
              style: TextStyle(fontSize: 13, fontFamily: 'geistsans'),
            ),
            actions: <CupertinoDialogAction>[
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
      return; // Exit the function early if there are missing photos
    }

    // Show the Cupertino confirmation dialog
    bool confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Submit Room'),
          content: Text('Are you sure you want to submit the room details?'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on submit
              },
            ),
          ],
        );
      },
    ) ?? false; // Provide a default value of 'false' in case the dialog returns null

    if (confirmed) {
      _submitRooms(); // Call submit if confirmed is true
    }
  },
  child: Text(
    'Submit Room',
    style: TextStyle(
      color: _themeController.isDarkMode.value
          ? const Color.fromARGB(255, 0, 0, 0)
          : const Color.fromARGB(255, 255, 255, 255),
    ),
  ),
),
            if (roomUnits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Please add at least one room before submitting.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

}
