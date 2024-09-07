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
  TextEditingController amenitiesController = TextEditingController();
  DateTime? availableFromDate;

  File? _coverPhoto;
  final ImagePicker _picker = ImagePicker();

  // Room list
  List<RoomUnit> roomUnits = [];

  // List for additional property photos
  List<File> _additionalPhotos = [];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
  }

  void _selectImage(RoomUnit room) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        room.roomImage = File(pickedFile.path);
      });
    }
  }

  void _selectCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverPhoto = File(pickedFile.path);
      });
    }
  }

  void _selectAdditionalImages() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _additionalPhotos.add(File(pickedFile.path));
      });
    }
  }

  void _applyToAll() {
    if (roomUnits.isNotEmpty) {
      final price = roomUnits.first.priceController.text;
      final capacity = roomUnits.first.capacityController.text;

      setState(() {
        for (var room in roomUnits) {
          room.priceController.text = price;
          room.capacityController.text = capacity;
        }
      });
    }
  }

  void _submitForm() async {
    if (descriptionController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        roomUnits.isNotEmpty) {

      var request = http.MultipartRequest('POST', Uri.parse(storeProperty));
      request.fields['userId'] = userId;
      request.fields['description'] = descriptionController.text;
      request.fields['address'] = addressController.text;
      request.fields['availableFrom'] = availableFromDate?.toIso8601String() ?? '';
      request.fields['amenities'] = amenitiesController.text.split(',').join(',');

      // Add cover photo
      if (_coverPhoto != null) {
        String mimeType = lookupMimeType(_coverPhoto!.path) ?? 'application/octet-stream';
        var fileExtension = mimeType.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            'coverPhoto',
            _coverPhoto!.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }

      // Add additional property photos
      for (int i = 0; i < _additionalPhotos.length; i++) {
        File photo = _additionalPhotos[i];

        String mimeType = lookupMimeType(photo.path) ?? 'application/octet-stream';
        var fileExtension = mimeType.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            'propertyPhoto[$i]',
            photo.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }

      // Add room photos and details
      for (int i = 0; i < roomUnits.length; i++) {
        RoomUnit room = roomUnits[i];

        if (room.roomImage != null) {
          String mimeType = lookupMimeType(room.roomImage!.path) ?? 'application/octet-stream';
          var fileExtension = mimeType.split('/').last;

          request.files.add(
            await http.MultipartFile.fromPath(
              'roomPhoto[$i]',
              room.roomImage!.path,
              contentType: MediaType('image', fileExtension),
            ),
          );
        }

        request.fields['roomPrice[$i]'] = room.priceController.text;
        request.fields['roomCapacity[$i]'] = room.capacityController.text;
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          var jsonResponse = jsonDecode(responseBody);

          if (jsonResponse['status']) {
            descriptionController.clear();
            addressController.clear();
            amenitiesController.clear();
            setState(() {
              _coverPhoto = null;
              roomUnits.clear();
              _additionalPhotos.clear();
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
        child: ListView(
          children: [
            Text('I. Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 20),
            Text('A. Property Details', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Cover Photo Section
            _coverPhoto == null
                ? GestureDetector(
                    onTap: _selectCoverImage,
                    child: Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text('Set your Property Cover Photo'),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _selectCoverImage,
                    child: Image.file(_coverPhoto!, height: 200, fit: BoxFit.cover),
                  ),
            SizedBox(height: 10),
            // Additional Property Photos Section
            Row(
              children: [
                ..._additionalPhotos.map((photo) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Image.file(photo, height: 100, width: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _additionalPhotos.remove(photo);
                                });
                              },
                              child: Icon(Icons.cancel, color: Colors.red),
                            ),
                          )
                        ],
                      ),
                    )),
                GestureDetector(
                  onTap: _selectAdditionalImages,
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.add_a_photo)),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Text('B. Room/Unit Specification', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.money),
                    ),
                    controller: roomUnits.isNotEmpty ? roomUnits.first.priceController : null,
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Capacity',
                    ),
                    controller: roomUnits.isNotEmpty ? roomUnits.first.capacityController : null,
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyToAll,
                  child: Text('Apply to all'),
                ),
              ],
            ),
            ...roomUnits.map((room) {
              return RoomUnitWidget(
                room: room,
                onImageSelected: (image) => setState(() => room.roomImage = image),
              );
            }).toList(),
            IconButton(
              onPressed: () {
                setState(() {
                  roomUnits.add(RoomUnit(
                    priceController: TextEditingController(),
                    capacityController: TextEditingController(),
                  ));
                });
              },
              icon: Icon(Icons.add),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: amenitiesController,
              decoration: InputDecoration(labelText: 'Amenities (comma separated)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomUnit {
  TextEditingController priceController;
  TextEditingController capacityController;
  File? roomImage;

  RoomUnit({
    required this.priceController,
    required this.capacityController,
    this.roomImage,
  });
}

class RoomUnitWidget extends StatelessWidget {
  final RoomUnit room;
  final ValueChanged<File?> onImageSelected;

  const RoomUnitWidget({
    Key? key,
    required this.room,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        room.roomImage == null
            ? GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImageSelected(File(pickedFile.path));
                  }
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.add_a_photo)),
                ),
              )
            : GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImageSelected(File(pickedFile.path));
                  }
                },
                child: Image.file(room.roomImage!, height: 100, width: 100, fit: BoxFit.cover),
              ),
        Expanded(
          child: TextField(
            controller: room.priceController,
            decoration: InputDecoration(labelText: 'Price'),
          ),
        ),
        Expanded(
          child: TextField(
            controller: room.capacityController,
            decoration: InputDecoration(labelText: 'Capacity'),
          ),
        ),
      ],
    );
  }
}
