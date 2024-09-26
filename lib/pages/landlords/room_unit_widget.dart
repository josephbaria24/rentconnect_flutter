import 'dart:io';
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

  const RoomUnitWidget({
    required this.room,
    required this.onImageSelected,
    required this.roomIndex, // Add this parameter
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      widget.onImageSelected(File(pickedFile.path), index);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Room Number Controller: ${widget.room.roomNumberController.text}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4, // Adds shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room No.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
              ShadInput(
                cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                placeholder: Text('Enter Room No.'),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeistSans',
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                controller: widget.room.roomNumberController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
              ShadInput(
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeistSans',
                  //fontWeight: FontWeight.normal,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                controller: widget.room.priceController,
                placeholder: Text('Enter price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
               Text(
                'Capacity',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
              ShadInput(
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeistSans',
                  //fontWeight: FontWeight.normal,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                controller: widget.room.capacityController,
                placeholder: Text('Enter capacity'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              Text(
                'Deposit',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
             ShadSelect<String>(
              
                placeholder: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select Deposit',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeistSans',
                      //fontWeight: FontWeight.normal,
                      color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 87, 87, 87),
                    ),),
                    SizedBox(width: 1,),
                    Icon(Icons.arrow_drop_down_outlined, size: 24,)
                  ],
                ),
                options: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 6, 0),
                    
                  ),
                  ...depositDurations.entries.map((e) =>
                      ShadOption(value: e.key, child: Text(e.value))).toList(),
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(depositDurations[value]!,
                    style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeistSans',
                    //fontWeight: FontWeight.normal,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),),
                onChanged: (newValue) {
                  setState(() {
                    widget.room.depositController.text = newValue!;
                  });
                },
              ),

              Text(
                'Advance Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 8),
              ShadSelect<String>(
                placeholder: Text('Select Advance payment',
                style: TextStyle(
              fontSize: 16,
              fontFamily: 'GeistSans',
              //fontWeight: FontWeight.normal,
              color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 78, 78, 78),
            ),),
                options: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 6, 0),
                    
                  ),
                  ...depositDurations.entries.map((e) =>
                      ShadOption(value: e.key, child: Text(e.value))).toList(),
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(depositDurations[value]!,
                    style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeistSans',
                    //fontWeight: FontWeight.normal,
                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  ),),
                onChanged: (newValue) {
                  setState(() {
                    widget.room.advanceController.text = newValue!;
                  });
                },
              ),
              SizedBox(height: 8),
              Text(
                'Reservation Duration',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              ShadInput(
                cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeistSans',
                  //fontWeight: FontWeight.normal,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                placeholder: Text('Enter reservation duration: Example: 5'),
                controller: widget.room.reservationDurationController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              Text(
                'Reservation Fee',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'GeistSans',
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              ShadInput(
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeistSans',
                  //fontWeight: FontWeight.normal,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                ),
                cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
                placeholder: Text('Enter reservation fee'),
                controller: widget.room.reservationFeeController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Room Photos:'),
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
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners for images
                          ),
                          child: widget.room.roomPhotos[i] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0), // Rounded corners for images
                                  child: Image.file(widget.room.roomPhotos[i]!, fit: BoxFit.cover),
                                )
                              : Icon(Icons.add_a_photo, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
