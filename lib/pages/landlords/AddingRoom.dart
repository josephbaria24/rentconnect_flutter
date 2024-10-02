import 'dart:io';
import 'dart:math';
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

class Addingroom extends StatefulWidget {
  final String token;
  final String propertyId;

  const Addingroom({required this.token, required this.propertyId, Key? key}) : super(key: key);

  @override
  _AddingroomState createState() => _AddingroomState();
}

class _AddingroomState extends State<Addingroom> {
  final List<RoomUnit> roomUnits = [];
  final ImagePicker _picker = ImagePicker();
  late String email;
  late String userId;
  final ThemeController _themeController = Get.find<ThemeController>();

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
        reservationDurationController: TextEditingController(),
        reservationFeeController: TextEditingController(),
        roomPhotos: [null, null, null], // Initialize with 3 null values
      ));
    });
    print("Added room: Total rooms now = ${roomUnits.length}");
  }

  void _submitRooms() async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.31:3000/rooms/createRoom'));

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
        'rooms[$i][reservationDuration]': room.reservationDurationController.text,
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
          arguments: widget.token
        );
      } else {
        var responseBody = await response.stream.bytesToString();
        print("Failed with status code: ${response.statusCode}");
        print("Response Body: $responseBody");
      }
    } catch (error) {
      print("Error occurred: $error");
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Add Rooms'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ...roomUnits.asMap().entries.map((entry) {
            int index = entry.key;
            RoomUnit room = entry.value;
            return RoomUnitWidget(
              room: room,
              roomIndex: index, // Pass the index here
              onImageSelected: (image, index) {
                setState(() {
                  room.roomPhotos[index] = image;
                });
              },
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
              onPressed: _submitRooms,
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
  );
}

}
