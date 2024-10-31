// // room_details_tab.dart
// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rentcon/pages/components/countdown_reservation.dart';
// import 'package:rentcon/pages/fullscreenImage.dart';
// import 'package:rentcon/pages/occupants/widgets/detail_room_property.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:http/http.dart' as http;
// class RoomDetailsTab extends StatefulWidget {
//   final String userId;
//   final String token;
//   final Map<String, dynamic> selectedMonths;
//   final bool isDarkMode;
//   final Function toggleImageVisibility;
//   final bool isImageVisible;
//   final Map<String, dynamic>? propertyRoomDetails;

//   const RoomDetailsTab({
//     required this.userId,
//     required this.token,
//     required this.selectedMonths,
//     required this.isDarkMode,
//     required this.toggleImageVisibility,
//     required this.isImageVisible,
//     required this.propertyRoomDetails
//   });

//   @override
//   State<RoomDetailsTab> createState() => _RoomDetailsTabState();
// }

// class _RoomDetailsTabState extends State<RoomDetailsTab> {
      

//   Future<String?> getProofOfReservation(String roomId, String token) async {
//     final url =
//         'http://192.168.1.5:3000/payment/room/$roomId/proofOfReservation';

//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token', // Include the authorization token
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         // Assuming the proof of reservation URL is in data['proofOfReservation']
//         return data[
//             'proofOfReservation']; // Adjust based on the actual API response structure
//       } else {
//         print('Failed to load proof of reservation: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching proof of reservation: $e');
//       return null;
//     }
//   }
//  Future<List<Map<String, dynamic>>> fetchInquiries(
//       String userId, String token) async {
//     final response = await http.get(
//       Uri.parse('http://192.168.1.5:3000/inquiries/occupant/$userId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((inquiry) => inquiry as Map<String, dynamic>).toList();
//     } else {
//       throw Exception('Failed to load inquiries');
//     }
//   }


//  Future<String?> getProofOfPayment(String roomId, String token) async {
//     final String apiUrl =
//         'http://192.168.1.5:3000/room/$roomId/monthlyPayments'; // Update with your API endpoint

