// lib/components/payment_details.dart

// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotPaymentDetails extends StatefulWidget {
  final Map<String, dynamic>? room;
  DateTime? selectedDueDate;
  String? selectedMonth;
  final String token;
  final Widget Function(Map<String, dynamic>?) buildMonthButtons;

  NotPaymentDetails({
    this.room,
    this.selectedDueDate,
    this.selectedMonth,
    required this.buildMonthButtons,
    required this.token,
  });

  @override
  State<NotPaymentDetails> createState() => _NotPaymentDetailsState();
}

class _NotPaymentDetailsState extends State<NotPaymentDetails> {
  String _status = 'pending'; // Default value for status
  Future<Map<String, dynamic>?>? proofFuture;
   final ThemeController _themeController = Get.find<ThemeController>();
    List<String> months = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];
  int currentMonthIndex = 0;



  DateTime? _localSelectedDueDate;
  @override
  void initState() {
    super.initState();

     currentMonthIndex = DateTime.now().month - 1; // January = 0
    widget.selectedMonth ??= months[currentMonthIndex]; // Set current month if not already set
     _localSelectedDueDate = widget.selectedDueDate;
    proofFuture = getProofOfPaymentForSelectedMonth(
      widget.room?['_id'],
      widget.token,
      widget.selectedMonth!,
    ).then((data) {
    if (data != null) {
      setState(() {
        _status = data['paymentStatus']; // Set status from API
      });
    }
    return data;
  });
  }



Future<void> handleUpdateStatus(String selectedMonth, String status) async {
  final proofData = await getProofOfPaymentForSelectedMonth(
    widget.room?['_id'],
    widget.token,
    selectedMonth,
  );

  if (proofData != null) {
    final monthlyPaymentId = proofData['monthlyPaymentId']; // Get the monthlyPaymentId
    await updatePaymentStatus(monthlyPaymentId, status); // Pass it to the update function
    // Update the due date if the status is 'completed' (or any other condition you want)
    if (status == 'completed') {
      await updateDueDate(widget.room?['_id'], widget.selectedDueDate!, widget.token); // Call the new update function
    }
  } else {
    print('No payment data available for the selected month.');
  }
}

Future<void> updateDueDate(String roomId, DateTime dueDate, String token) async {
  final String apiUrl = 'http://192.168.1.8:3000/rooms/$roomId/due-date';

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dueDate': dueDate.toIso8601String(), // Convert DateTime to ISO 8601 string
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated the due date
      print('Due date updated successfully');
      
      // Update the local selected due date
      setState(() {
        widget.selectedDueDate = dueDate; // Ensure this reflects the new due date
      });

      // Optionally refresh the proof of payment data
      proofFuture = getProofOfPaymentForSelectedMonth(
        widget.room?['_id'],
        widget.token,
        widget.selectedMonth!,
      );
    } else {
      print('Failed to update due date: ${response.statusCode}');
      // Handle errors (e.g., show a message to the user)
    }
  } catch (e) {
    print('Error updating due date: $e');
    // Handle network or other errors
  }
}

void _selectDueDate(BuildContext context) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: widget.selectedDueDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    // Set the time to midnight (00:00) and then convert to UTC
    DateTime selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 0, 0, 0);
    DateTime selectedDateUtc = selectedDate.toUtc(); // Convert the date to UTC

    setState(() {
      widget.selectedDueDate = selectedDateUtc;

      // Log the selected date in UTC to verify
      print('Due Date Selected (UTC): ${widget.selectedDueDate?.toIso8601String()}');

      // Call the function to save the due date, passing the selected UTC date to the backend
      updateDueDate(widget.room!['_id'], widget.selectedDueDate!, widget.token);
    });
  }
}






