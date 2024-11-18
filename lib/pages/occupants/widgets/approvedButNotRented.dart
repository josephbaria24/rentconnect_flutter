// inquiry_details_widget.dart

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:http/http.dart' as http;
import 'package:timeline_tile/timeline_tile.dart';

class Approvedbutnotrented extends StatefulWidget {
  final Map<String, dynamic> inquiry;
  final Map<String, dynamic> roomDetails;
  final String proofOfReservation;
  final String userId;
  final String token;
  final Function(String inquiryId, String token) cancelInquiry;
  final Function(String roomId, String proofOfReservation) deleteProof;
  final Function(String inquiryId, String userId, String roomId, String ownerId, String landlordEmail, String occupantName) uploadProofOfReservation;
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
    final ThemeController _themeController = Get.find<ThemeController>();



  @override
  void initState() {
    super.initState();
    _proofOfReservation = widget.proofOfReservation;
    _fetchLandlordProfile();
    _fetchOccupantProfile(); // Initialize with the widget's value
  }

 Map<String, dynamic>? landlordDetails;
 Map<String, dynamic>? occupantDetails;
 Future<void> _fetchLandlordProfile() async {
    final url = Uri.parse(
        'http://192.168.1.115:3000/user/${widget.roomDetails['ownerId']}'); // Adjust the endpoint if needed
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          landlordDetails = jsonDecode(response.body);
        });
      } else {
        print('No profile yet');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }
 Future<void> _fetchOccupantProfile() async {
    final url = Uri.parse(
        'http://192.168.1.115:3000/user/${widget.userId}'); // Adjust the endpoint if needed
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer ${widget.token}'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          occupantDetails = jsonDecode(response.body);
        });
      } else {
        print('No profile yet');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 1),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Text(
            'Proof of reservation',
            style: TextStyle(
              fontFamily: 'manrope',
              fontSize: 16,
              color: _themeController.isDarkMode.value
                  ? Colors.white
                  : const Color.fromARGB(255, 53, 53, 53),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text("Proof of reservation"),
                  content: Column(
                    children: const [
                      SizedBox(height: 8),
                      Text(
                        "Currently, our app doesn't support direct payment integrations with e-wallets, banks, or other financial systems. "
                        "We encourage you to upload proof of payment here to ensure transparency and verification between landlords and occupants. "
                        "Your payment receipts are securely stored and provide a record for the landlord to review and confirm transactions.",
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text("Got it"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.help_outline_outlined,
              color: _themeController.isDarkMode.value
                  ? Colors.white
                  : const Color.fromARGB(255, 54, 54, 54),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      
      if (_isUploading) // Show loading indicator if uploading
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: CupertinoActivityIndicator(),
        ),
      if (widget.proofOfReservation != null &&
          widget.proofOfReservation.isNotEmpty)
        Container(
        decoration: BoxDecoration(
          color: _themeController.isDarkMode.value? const Color.fromARGB(255, 75, 76, 87):Colors.black ,
          borderRadius: BorderRadius.circular(12),
          //border: Border.all(width: 0.5, color: _themeController.isDarkMode.value? Colors.white:Colors.black)
        ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // Image container for proof of reservation
                Expanded(
                  child: Column(
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
                                '${widget.proofOfReservation}?v=${DateTime.now().millisecondsSinceEpoch}',
                                fit: BoxFit.cover,
                                height: 150,
                                width: double.infinity,
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
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                          'Are you sure you want to delete this proof of reservation?'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        CupertinoDialogAction(
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                                color:
                                                    CupertinoColors.destructiveRed),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
            
                                if (shouldDelete == true) {
                                  await widget.deleteProof(
                                      widget.roomDetails["_id"],
                                      widget.proofOfReservation);
                                  // Optionally add logic to refresh or update the UI
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Spacing between image and button
            
                // Button for uploading or changing photo
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
                      widget.roomDetails['ownerId'],
                      landlordDetails!['email'],
                      occupantDetails!['profile']['firstName'],
                    );
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
                      color: widget.isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      else
        ShadButton(
          foregroundColor: widget.isDarkMode
              ? const Color.fromARGB(255, 0, 0, 0)
              : const Color.fromARGB(255, 255, 255, 255),
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
              widget.roomDetails['ownerId'],
              landlordDetails!['email'],
              occupantDetails!['profile']['firstName'],
            );
            setState(() {
              _isUploading = false;
            });
          },
          icon: const Icon(Icons.add_a_photo, color: Colors.grey,),
          child: Text(
            'Upload Photo',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      SizedBox(height: 10,),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: _themeController.isDarkMode.value? Colors.white:Colors.black)
        ),
        child: Column(
          children: [
            TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isFirst: true,
              afterLineStyle: const LineStyle(color: Colors.blue),
              indicatorStyle: IndicatorStyle(
                iconStyle:
                    IconStyle(iconData: Icons.pending_actions, color: Colors.white),
                width: 30,
                height: 30,
                color: Colors.blue,
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your email frequently for the inquiry result.',
                      style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.white60
                              : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isLast: true,
              beforeLineStyle: const LineStyle(color: Colors.blue),
              indicatorStyle: IndicatorStyle(
                iconStyle: IconStyle(
                    iconData: Icons.check_circle_outline, color: Colors.white),
                width: 30,
                height: 30,
                color: Colors.blue,
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approved',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact the landlord immediately for the payment of reservation.',
                      style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.white60
                              : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            fontFamily: 'manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

}

