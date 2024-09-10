import 'dart:io';
import 'package:flutter/material.dart';

class RoomUnit {
  final TextEditingController priceController;
  final TextEditingController roomNumberController;
  final TextEditingController capacityController;
  final TextEditingController depositController;
  final TextEditingController advanceController;
  final TextEditingController reservationDurationController;
  final TextEditingController reservationFeeController;
  List<File?> roomPhotos;

  RoomUnit({
    required this.priceController,
    required this.roomNumberController,
    required this.capacityController,
    required this.depositController,
    required this.advanceController,
    required this.reservationDurationController,
    required this.reservationFeeController,
    required this.roomPhotos,
  });
}
