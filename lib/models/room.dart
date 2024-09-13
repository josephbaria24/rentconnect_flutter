import 'package:flutter/material.dart';

class Room {
  final String id;
  final String propertyId;
  final int roomNumber;
  final double price;
  final int capacity;
  final double deposit;
  final double advance;
  final String reservationDuration;
  final double reservationFee;
  final List<String> photos;

  Room({
    required this.id,
    required this.propertyId,
    required this.roomNumber,
    required this.price,
    required this.capacity,
    required this.deposit,
    required this.advance,
    required this.reservationDuration,
    required this.reservationFee,
    required this.photos,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      propertyId: json['propertyId'],
      roomNumber: json['roomNumber'],
      price: json['price'].toDouble(),
      capacity: json['capacity'],
      deposit: json['deposit'].toDouble(),
      advance: json['advance'].toDouble(),
      reservationDuration: json['reservationDuration'],
      reservationFee: json['reservationFee'].toDouble(),
      photos: List<String>.from(json['photos']),
    );
  }
}
