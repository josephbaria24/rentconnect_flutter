import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReservationDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> room;
  final Future<String?> Function(String roomId) fetchProofOfReservation;
  final Future<void> Function(String roomId) markRoomAsOccupied;
  final String token;
  final bool isDarkMode;

  const ReservationDetailsWidget({
    Key? key,
    required this.room,
    required this.fetchProofOfReservation,
    required this.markRoomAsOccupied,
    required this.token,
    required this.isDarkMode,
  }) : super(key: key);


Future<void> saveImage(String imageUrl, BuildContext context) async {
  try {
    // Fetch the image data from the URL
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // Convert the response body to Uint8List
      final Uint8List imageBytes = response.bodyBytes;

      // Save the image
      //final result = await ImageGallerySaver.saveImage(imageBytes);

      // Show a toast or Snackbar to inform the user that the image has been saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to gallery!')),
      );
    } else {
      // Handle error if the response is not 200
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch image.')),
      );
    }
  } catch (e) {
    // Handle exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving image: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text('Reservation Fee: ₱${room['reservationFee'] ?? 'N/A'}'),
        Text('Duration of Reservation: ${room['reservationDuration'] ?? 'N/A'} days'),
        const SizedBox(height: 10),
        Text(
          'Proof of Reservation:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        FutureBuilder<String?>(
          future: fetchProofOfReservation(room['_id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
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
                  // Show full-screen image with save option
                  showFullscreenImage(context, snapshot.data!);
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
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Text('No proof uploaded yet'),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Tooltip(
          message: 'Is the reserver moved-in?',
          child: ShadButton(
            onPressed: () async {
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
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('Confirm'),
                        isDestructiveAction: true,
                        onPressed: () async {
                          await markRoomAsOccupied(room["_id"]);

                          // Close the confirmation dialog
                          Navigator.of(context).pop();

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
                                          builder: (context) => CurrentListingPage(token: token),
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
            child: Text('Mark as Occupied'),
          ),
        )
      ],
    );
  }

  void showFullscreenImage(BuildContext context, String imageUrl) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.black,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the fullscreen image on tap
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4, // Limit height to 90% of screen
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child; // If loading complete
                          return Center(child: CircularProgressIndicator()); // Show loading indicator
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text('Error loading image', style: TextStyle(color: Colors.white)));
                        },
                      ),
                      Positioned(
                        top: 5,
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.download, color: Colors.white),
                          onPressed: () {
                            saveImage(imageUrl,context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }




}
