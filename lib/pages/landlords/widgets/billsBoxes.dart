// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers, sort_child_properties_last

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/landlords/widgets/billPage.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Billsboxes extends StatefulWidget {
  final List<dynamic>? inquiries;
  final String token;
  final String userID;
  final VoidCallback onRetry;

  const Billsboxes({
    required this.inquiries,
    required this.token,
    required this.userID,
    required this.onRetry,
    Key? key,
  }): super(key: key);

  @override
  State<Billsboxes> createState() => _BillsboxesState();
}


class _BillsboxesState extends State<Billsboxes> {
  bool _isLoading = false;
  bool _isSubmitting = false;
  final ThemeController _themeController = Get.find<ThemeController>();
  final Map<String, List<Map<String, dynamic>>> _savedBillsByType = {
    'electricity': [],
    'water': [],
    'maintenance': [],
    'internet': [],
  };

  late ToastNotification toastNotification;
  Map<String, dynamic>? userDetails;
  String _selectedPaymentMethod = 'E-wallet'; 
  String _paymentDetails = "";
  String _dueDate = ''; 
  // Add error state
  String? _error;

@override
  void initState() {
    super.initState();
    toastNotification = ToastNotification(context);
     _initializeData();
  }

 Future<void> refreshInquiries() async {
    // Example: Fetch updated inquiries from backend or update state
    print("Refreshing inquiries...");
    // Implement your actual refresh logic here
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Validate inquiries
      if (widget.inquiries == null || widget.inquiries!.isEmpty) {
        throw Exception('No inquiries available.');
      }

      // Any additional initialization logic

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      toastNotification.error('Failed to initialize: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



@override
Widget build(BuildContext context) {
  // Show loading indicator while initializing
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
        ),
      );
    }

