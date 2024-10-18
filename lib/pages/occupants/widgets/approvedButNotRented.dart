// inquiry_details_widget.dart

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Approvedbutnotrented extends StatefulWidget {
  final Map<String, dynamic> inquiry;
  final Map<String, dynamic> roomDetails;
  final String proofOfReservation;
  final String userId;
  final String token;
  final Function(String inquiryId, String token) cancelInquiry;
  final Function(String roomId, String proofOfReservation) deleteProof;
  final Function(String inquiryId, String userId, String roomId, String ownerId) uploadProofOfReservation;
  final bool isDarkMode; // Add this parameter

  const Approvedbutnotrented({
    Key? key,
    required this.inquiry,
    required this.roomDetails,
    required this.proofOfReservation,
    required this.userId,
    required this.token,
    required this.cancelInquiry,
    required this.deleteProof,
    required this.uploadProofOfReservation,
    required this.isDarkMode, // Include this parameter
  }) : super(key: key);

  @override
  State<Approvedbutnotrented> createState() => _ApprovedbutnotrentedState();
}



class _ApprovedbutnotrentedState extends State<Approvedbutnotrented> {
  bool _isUploading = false;
   String? _proofOfReservation;
  @override
  void initState() {
    super.initState();
    _proofOfReservation = widget.proofOfReservation; // Initialize with the widget's value
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      if (_isUploading) // Show loading indicator if uploading
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CupertinoActivityIndicator(),
        ),
      const SizedBox(height: 1),
      Text(
        'Request Type: ${widget.inquiry['requestType']}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        'Reservation fee: ${widget.roomDetails['reservationFee']}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text('Proof of reservation fee:', style: TextStyle(fontWeight: FontWeight.bold)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'You can upload a photo of the receipt or hand-to-hand payment',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'geistsans',
                fontSize: 12,
                color: Colors.grey,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      
      // Proof of reservation photo section
      if (widget.proofOfReservation != null && widget.proofOfReservation.isNotEmpty)
        Column(
          children: [
            Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      // Adding a cache-busting parameter to the URL
                      '${widget.proofOfReservation}?v=${DateTime.now().millisecondsSinceEpoch}',
                      fit: BoxFit.fitHeight,
                      height: 150,
                      width: 300,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text(
                              'Confirm Deletion',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this proof of reservation?',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: widget.isDarkMode
                                    ? CupertinoColors.white.withOpacity(0.7)
                                    : CupertinoColors.black.withOpacity(0.87),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? CupertinoColors.activeBlue
                                        : CupertinoColors.activeBlue,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                   Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OccupantInquiries(
                                        userId: widget.userId,
                                        token: widget.token,
                                      ),
                                    ),
                                  );
                                },
                               
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        await widget.deleteProof(widget.roomDetails["_id"], widget.proofOfReservation);
                        // Add logic to refresh or update UI
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDarkMode
                    ? Colors.white
                    : const Color.fromARGB(255, 1, 0, 40),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
              ),
              onPressed: () async {
                setState(() {
                  _isUploading = true;
                });
                await widget.uploadProofOfReservation(
                    widget.inquiry['_id'],
                    widget.userId,
                    widget.roomDetails['_id'],
                    widget.roomDetails['ownerId']);
                setState(() {
                  _isUploading = false;
                });
              },
              icon: SvgPicture.asset(
                'assets/icons/change.svg',
                color: widget.isDarkMode ? Colors.black : Colors.white,
              ),
              label: Text(
                'Change Photo',
                style: TextStyle(
                    color:
                        widget.isDarkMode ? Colors.black : Colors.white),
              ),
            ),
          ],
        )
      else
        ShadButton(
          backgroundColor: widget.isDarkMode
              ? Colors.white
              : const Color.fromARGB(255, 1, 0, 40),
          onPressed: () async {
            setState(() {
              _isUploading = true;
            });
            await widget.uploadProofOfReservation(
                widget.inquiry['_id'],
                widget.userId,
                widget.roomDetails['_id'],
                widget.roomDetails['ownerId']);
            setState(() {
              _isUploading = false;
            });
          },
          icon: const Icon(Icons.add_a_photo),
          child: Text(
            'Upload Photo',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        onPressed: () async {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(
                  "Cancel Inquiry",
                  style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white
                          : Colors.black),
                ),
                content: const Text(
                    "This action is irreversible. Do you want to proceed?"),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("No"),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      await widget.cancelInquiry(widget.inquiry['_id'], widget.token);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        },
        child: Text(
          'Cancel Inquiry',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.red : Colors.red,
            fontFamily: 'geistsans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

}