//     try {
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         // Check if the monthly payments exist and extract the proof of payment from the latest payment
//         if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
//           final List<dynamic> monthlyPayments = data['monthlyPayments'];
//           // Get the most recent proof of payment
//           final proofOfPayment =
//               monthlyPayments.last['proofOfPayment'] as String?;
//           return proofOfPayment; // Return the proof of payment URL
//         } else {
//           return null; // No payments found
//         }
//       } else {
//         throw Exception(
//             'Failed to fetch proof of payment: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching proof of payment: $e');
//       return null; // Return null if there's an error
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     print("property details ${widget.propertyRoomDetails}");
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder<List<Map<String, dynamic>>>(
//               future: fetchInquiries(widget.userId, widget.token),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (snapshot.hasData && snapshot.data != null) {
//                   final inquiries = snapshot.data!;
      
//                   if (inquiries.isEmpty) {
//                     return const Center(child: Text('No inquiries found.'));
//                   }
      
//                   return ListView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: inquiries.length,
//                     itemBuilder: (context, index) {
//                       final inquiry = inquiries[index];
//                       print('Inquiry Details: $inquiry');
//                       final roomDetails = inquiry['roomId'];
//                       print('Room Details: $roomDetails');
//                       final inquiryId = inquiry['_id'];
      
//                       if (roomDetails == null) {
//                         return const Center(child: Text('Invalid room information.'));
//                       }
      
//                       final String? roomPhotoUrl = roomDetails['photo1'] ??
//                           roomDetails['photo2'] ??
//                           roomDetails['photo3'];
//                       final String defaultPhoto = 'https://via.placeholder.com/150';
      
//                       // Initialize selected month for this inquiry if not already done
//                       if (!widget.selectedMonths.containsKey(inquiryId)) {
//                         widget.selectedMonths[inquiryId] = null;
//                       }
      
//                       return FutureBuilder<String?>(
//                         future: getProofOfReservation(roomDetails['_id'], widget.token),
//                         builder: (context, proofSnapshot) {
//                           final String? proofOfReservation = proofSnapshot.data ?? '';
      
//                           return Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: ShadCard(
//                               shadows: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   offset: Offset(0, 3),
//                                   blurRadius: 8,
//                                 ),
//                               ],
//                               backgroundColor: widget.isDarkMode
//                                   ? Color.fromARGB(255, 36, 38, 43)
//                                   : const Color.fromARGB(255, 255, 255, 255),
//                               border: Border(),
//                               width: 350,
//                               title: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       'Room: ${roomDetails['roomNumber']}',
//                                       style: TextStyle(
//                                         fontFamily: 'GeistSans',
//                                         color: widget.isDarkMode ? Colors.white : Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       // Ensure propertyRoomDetails is not null
//                                     final location = widget.propertyRoomDetails!['location'];
//                                     if (location != null && location['coordinates'] != null) {
//                                       final coordinates = location['coordinates'];
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => PropertyDetailsWidget(
//                                             location: '${widget.propertyRoomDetails!['street']}, ${widget.propertyRoomDetails!['barangay']}, ${widget.propertyRoomDetails!['city']}',
//                                             amenities: jsonDecode(widget.propertyRoomDetails!['amenities'][0]),
//                                             description: widget.propertyRoomDetails!['description'],
//                                             coordinates: coordinates.cast<double>(),
//                                             roomDetails: roomDetails,

//                                           ),
//                                         ),
//                                       );
//                                     } else {
//                                       // Handle the case where location or coordinates is null
//                                       print('Location or coordinates is missing for room details');
//                                     }
//                                     },
//                                     child: Text(
//                                       'View details',
//                                       style: TextStyle(
//                                         color: widget.isDarkMode
//                                             ? const Color.fromARGB(255, 255, 255, 255)
//                                             : const Color.fromARGB(255, 0, 0, 0),
//                                         fontWeight: FontWeight.w400,
//                                         fontFamily: 'geistsans',
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                   Icon(
//                                     CupertinoIcons.chevron_forward,
//                                     size: 16,
//                                   )
//                                 ],
//                               ),
//                               description: Text(
//                                 'Request Status: ${inquiry['status']}\nPrice: ₱${roomDetails['price']}',
//                                 style: TextStyle(
//                                   fontFamily: 'Roboto',
//                                   color: widget.isDarkMode ? Colors.white : const Color.fromARGB(255, 3, 3, 3),
//                                 ),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: [
//                                   if (inquiry['requestType'] == 'reservation' &&
//                                       inquiry['status'] == 'approved' &&
//                                       inquiry['isRented'] == false)
//                                     RemainingTimeWidget(
//                                       approvalDate: DateTime.parse(inquiry['approvalDate']),
//                                       reservationDuration: inquiry['reservationDuration'],
//                                     ),
//                                   const SizedBox(height: 16),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: widget.isDarkMode
//                                           ? const Color.fromARGB(255, 36, 38, 43)
//                                           : const Color.fromARGB(255, 255, 255, 255),
//                                       foregroundColor: Colors.white,
//                                       shadowColor: Colors.black,
//                                       elevation: 0,
//                                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     onPressed: () => widget.toggleImageVisibility(),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           widget.isImageVisible
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                           color: widget.isDarkMode ? Colors.white : Colors.black,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           widget.isImageVisible ? 'Hide Image' : 'Show Room Image',
//                                           style: TextStyle(
//                                             color: widget.isDarkMode ? Colors.white : Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (widget.isImageVisible)
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => FullscreenImage(
//                                               imageUrl: roomPhotoUrl,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: Hero(
//                                         tag: roomPhotoUrl!,
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(10),
//                                             border: Border.all(
//                                               width: 1,
//                                               color: widget.isDarkMode ? Colors.white : Colors.black,
//                                             ),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(5.0),
//                                             child: Image.network(
//                                               roomPhotoUrl ?? defaultPhoto,
//                                               fit: BoxFit.contain,
//                                               height: 150,
//                                               errorBuilder: (context, error, stackTrace) {
//                                                 return const Icon(
//                                                   Icons.error,
//                                                   color: Color.fromARGB(255, 190, 5, 51),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
