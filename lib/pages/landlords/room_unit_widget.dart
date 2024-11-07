import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentcon/models/room_unit.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RoomUnitWidget extends StatefulWidget {
  final RoomUnit room;
  final Function(File?, int) onImageSelected;
  final int roomIndex; // Add this parameter
  final Function(int) onExpand;
  final bool isExpanded;
   final Function(int) onRemove;

  const RoomUnitWidget({
    required this.room,
    required this.onImageSelected,
    required this.roomIndex, // Add this parameter
    required this.onExpand,
    required this.onRemove,
    this.isExpanded = false, // Default value
    Key? key,
  }) : super(key: key);

  @override
  State<RoomUnitWidget> createState() => _RoomUnitWidgetState();
}

final ThemeController _themeController = Get.find<ThemeController>();

class _RoomUnitWidgetState extends State<RoomUnitWidget> {
  @override
  void initState() {
    super.initState();
    // Set the initial room number based on roomIndex
    widget.room.roomNumberController.text = (widget.roomIndex + 1).toString(); // Room number starts from 1
  }

  final depositDurations = {
  'one month': 'One month',
  'two months': 'Two months',
  'three months': 'Three months',
  'four months': 'Four months',
  'five months': 'Five months',
  'none': 'None',
};


  Future<void> _pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
  
      // Ask the user to choose between picking an image from the gallery or taking a photo
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
                  widget.onImageSelected(File(result.files.single.path!), index); // Return the selected image
                } else {
                  print('No image selected from gallery.');
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
                  widget.onImageSelected(File(pickedFile.path), index); // Return the captured image
                } else {
                  print('No image captured.');
                }
              },
            ),
          ],
        ),
      );
    },
  );
  }

  // Function to check if all required fields are filled
  bool _areFieldsCompleted() {
    return widget.room.roomNumberController.text.isNotEmpty &&
        widget.room.priceController.text.isNotEmpty &&
        widget.room.capacityController.text.isNotEmpty &&
        widget.room.depositController.text.isNotEmpty &&
        // widget.room.reservationDurationController.text.isNotEmpty &&
        widget.room.reservationFeeController.text.isNotEmpty &&
        widget.room.advanceController.text.isNotEmpty &&
        widget.room.roomPhotos.any((photo) => photo != null); 
  }

  @override
  Widget build(BuildContext context) {
    bool isExpanded = widget.isExpanded; // Use the isExpanded prop from widget
    bool allFieldsCompleted = _areFieldsCompleted(); // Check if all fields are filled

    return Padding(
      
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: _themeController.isDarkMode.value? const Color.fromARGB(255, 36, 38, 43):Colors.white,
        elevation: 4, // Adds shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for the card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Room No.',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'manrope',
                          fontWeight: FontWeight.bold,
                          color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                        ),
                      ),
                      if (allFieldsCompleted) // Show "Completed" text and check icon if all fields are filled
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'Completed',
                              style: TextStyle(color: Colors.green,
                              fontFamily: 'manrope',
                              fontSize: 10),
                            ),
                            Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
    
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      // Call onExpand to notify parent about the toggle
                      widget.onExpand(widget.roomIndex);
                    },
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.close, // Close icon
                        color: _themeController.isDarkMode.value ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        widget.onRemove(widget.roomIndex); // Call remove callback
                      },
                    ),
                ],
              ),
              ShadInput(
                cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                placeholder: Text('Enter Room No.'),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'manrope',
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                controller: widget.room.roomNumberController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
    
              // Content that will be shown/hidden
              if (isExpanded) ...[
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                ShadInput(
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'manrope',
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                  cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  controller: widget.room.priceController,
                  placeholder: Text('Enter price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
    
                Text(
                  'Capacity',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                ShadInput(
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'manrope',
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                  cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  controller: widget.room.capacityController,
                  placeholder: Text('Enter capacity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
    
                Text(
                  'Deposit',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                  ShadSelect<String>(
                    placeholder: Text(
                      'Select Deposit',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'manrope',
                        color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 70, 69, 69),
                      ),
                    ),
                    options: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 6, 0),
                      ),
                      ...depositDurations.entries.map((e) =>
                          ShadOption(value: e.key, child: Text(e.value))).toList(),
                    ],
                    initialValue: widget.room.depositController.text.isNotEmpty
                        ? widget.room.depositController.text
                        : null, // Use the value from the controller if present
                    selectedOptionBuilder: (context, value) => Text(
                      depositDurations[value]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'manrope',
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        widget.room.depositController.text = newValue!;
                      });
                    },
                  ),

                  ShadSelect<String>(
                    placeholder: Text(
                      'Select Advance payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'manrope',
                        color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 78, 78, 78),
                      ),
                    ),
                    options: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 6, 0),
                      ),
                      ...depositDurations.entries.map((e) =>
                          ShadOption(value: e.key, child: Text(e.value))).toList(),
                    ],
                    initialValue: widget.room.advanceController.text.isNotEmpty
                        ? widget.room.advanceController.text
                        : null, // Use the value from the controller if present
                    selectedOptionBuilder: (context, value) => Text(
                      depositDurations[value]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'manrope',
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        widget.room.advanceController.text = newValue!;
                      });
                    },
                  ),

                SizedBox(height: 8),
    
                // Reservation Fee
                Text(
                  'Reservation Fee',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                ),
                ShadInput(
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'manrope',
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),
                  cursorColor: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  placeholder: Text('Enter reservation fee'),
                  controller: widget.room.reservationFeeController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                Text('Room Photos:',
                 style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.bold,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),),
                Text('Upload ateast one photo',
                 style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'manrope',
                    fontWeight: FontWeight.w500,
                    color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 128, 128, 128) : const Color.fromARGB(255, 78, 78, 78),
                  ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < widget.room.roomPhotos.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickImage(i),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            height: 100,
                            decoration: BoxDecoration(
                              color: _themeController.isDarkMode.value?const Color.fromARGB(31, 122, 122, 122): Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0), // Rounded corners for images
                            ),
                            child: widget.room.roomPhotos[i] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0), // Rounded corners for images
                                    child: Image.file(widget.room.roomPhotos[i]!, fit: BoxFit.cover),
                                  )
                                : Center(child: Icon(Icons.image_outlined, size: 35,)),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
