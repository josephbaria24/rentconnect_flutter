// lib/components/reservation_details.dart

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReservationDetails extends StatefulWidget {
  final Map<String, dynamic> room;
  final String token;
  final bool mounted;
  final int? reservationDuration; // Add reservationDuration field
  final String selectedUserId;
  ReservationDetails({
    required this.room,
    required this.token,
    required this.mounted,
    required this.reservationDuration,
    required this.selectedUserId,
  });

  @override
  State<ReservationDetails> createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails> {
  Future<String?> fetchProofOfReservation(String roomId) async {
    try {
    // Example API call to fetch payment details
    var response = await http.get(Uri.parse('http://192.168.1.5:3000/payment/room/$roomId/proofOfReservation'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['proofOfReservation']; // Ensure the key matches your backend response
    } else {
      // Handle error, return null if not available
      return null;
    }
  } catch (e) {
    // Handle any errors during the request
    return null;
  }
  }
  String? selectedUserId; 

Future<void> markRoomAsOccupied(String roomId) async {
  if (widget.selectedUserId != null) {
    try {
      final response = await http.patch(
        Uri.parse('http://192.168.1.5:3000/rooms/$roomId/occupy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.selectedUserId, // Pass the userId from approved inquiry
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        // Handle success (e.g., show a success message, refresh UI)
        print('Room marked as occupied successfully');
      } else {
        // Handle error responses (e.g., log error)
        print('Error marking room as occupied: ${response.body}');
      }
    } catch (error) {
      print('Error occurred while marking room as occupied: $error');
    }
  } else {
    print('No userId found to mark as occupied');
  }
}


final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    print("userId${widget.selectedUserId}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text('Reservation Fee: ₱${widget.room['reservationFee'] ?? 'N/A'}'),
        Text('Duration of Reservation: ${widget.reservationDuration} days'), // Display reservationDuration
        const SizedBox(height: 10),
        Text('Proof of Reservation:', style: TextStyle(fontWeight: FontWeight.bold)),
        FutureBuilder<String?>(
          future: fetchProofOfReservation(widget.room['_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: CupertinoActivityIndicator(),
              );
            } else if (snapshot.hasError) {
              return Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Text('Error loading image'),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return GestureDetector(
                onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>  FullscreenImage(imageUrl: snapshot.data!)));
                },
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.webp',
                      image: snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(136, 131, 131, 131),
                ),
                alignment: Alignment.center,
                child: Text('No proof uploaded yet'),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Center(child: Text('Is the reservant moved-in?', style: TextStyle(
          fontFamily: 'geistsans',
          color: _themeController.isDarkMode.value? const Color.fromARGB(255, 216, 216, 216): const Color.fromARGB(193, 53, 53, 53),
          fontSize: 13,
        ),)),
        Tooltip(
          message: 'Is the reservant moved-in?',
          child: Center(
            child: ShadButton(
              backgroundColor: _themeController.isDarkMode.value? Colors.white: const Color.fromARGB(255, 0, 16, 34),
              onPressed: () async {
                if (!widget.mounted) return;

                // Show confirmation dialog
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text('Confirm Occupation'),
                      content: Text('Are you sure you want to mark this room as occupied?'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('Cancel'),
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog without action
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text('Confirm'),
                          isDestructiveAction: true,
                          onPressed: () async {
                            await markRoomAsOccupied(widget.room["_id"]);

                            Navigator.of(context).pop(); // Close confirmation dialog

                            // Show success dialog
                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: Text('Success'),
                                  content: Text('Successfully marked as occupied!'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close success dialog
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CurrentListingPage(token: widget.token),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Mark as Occupied', style: TextStyle(
                color: _themeController.isDarkMode.value? Colors.black: Colors.white
              ),),
            ),
          ),
        ),
      ],
    );
  }
}