    // Show error state if there's an error
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
           ElevatedButton(
            onPressed: () async {
             await refreshInquiries(); 
            widget.onRetry(); // Trigger the callback to reopen the modal
          }, // Call the callback on retry
            child: Text('Retry'),
          ),
          ],
        ),
      );
    }
  // Get the height of the keyboard
  double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Create billing statement',
            style: TextStyle(
              fontFamily: 'manrope',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: _themeController.isDarkMode.value ? Colors.white : Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Aligns both widgets vertically
                    children: [
                      Text(
                        'Due Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          fontSize: 13,
                          color:_themeController.isDarkMode.value ? Colors.white : Colors.black,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(7)),
                        alignment: Alignment.center, // Ensures text aligns centrally
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3),
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setState(() {
                                  _dueDate = "${picked.toLocal()}".split(' ')[0];
                                });
                              }
                            },
                            child: Text(
                              _dueDate.isEmpty ? 'Tap to Select Due Date' : _dueDate,
                              style: TextStyle(
                                color:_themeController.isDarkMode.value ? Colors.black : Colors.white,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes default padding
                              minimumSize: Size(0, 0), // Ensures minimal size
                              visualDensity: VisualDensity.compact, // Reduces the size of the button
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks tap target
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5,),
          const SizedBox(height: 10),
          // Payment Method Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Payment method:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _selectedPaymentMethod,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPaymentMethod = newValue!;
                                    _paymentDetails = ""; // Clear details when method changes
                                  });
                                },
                                dropdownColor: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                                items: <String>[
                                  'E-wallet',
                                  'Hand-to-hand',
                                  'Bank',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedPaymentMethod != 'Hand-to-hand') ...[
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _paymentDetails = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: _selectedPaymentMethod == 'E-wallet'
                                  ? 'E-wallet Account Details'
                                  : 'Bank Account Details',
                              labelStyle: TextStyle(
                                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(
                              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 5.0,
            runSpacing: 8.0,
            children: widget.inquiries!.map((inquiry) {
              return Column(
                children: [
                  // First row (Electricity and Water)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildBillBox(context, 'Electricity',
                                Icons.electrical_services, Colors.orange, inquiry['_id'], 'electricity'),
                            _buildSavedBillsDisplay('electricity'), // Display saved bills for Electricity
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          children: [
                            _buildBillBox(context, 'Water',
                                Icons.water_drop, Colors.blueAccent, inquiry['_id'], 'water'),
                            _buildSavedBillsDisplay('water'), // Display saved bills for Water
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second row (Maintenance and Internet)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildBillBox(context, 'Repair', Icons.build,
                                Colors.blueGrey, inquiry['_id'], 'maintenance'),
                            _buildSavedBillsDisplay('maintenance'), // Display saved bills for Maintenance
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          children: [
                            _buildBillBox(context, 'Internet', Icons.wifi,
                                Colors.greenAccent, inquiry['_id'], 'internet'),
                            _buildSavedBillsDisplay('internet'), // Display saved bills for Internet
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Center(
            child: ShadButton(
              backgroundColor:
                  _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 0, 6, 22),
              onPressed: _isLoading ? null : _submitAllBills, // Disable button if loading
              child: _isLoading
                  ? CupertinoActivityIndicator(
                      color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                    ) // Show spinner when loading
                  : Text(
                      'Create',
                      style: TextStyle(
                        color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                      ),
                    ),
            ),
          ),
          // Conditionally add the SizedBox when the keyboard is visible
          if (keyboardHeight > 0) SizedBox(height: 150),
        ],
      ),
    ),
  );
}
void _submitAllBills() async {
  if (widget.inquiries == null || widget.inquiries!.isEmpty) {
    toastNotification.warn('No inquiries available to submit bills.');
    return;
  }

  if (_dueDate.isEmpty) {
    toastNotification.warn('Please select a due date.');
    return;
  }

  bool hasBills = _savedBillsByType.values.any((bills) => bills.isNotEmpty);
  if (!hasBills) {
    toastNotification.warn('Please add at least one bill before submitting.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    Map<String, dynamic> requestBody = {
      'dueDate': _dueDate,
      'paymentMethod': {
        'type': _selectedPaymentMethod,
        'details': _paymentDetails.isEmpty ? null : _paymentDetails,
      }
    };

    _savedBillsByType.forEach((key, value) {
      final lastBill = value.isNotEmpty ? value.last : {'amount': 0};
      requestBody[key] = lastBill;
    });

    final inquiryId = widget.inquiries!.first['_id'];

    final response = await http.post(
      Uri.parse('https://rentconnect.vercel.app/inquiries/$inquiryId/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final inquiry = responseBody['inquiry'];

      if (inquiry != null && inquiry['roomBills'] != null) {
        final List<dynamic> roomBills = inquiry['roomBills'];

        // Find the most recently created bill by created_at timestamp
        roomBills.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA); // Sort in descending order
        });

        final newestBill = roomBills.isNotEmpty ? roomBills.first : null;
        if (newestBill != null && newestBill['_id'] != null) {
          String billId = newestBill['_id'];
          print('Newest bill ID: $billId');
          _showBill(context, billId);
          toastNotification.success('Bills added successfully');
        } else {
          toastNotification.warn('Could not identify the newest bill.');
        }
      } else {
        toastNotification.warn('No room bills found in the response.');
      }
    } else if (response.statusCode == 409) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String? billId = responseBody['billId'];
      if (billId != null) {
        _showExistingBillDialog(context, billId);
      } else {
        toastNotification.error('Conflict detected but no bill ID returned.');
      }
    } else {
      toastNotification.warn('Failed to add bills.');
    }
  } catch (e) {
    print('Error occurred: $e');
    toastNotification.error('An error occurred while submitting bills.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}




  Widget _buildBillBox(BuildContext context, String title, IconData icon, Color color, String inquiryId, String billType) {
    return GestureDetector(
      onTap: () {
        _showBillPopover(context, title, icon, color, inquiryId, billType);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _themeController.isDarkMode.value? Colors.black12: const Color.fromARGB(28, 75, 198, 207),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                SizedBox(width: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right_outlined, size: 17),
          ],
        ),
      ),
    );
  }

void _showBillPopover(BuildContext context, String title, IconData icon, Color color, String inquiryId, String billType) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Decreased border radius
        ),
        title: Text(title, style: TextStyle(fontFamily: 'manrope', fontWeight: FontWeight.w600),),
        content: _buildPopoverForm(icon, color, title, inquiryId, billType),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close',style: TextStyle(color: Colors.redAccent),),
              ),
              
            ],
          ),
        ],
      );
    },
  );
}

