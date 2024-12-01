// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/theme_controller.dart';
import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timelines_plus/timelines_plus.dart';


class PaymentUploadWidget extends StatefulWidget {
  final String inquiryId;
  final String userId;
  final Map<String, dynamic> roomDetails;
  final String token;
  final Map<String, String?> selectedMonths;
  final Future<void> Function(String inquiryId, String userId, String roomId, String selectedMonth, String ownerId, String token, double amount) uploadProofOfPayment; 
  final bool isDarkMode;
  final TextEditingController amountController;

  const PaymentUploadWidget({
    required this.inquiryId,
    required this.userId,
    required this.roomDetails,
    required this.token,
    required this.selectedMonths,
    required this.uploadProofOfPayment,
    required this.isDarkMode,
    required this.amountController,
    Key? key,
  }) : super(key: key);

    void showMonthSelectionDialog(BuildContext context) {
    _PaymentUploadWidgetState? state =
        context.findAncestorStateOfType<_PaymentUploadWidgetState>();
    if (state != null) {
      state._showMonthSelectionDialog();
    }
  }
    // Define the button to trigger the month selection dialog

  @override
  _PaymentUploadWidgetState createState() => _PaymentUploadWidgetState();
}

class _PaymentUploadWidgetState extends State<PaymentUploadWidget> {
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final ThemeController _themeController = Get.find<ThemeController>();
  
  String? proofOfPaymentUrl;
  String? status;
  String? rejectionReason;
   String? lastSelectedMonth; // New variable to store the last selected month
  List<Map<String, dynamic>> monthlyPayments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setDefaultSelectedMonth();// Load the last selected month on initialization
    _fetchMonthlyPayments();
  }


  void _setDefaultSelectedMonth() {
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM').format(now); // Get current month name
    lastSelectedMonth = currentMonth; // Set it as the default selected month
    widget.selectedMonths[widget.inquiryId] = lastSelectedMonth; // Set the loaded month as the selected month
     _checkExistingPayment(lastSelectedMonth);
  }


  @override
  void dispose() {
    // Cancel any timers or subscriptions here
    super.dispose();
  }

  Future<void> _saveSelectedMonth(String month) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedMonth', month); // Save the selected month
  }


  // Method to expose just the "Select Month" button
