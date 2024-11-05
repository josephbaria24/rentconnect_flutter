// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/occupants/occupant_inquiries.dart';
import 'package:rentcon/theme_controller.dart';
import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';

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

  @override
  _PaymentUploadWidgetState createState() => _PaymentUploadWidgetState();
}bool _isLoading = false;
 List<Map<String, dynamic>> monthlyPayments = [];
class _PaymentUploadWidgetState extends State<PaymentUploadWidget> {
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final ThemeController _themeController = Get.find<ThemeController>();

  String? proofOfPaymentUrl;
 @override
  void initState() {
    super.initState();
    _fetchMonthlyPayments();
    _checkExistingPayment(widget.selectedMonths[widget.inquiryId]); // Fetch payments when the widget initializes
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Button to open the month selection dialog
        ShadButton.secondary(
          onPressed: _showMonthSelectionDialog,
          child: Text(
            widget.selectedMonths[widget.inquiryId] ?? 'Select Month',
            style: TextStyle(
              color: widget.selectedMonths[widget.inquiryId] != null ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: widget.selectedMonths[widget.inquiryId] != null ? const Color.fromARGB(255, 0, 24, 37) : const Color.fromARGB(255, 201, 200, 200),
        ),

        const SizedBox(height: 10),
        
        // Amount Input Field
        ShadInput(
          controller: widget.amountController,
          placeholder: Text('Amount(Optional):'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Display proof of payment or upload button
        if (proofOfPaymentUrl != null)
          Column(
            children: [
              Text('Proof Of Payment:', style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
              Image.network(proofOfPaymentUrl!),
              const SizedBox(height: 8),
              ShadButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Start loading
                });

                // Call your upload function and wait for it to complete
                await _uploadPayment();

                // Refresh the currentListingPage or any necessary data here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OccupantInquiries(token: widget.token, userId: widget.userId), // Your page to refresh
                  ),
                );

                setState(() {
                  _isLoading = false; // Stop loading
                });
              },
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                            : const Text('Change Photo'),
                      ),
            ],
          )
        else
          Center(
            child: Column(
            
              children: [
                
                ShadButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Start loading
                });

                // Call your upload function and wait for it to complete
                await _uploadPayment();

                // Refresh the currentListingPage or any necessary data here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OccupantInquiries(token: widget.token, userId: widget.userId,), // Your page to refresh
                  ),
                );

                setState(() {
                  _isLoading = false; // Stop loading
                });
              },
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                            : const Text('Upload Proof of Payment'),
                      ),
              ],
            ),
          ),
      ],
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
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 0, 24, 37)
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
                                ? (_themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.white)
                                : _themeController.isDarkMode.value ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
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
    try {
      final response = await http.get(Uri.parse('https://rentconnect.vercel.app/payment/room/${widget.roomDetails['_id']}/monthlyPayments'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          setState(() {
            monthlyPayments = List<Map<String, dynamic>>.from(data['monthlyPayments']);
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch monthly payments.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching payments. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
                setState(() {
                  proofOfPaymentUrl = payment['proofOfPayment'];
                });
                return;
              }
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to fetch monthly payments.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Handle any exceptions during the API call
        print('Error fetching payments: $e'); // Debugging
        Fluttertoast.showToast(
          msg: 'Error fetching payments. Please try again.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      // If no payment was found for the selected month, clear the URL
      setState(() {
        proofOfPaymentUrl = null;
      });
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