Widget _buildPopoverForm(IconData icon, Color color, String title, String inquiryId, String billType) {
  final TextEditingController _amountController = TextEditingController();
  bool _isPaid = false;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
        labelStyle: TextStyle(
          fontFamily: 'manrope',
          fontSize: 14, color:_themeController.isDarkMode.value? Colors.white:Colors.black
        ),
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey, // Border color when not focused
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _themeController.isDarkMode.value?Colors.white: const Color.fromARGB(255, 0, 0, 0), // Border color when focused (pressed)
            width: 2.0, // You can adjust the width of the focused border
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      

            ),
            SizedBox(height: 7),
            ShadButton(
                backgroundColor: _themeController.isDarkMode.value?Colors.white:Colors.black,
                onPressed: () {
                   final amount = _amountController.text;

            // Validate the amount and prevent empty submission
            if (amount.isEmpty) {
              toastNotification.warn('Please enter a valid amount');
              return; // Stop execution if amount is invalid
            }
            _updateBillData(billType, amount, _dueDate, _isPaid);
            Navigator.of(context).pop(); // Close popover after saving
                },
                child: Text('Save Bill',style: TextStyle(color: _themeController.isDarkMode.value? Colors.black:Colors.white),)
              ),
          ],
        );
      }


  void _updateBillData(String billType, String amount, String dueDate, bool isPaid) {
    // Add the saved bill to the list for display, replacing the existing one
    _savedBillsByType[billType]!.clear(); // Clear existing bills before adding new one
    _savedBillsByType[billType]!.add({
      'type': billType,
      'amount': double.tryParse(amount), // Use tryParse to safely convert to double
      'dueDate': dueDate, // Include the shared due date
      'isPaid': isPaid,
      'paymentDate': null, // You can modify this later if needed
    });
    print('Updating bill data for $billType: ${_savedBillsByType[billType]}'); // Log for debugging
  }









Future<dynamic> fetchExistingBill(String billId) async {
  final response = await http.get(
    Uri.parse('https://rentconnect.vercel.app/inquiries/bills/getBillId/$billId'),
  );

  print('Response status: ${response.statusCode}');
  print('Response body in fetch: ${response.body}');

  if (response.statusCode == 200) {
    return json.decode(response.body); // Return the bill details
  } else {
    throw Exception('Failed to load existing bill');
  }
}



void _showExistingBillDialog(BuildContext context, String billId) {
  fetchExistingBill(billId).then((response) {
    if (!mounted) return;

    if (response is Map<String, dynamic>) {
      // Show the dialog with the fetched bill data
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Bill Already Exists'),
            content: Text('A bill for this month already exists. Do you want to view it?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate to the view existing bill page using the billId and response data
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewBillPage(billId: billId, userID: widget.userID, token: widget.token,), // Pass the full bill details
                    ),
                  );
                },
                child: Text('View'),
              ),
              
            ],
          );
        },
      );
    } else {
      print('No existing bill found or response format is incorrect');
    }
  }).catchError((error) {
    if (mounted) {
      print('Error fetching existing bill: $error');
    }
  });
}


void _showBill(BuildContext context, String billId) {
  fetchExistingBill(billId).then((response) {
    if (!mounted) return;

    if (response is Map<String, dynamic>) {
      // Show the dialog with the fetched bill data
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('View bill'),
            content: Text('A bill for this month is successfully created. Do you want to view it?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate to the view existing bill page using the billId and response data
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewBillPage(billId: billId, userID: widget.userID, token: widget.token,), // Pass the full bill details
                    ),
                  );
                },
                child: Text('View'),
              ),
              
            ],
          );
        },
      );
    } else {
      print('No bill found or response format is incorrect');
    }
  }).catchError((error) {
    if (mounted) {
      print('Error fetching existing bill: $error');
    }
  });
}






Widget _buildSavedBillsDisplay(String billType) {
  final savedBills = _savedBillsByType[billType] ?? [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: savedBills.map((bill) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column( // Use Column for two lines of text
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: \₱${bill['amount']}',
              style: TextStyle(fontSize: 15, fontFamily: 'geistmono'),
            ),
            Text(
              'Paid: ${bill['isPaid'] ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 14,fontFamily: 'geistmono'),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

}