// Function to get the shortened name of the month
String _getShortenedMonth(String? month) {
  if (month == null || month.isEmpty) {
    return 'N/A'; // or return an empty string
  }
  
  final monthNames = {
    'January': 'Jan',
    'February': 'Feb',
    'March': 'Mar',
    'April': 'Apr',
    'May': 'May',
    'June': 'Jun',
    'July': 'Jul',
    'August': 'Aug',
    'September': 'Sep',
    'October': 'Oct',
    'November': 'Nov',
    'December': 'Dec',
  };

  return monthNames[month] ?? month; // Fallback to the full month name if not found
}
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.3, color: _themeController.isDarkMode.value? Colors.white:Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Container to display the selected month
            Container(
              
              decoration: BoxDecoration(
                color:_themeController.isDarkMode.value? Colors.white: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _showMonthSelectionDialog, // Open month selection dialog on tap
                child: Column(
                  children: [
                    SizedBox(height: 5,),

                    _themeController.isDarkMode.value? Lottie.asset('assets/icons/calendar.json',repeat: false, height: 60) : Lottie.asset('assets/icons/calendarwhite.json',repeat: false, height: 60),
                    Text(
                      _getShortenedMonth(widget.selectedMonths[widget.inquiryId]),
                      style: TextStyle(
                        color: _themeController.isDarkMode.value?Colors.black: Colors.white,
                        fontSize: 27,
                        fontFamily: 'manrope',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16), // Spacing between the month container and payment photo
            Column(
              children: [
                 if (proofOfPaymentUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenImage(imageUrl: proofOfPaymentUrl!),
                    ),
                  );
                },
                child: Hero(
                  tag: proofOfPaymentUrl!,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1,
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.network(
                        proofOfPaymentUrl!,
                        fit: BoxFit.fitWidth,
                        height: 60,
                        width: 70,
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  if (_hasPaymentForMonth(widget.selectedMonths[widget.inquiryId] ?? ''))
                    SizedBox.shrink() // Hide if there is a payment
                  else
                    Column(
                      children: [
                        if (_isLoading) // Skeleton Loader for photo fetching
                          Skeletonizer(
                            enabled: _isLoading,
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        else
                          Lottie.asset('assets/icons/empty.json', height: 60, repeat: false),
                       // Text('Empty', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 5,),
               SizedBox(
              height: 30,
              child: TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero), // Remove padding
                  backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 108, 197, 248)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Reduce border radius
                    ),
                  ),
                ),
                onPressed: _uploadPayment,
                child: Center( // Center the text inside the button
                  child: Text(
                    proofOfPaymentUrl != null ? 'Change' : 'Upload',
                    style: TextStyle(
                      fontFamily: 'manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: proofOfPaymentUrl != null ? Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
              ],
            ),

            // Status Icon based on `status` value
            
            const SizedBox(width: 36), // Spacing between image and icon
            if (status != null)
              GestureDetector(
                onTap: () {
                  // Show dialog when status is rejected to display rejectionReason
                  if (status == 'rejected') {
                    _showRejectionDialog(context, rejectionReason!);
                  }
                },
                child: Column(
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                        fontFamily: 'manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      status == 'pending'
                          ? Icons.pending
                          : status == 'completed'
                              ? Icons.check_circle
                              : Icons.cancel,
                      color: status == 'pending'
                          ? Colors.orange
                          : status == 'completed'
                              ? Colors.green
                              : Colors.red,
                      size: 24,
                    ),
                    SizedBox(height: 4), // Add space between icon and text
                    Text(
                      status == 'pending'
                          ? 'Pending'
                          : status == 'completed'
                              ? 'Completed'
                              : 'Rejected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == 'pending'
                            ? Colors.orange
                            : status == 'completed'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}


/// Function to show the rejection reason in a dialog
Future<void> _showRejectionDialog(BuildContext context, String rejectionReason) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Apply 10 border radius
        ),
        title: Center(
          child: Text(
            'Rejection Reason',
            style: TextStyle(
              fontFamily: 'Manrope', // Set font family to Manrope
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          rejectionReason.isEmpty ? 'No rejection reason provided' : rejectionReason,
          style: TextStyle(
            fontFamily: 'Manrope', // Set font family to Manrope
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Manrope', // Set font family to Manrope
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}


  void _showMonthSelectionDialog() {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Changed to 2 buttons in a row
              childAspectRatio: 2,
            ),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final hasPayment = _hasPaymentForMonth(month);
              final isSelected = widget.selectedMonths[widget.inquiryId] == month;

              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: CupertinoButton(
                  onPressed: () async{
                    setState(() {
                      
                      _isLoading = true;
                    });
                     await Future.delayed(const Duration(seconds: 1));

                     setState(() {
                      widget.selectedMonths[widget.inquiryId] = month;
                     
                      _isLoading = false; // Stop loading
                    });
                    _checkExistingPayment(month); // Call the check function on selection
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ?  (_themeController.isDarkMode.value ? Colors.white: const Color.fromARGB(255, 0, 0, 0) )
                          : const Color.fromARGB(0, 177, 177, 177),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            color: isSelected
                                ? (_themeController.isDarkMode.value ? const Color.fromARGB(255, 0, 0, 0) : Colors.white)
                                : _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
                            fontFamily: 'manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (hasPayment)
                          const Icon(
                            Icons.check,
                            size: 17,
                            color: Color.fromARGB(255, 0, 151, 93),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
void _fetchMonthlyPayments() async {
  setState(() {
    _isLoading = true; // Set loading to true before the API call
  });

  try {
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/payment/room/${widget.roomDetails['_id']}/monthlyPayments'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        if (mounted) {
          setState(() {
            monthlyPayments = List<Map<String, dynamic>>.from(data['monthlyPayments']);
          });
        }
      } else {
        String message = 'Error: ${data['message'] ?? 'Unknown error'}';
        print(message); // Print to console
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      String message = 'Failed to fetch monthly payments. Status: ${response.statusCode}';
      print(message);
    }
  } catch (e) {
    String message = 'Error fetching payments. Please try again. Exception: $e';
    print(message); // Print to console
    
  } finally {
    // Ensure loading is set to false regardless of success or failure
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



  bool _hasPaymentForMonth(String month) {
    // Check if the proof of payment exists for the selected month
    for (var payment in monthlyPayments) {
      if (payment['month'] == month && payment['proofOfPayment'] != null) {
        return true; // Proof of payment exists for this month
      }
    }
    return false; // No proof of payment found for this month
  }

  // Function to check if payment exists for the selected month
void _checkExistingPayment(String? selectedMonth) async {
  if (selectedMonth != null) {
    setState(() {
      _isLoading = true; // Set loading to true before the API call
    });

    try {
      // Call the API to get monthly payments
      final response = await http.get(Uri.parse('https://rentconnect.vercel.app/payment/room/${widget.roomDetails['_id']}/monthlyPayments'));

      // Debugging: Print the response status and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          final monthlyPayments = data['monthlyPayments'] as List;

          // Check if the selected month has a corresponding payment
          for (var payment in monthlyPayments) {
            print('Checking payment for month: ${payment['month']}'); // Debugging
            if (payment['month'] == selectedMonth) {
              print('Found proof of payment for month: $selectedMonth'); // Debugging
              if (mounted) { // Check if the widget is still mounted before calling setState
                setState(() {
                  proofOfPaymentUrl = payment['proofOfPayment'];
                  status = payment['status'];
                  rejectionReason = payment['rejectionReason'];
                });
              }
              return;
            }
          }
        }
      } else {
       
      }
    } catch (e) {
      // Handle any exceptions during the API call
      print('Error fetching payments: $e'); // Debugging
      Fluttertoast.showToast(
        msg: 'Error fetching payments. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      // Ensure loading is set to false regardless of success or failure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // If no payment was found for the selected month, clear the URL
    if (mounted) { // Check if the widget is still mounted before calling setState
      setState(() {
        proofOfPaymentUrl = null;
      });
    }
  }
}

  // Function to handle the upload or change of proof of payment
  Future<void> _uploadPayment() async {
    String? selectedMonth = widget.selectedMonths[widget.inquiryId];
    String amount = widget.amountController.text;

    if (selectedMonth != null && selectedMonth.isNotEmpty) {
      double parsedAmount = double.tryParse(amount) ?? 0.0;

      await widget.uploadProofOfPayment(
        widget.inquiryId,
        widget.userId,
        widget.roomDetails['_id'],
        selectedMonth,
        widget.roomDetails['ownerId'],
        widget.token,
        parsedAmount,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Please select a month before uploading.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

}


