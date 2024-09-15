import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentcon/models/room_unit.dart';

class RoomUnitWidget extends StatelessWidget {
  final RoomUnit room;
  final Function(File?, int) onImageSelected;

  const RoomUnitWidget({
    required this.room,
    required this.onImageSelected,
    Key? key,
  }) : super(key: key);

  Future<void> _pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path), index);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Room Number Controller: ${room.roomNumberController.text}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Room Number:'),
          TextField(
            controller: room.roomNumberController,
            decoration: InputDecoration(labelText: 'Enter Room Number'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Price:'),
          TextField(
            controller: room.priceController,
            decoration: InputDecoration(labelText: 'Enter Price'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Capacity:'),
          TextField(
            controller: room.capacityController,
            decoration: InputDecoration(labelText: 'Enter Capacity'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Deposit:'),
          TextField(
            controller: room.depositController,
            decoration: InputDecoration(labelText: 'Enter Deposit'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Advance Payment:'),
          TextField(
            controller: room.advanceController,
            decoration: InputDecoration(labelText: 'Enter Advance Payment'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Reservation Duration:'),
          TextField(
            controller: room.reservationDurationController,
            decoration: InputDecoration(labelText: 'Enter Reservation Duration'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          Text('Reservation Fee:'),
          TextField(
            controller: room.reservationFeeController,
            decoration: InputDecoration(labelText: 'Enter Reservation Fee'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          Text('Room Photos:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < room.roomPhotos.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(i),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      height: 100,
                      color: Colors.grey[300],
                      child: room.roomPhotos[i] != null
                          ? Image.file(room.roomPhotos[i]!, fit: BoxFit.cover)
                          : Icon(Icons.add_a_photo),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