void _updateDueDateToNextMonth() {
  if (widget.selectedDueDate != null) {
    // Get the current selected due date
    DateTime dueDate = widget.selectedDueDate!;
    // Create a new date for the same day next month
    DateTime nextMonthDueDate = DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
    setState(() {
      widget.selectedDueDate = nextMonthDueDate; // Update the due date
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
SizedBox(
  width: double.infinity, // Set width to max
  child: InkWell(
    onTap: () => _selectDueDate(context), // Handle tap
    borderRadius: BorderRadius.circular(10), // Make the ripple effect round
    child: Container(
      decoration: BoxDecoration(
        color: _themeController.isDarkMode.value? const Color.fromARGB(131, 30, 69, 100): Color.fromARGB(28, 75, 148, 207),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // Allow text to take remaining space
              child: SingleChildScrollView( // Make text scrollable if too long
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date: ${widget.selectedDueDate != null ? DateFormat('MMMM dd, yyyy').format(widget.selectedDueDate!) : 'N/A'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Tap here to set due date',
                      style: TextStyle(
                        color: _themeController.isDarkMode.value ? Colors.blueAccent : Colors.blueAccent,
                        fontFamily: 'geistsans',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Lottie.network(
              'https://lottie.host/84c5573f-ccdc-4677-ab3e-53eb235c9e80/8hyhfAO3Pb.json',
              height: 100,
            width: 100,
            ),
          ],
        ),
      ),
    ),
  ),
),

      const SizedBox(height: 5),
        Text('Total Amount: ₱${widget.room?['price'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600),),
        const SizedBox(height: 5),
        Text('Tap the months to see the photo.', style: TextStyle(color: _themeController.isDarkMode.value? const Color.fromARGB(255, 189, 189, 189):
        const Color.fromARGB(172, 71, 71, 71)),),
        const SizedBox(height: 5),

        // Call buildMonthButtons with only the room argument
        widget.buildMonthButtons(widget.room), 
        const SizedBox(height: 4),

        Text(
          'Proof of Payment:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        FutureBuilder<Map<String, dynamic>?>(
          future: proofFuture,
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
                alignment: Alignment.center,
                child: Text('Error loading image'),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullscreenImage(
                                  imageUrl: snapshot.data!['proofOfPayment'])));
                    },
                    child: Container(
                      height: 130,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              snapshot.data!['proofOfPayment'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                '${widget.selectedMonth}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 4.0,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Checkbox section for status (Completed, Rejected)
                  const SizedBox(height: 10),
                  Text(
                    'Payment Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: const Color.fromARGB(255, 0, 248, 165),
                            value: _status == 'completed',
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _status = 'completed';
                                }
                              });
                            },
                          ),
                          const Text('Completed'),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            activeColor: const Color.fromARGB(255, 0, 248, 165),
                            value: _status == 'rejected',
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _status = 'rejected';
                                }
                              });
                            },
                          ),
                          const Text('Rejected'),
                        ],
                      ),
                    ],
                  ),
                  Center(
                    child: ShadButton(
                      backgroundColor: _themeController.isDarkMode.value
                          ? Colors.white
                          : Colors.black,
                      onPressed: () async {
                        if (widget.selectedMonth != null) {
                          await handleUpdateStatus(widget.selectedMonth!, _status);
                          Get.snackbar(
                            '',
                            '',
                            titleText: Text(
                              'Success',
                              style: TextStyle(
                                color: _themeController.isDarkMode.value
                                    ? Colors.green
                                    : const Color.fromARGB(255, 1, 139, 6),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            messageText: Text('Payment status updated!'),
                            duration: Duration(seconds: 2),
                          );
                        } else {
                          print('Selected month is null');
                        }
                      },
                      child: Text(
                        'Update Status',
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('No proof uploaded for ${widget.selectedMonth}'),
              );
            }
          },
        ),
      ],
    );
  }

  
Future<Map<String, dynamic>?> getProofOfPaymentForSelectedMonth(
    String roomId, String token, String selectedMonth) async {
  final String apiUrl = 'http://192.168.1.8:3000/payment/room/$roomId/monthlyPayments';

  try {
    print('API URL: $apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
        final List<dynamic> monthlyPayments = data['monthlyPayments'];

        // Find the payment for the selected month
        final paymentForMonth = monthlyPayments.firstWhere(
          (payment) => payment['month'] == selectedMonth,
          orElse: () => null, // If no payment is found for that month
        );

        if (paymentForMonth != null) {
          final proofOfPayment = paymentForMonth['proofOfPayment'];
          final paymentStatus = paymentForMonth['status']; // Get the status
          final monthlyPaymentId = paymentForMonth['_id']; // Get the monthlyPaymentId
          return {
            'proofOfPayment': proofOfPayment,
            'paymentStatus': paymentStatus, // Include the status
            'monthlyPaymentId': monthlyPaymentId,
          };
        }
      }
    }
  } catch (e) {
    print('Error fetching proof of payment: $e');
  }
  return null;
}
  Future<void> updatePaymentStatus(String monthPaymentId, String status) async {
    final String apiUrl = 'http://192.168.1.8:3000/payment/monthlyPayments/$monthPaymentId/status';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}), // Sending the new status
      );

      if (response.statusCode == 200) {
        // Successfully updated the status
        final updatedPayment = jsonDecode(response.body);
        print('Payment status updated: $updatedPayment');
        // You may want to show a success message or refresh data
      } else if (response.statusCode == 404) {
        print('Monthly Payment not found.');
        // Handle not found error (maybe show a message to the user)
      } else {
        print('Failed to update payment status: ${response.statusCode}');
        // Handle other errors (maybe show a message to the user)
      }
    } catch (e) {
      print('Error updating payment status: $e');
      // Handle network or other errors
    }
  }



  // Future<void> handleUpdateStatus(String selectedMonth, String status) async {
  //   final proofData = await getProofOfPaymentForSelectedMonth(
  //     widget.room?['_id'],
  //     widget.token,
  //     selectedMonth,
  //   );

  //   if (proofData != null) {
  //     final monthlyPaymentId = proofData['monthlyPaymentId']; // Get the monthlyPaymentId
  //     await updatePaymentStatus(monthlyPaymentId, status); // Pass it to the update function
  //   } else {
  //     print('No payment data available for the selected month.');
  //   }
  // }

}