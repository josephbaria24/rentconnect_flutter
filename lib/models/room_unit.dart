import 'dart:io';
import 'package:flutter/material.dart';

class RoomUnit {
  final TextEditingController priceController;
  final TextEditingController roomNumberController;
  final TextEditingController capacityController;
  final TextEditingController depositController;
  final TextEditingController advanceController;
  //final TextEditingController reservationDurationController;
  final TextEditingController reservationFeeController;
  
  List<File?> roomPhotos; // For photo1, photo2, and photo3

  RoomUnit({
    required this.priceController,
    required this.roomNumberController,
    required this.capacityController,
    required this.depositController,
    required this.advanceController,
    //required this.reservationDurationController,
    required this.reservationFeeController,
    required this.roomPhotos, // Expecting up to 3 room photos
  });

  // Method to convert RoomUnit data to a format suitable for backend API (e.g., FormData)
  Map<String, dynamic> toMap() {
    return {
      'price': priceController.text,
      'roomNumber': roomNumberController.text,
      'capacity': capacityController.text,
      'deposit': depositController.text,
      'advancePayment': advanceController.text,
      //'reservationDuration': reservationDurationController.text,
      'reservationFee': reservationFeeController.text,
      'photo1': roomPhotos.isNotEmpty && roomPhotos[0] != null ? roomPhotos[0] : null,
      'photo2': roomPhotos.length > 1 && roomPhotos[1] != null ? roomPhotos[1] : null,
      'photo3': roomPhotos.length > 2 && roomPhotos[2] != null ? roomPhotos[2] : null,
    };
  }

  // You can add more helper functions or data transformation logic as needed
}
