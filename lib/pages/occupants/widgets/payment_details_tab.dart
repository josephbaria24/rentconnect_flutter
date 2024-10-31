// // room_details_tab.dart
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:rentcon/pages/landlords/PaymentLandlordSide.dart';
// import 'package:rentcon/pages/occupants/widgets/approvedButNotRented.dart';
// import 'package:rentcon/pages/occupants/widgets/pending.dart';
// import 'package:http/http.dart' as http;

// class PaymentDetailsTab extends StatefulWidget {
//   final String userId;
//   final String token;
//   final Function cancelInquiry;
//   final bool isDarkMode;
//   final Function uploadProofOfPayment;
//   final TextEditingController amountController;
//   final Function deleteProof;
//   final String uploadProofOfReservation;

//   const PaymentDetailsTab({
//     Key? key,
//     required this.userId,
//     required this.token,
//     required this.cancelInquiry,
//     required this.isDarkMode,
//     required this.uploadProofOfPayment,
//     required this.amountController,
//     required this.deleteProof,
//     required this.uploadProofOfReservation,
//   }) : super(key: key);

//   @override
//   State<PaymentDetailsTab> createState() => _PaymentDetailsTabState();
// }

// class _PaymentDetailsTabState extends State<PaymentDetailsTab> {
 
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


  
//   Future<void> _cancelInquiry(String inquiryId, String token) async {
//     final String apiUrl =
//         'http://192.168.1.5:3000/inquiries/delete/$inquiryId';
//     try {
//       final response = await http.delete(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         print('Inquiry deleted successfully');
//         // You can update the UI or show a success message
//         setState(() {});
//       } else {
//         print('Failed to delete inquiry: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleting inquiry: $e');
//     }
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(18.0),
//       child: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchInquiries(widget.userId, widget.token),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData && snapshot.data != null) {
//             final inquiries = snapshot.data!;

//             if (inquiries.isEmpty) {
//               return const Center(child: Text('No inquiries found.'));
//             }

//             return ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: inquiries.length,
//               itemBuilder: (context, index) {
//                 final inquiry = inquiries[index];
//                 final roomDetails = inquiry['roomId'];
//                 final inquiryId = inquiry['_id'];

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Insert your conditional rendering logic for each inquiry here
//                     if ((inquiry['status'] == 'pending' && inquiry['isRented'] == false) &&
//                         (inquiry['requestType'] == 'reservation' || inquiry['requestType'] == 'rent')) ...[
//                       Pending(
//                         inquiry: inquiry,
//                         token: widget.token,
//                         cancelInquiry: _cancelInquiry,
//                         isDarkMode: widget.isDarkMode,
//                       ),
//                     ] else if (inquiry['status'] == 'approved' && inquiry['requestType'] == 'rent' && inquiry['isRented'] == true) ...[
//                       PaymentUploadWidget(
//                         inquiryId: inquiryId,
//                         userId: widget.userId,
//                         roomDetails: roomDetails,
//                         token: widget.token,
//                         selectedMonths: [], // Pass selectedMonths if needed
//                         uploadProofOfPayment: widget.uploadProofOfPayment,
//                         isDarkMode: widget.isDarkMode,
//                         amountController: widget.amountController,
//                       ),
//                     ] else if (inquiry['status'] == 'approved' && inquiry['requestType'] == 'reservation' && inquiry['isRented'] == false) ...[
//                       Approvedbutnotrented(
//                         inquiry: inquiry,
//                         roomDetails: roomDetails,
//                         proofOfReservation: null, // Pass actual proofOfReservation if available
//                         userId: widget.userId,
//                         token: widget.token,
//                         cancelInquiry: _cancelInquiry,
//                         deleteProof: widget.deleteProof,
//                         uploadProofOfReservation: widget.uploadProofOfReservation,
//                         isDarkMode: widget.isDarkMode,
//                       ),
//                     ] else if (inquiry['status'] == 'approved' && inquiry['requestType'] == 'reservation' && inquiry['isRented'] == true) ...[
//                       PaymentUploadWidget(
//                         inquiryId: inquiryId,
//                         userId: widget.userId,
//                         roomDetails: roomDetails,
//                         token: widget.token,
//                         selectedMonths: [], // Pass selectedMonths if needed
//                         uploadProofOfPayment: widget.uploadProofOfPayment,
//                         isDarkMode: widget.isDarkMode,
//                         amountController: widget.amountController,
//                       ),
//                     ],
//                   ],
//                 );
//               },
//             );
//           }

//           return const Center(child: Text('No inquiries found.'));
//         },
//       ),
//     );
//   }
// }
