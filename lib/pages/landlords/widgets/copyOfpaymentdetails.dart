// lib/components/payment_details.dart

// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:rentcon/pages/components/tutorial_targets.dart';


class PaymentDetails extends StatefulWidget {
  final Map<String, dynamic>? room;
  DateTime? selectedDueDate;
  String? selectedMonth;
  final String token;

  PaymentDetails({
    this.room,
    this.selectedDueDate,
    this.selectedMonth,
    required this.token,
  });

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  String _status = ''; // Default value for status
  Future<Map<String, dynamic>?>? proofFuture;
  final ThemeController _themeController = Get.find<ThemeController>();
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  late ScrollController _scrollController;
  int _currentMonthIndex = 0; // Track the current month index

    List<TargetFocus> targets = [];

    GlobalKey _dueDateKey = GlobalKey();
    GlobalKey _paymentStatus = GlobalKey();
    GlobalKey _proofOfPaymentKey = GlobalKey();
    GlobalKey _monthlyPaymentKey = GlobalKey();








  @override
  void initState() {
    super.initState();
    _currentMonthIndex = DateTime.now().month - 1; // January = 0
    _selectedMonth =
        months[_currentMonthIndex]; // Set current month if not already set
    _selectedMonth = _selectedMonth;
    fetchAndSetStatus(); // Fetch and set payment status
    proofFuture = getProofOfPaymentForSelectedMonth(
        widget.room!['_id'], widget.token, _selectedMonth);
    _fetchProofForAllMonths(widget.room?['_id'], widget.token);
    handleUpdateStatus(_selectedMonth, _status);

    // Scroll to the selected month index
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(_currentMonthIndex);
    });



     // Check if the tutorial should be shown (every 2 days)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _checkAndShowTutorial();
  });
    // Initialize targets
    targets = createTutorialTargets(
      _dueDateKey,
      _paymentStatus,
      _proofOfPaymentKey,
      _monthlyPaymentKey,
    );
  }


// Function to check and show tutorial only once every 2 days
Future<void> _checkAndShowTutorial() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? lastShownTimestamp = prefs.getInt('last_tutorial_timestamp');
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

  // Check if lastShownTimestamp exists and if it's been 2 days (2 * 24 * 60 * 60 * 1000 milliseconds)
  if (lastShownTimestamp == null || currentTimestamp - lastShownTimestamp >= 2 * 24 * 60 * 60 * 1000) {
    // Delay for 1 second, then show tutorial
    Future.delayed(Duration(seconds: 1), () {
      _showTutorial();
    });

    // Update the last shown timestamp
    await prefs.setInt('last_tutorial_timestamp', currentTimestamp);
  }
}


void _showTutorial() {
    TutorialCoachMark(
      opacityShadow: 0.8,
      targets: targets,
      colorShadow:_themeController.isDarkMode.value? const Color.fromARGB(255, 102, 102, 102): Colors.black.withOpacity(0.8),
      textSkip: "SKIP",
      alignSkip: Alignment.topRight,
      textStyleSkip: TextStyle(color: _themeController.isDarkMode.value? Colors.white: Colors.white, fontFamily: 'manrope', fontSize: 17, fontWeight: FontWeight.w600),
      onFinish: () {
        print("Tutorial finished");
      },
      onSkip: () {
        print("Tutorial skipped");
        return true; 
      },
    ).show(context: context);
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Function to fetch the status for the selected month
  Future<void> fetchAndSetStatus() async {
    proofFuture = getProofOfPaymentForSelectedMonth(
        widget.room!['_id'], widget.token, _selectedMonth);

    proofFuture!.then((data) {
      if (data != null) {
        setState(() {
          _status = data['paymentStatus'] ?? 'pending'; // Set fetched status
        });
      }
    });
  }




  Future<Map<String, dynamic>?> getProofOfPaymentForSelectedMonth(
      String roomId, String token, String selectedMonth) async {
    final String apiUrl =
        'https://rentconnect.vercel.app/payment/room/${widget.room?['_id']}/monthlyPayments';

    try {
      print('API URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      //print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        //print('Response Data: $data'); // Add this line
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
            final monthlyPaymentId = paymentForMonth['_id'];
            return {
              'paymentStatus': paymentStatus,
              'proofOfPayment': proofOfPayment,
              'monthlyPaymentId': monthlyPaymentId,
            }; // Return both proof and ID
          } else {
            
            return null; // No payment found for the selected month
          }
        } else {
          print('No payments found or empty monthlyPayments.');
          return null;
        }
      } else {
        throw Exception(
            'Failed to fetch proof of payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching proof of payment: $e');
      return null;
    }
  }

  Map<String, bool> _monthsWithProof = {
    'January': false,
    'February': false,
    'March': false,
    'April': false,
    'May': false,
    'June': false,
    'July': false,
    'August': false,
    'September': false,
    'October': false,
    'November': false,
    'December': false,
  };

  Future<void> _fetchProofForAllMonths(String? roomId, String token) async {
    if (widget.room?['_id'] == null) return; // Early return if roomId is null

    for (String month in _monthsWithProof.keys) {
      final proof = await getProofOfPaymentForSelectedMonth(
          widget.room?['_id'], widget.token, month);
      setState(() {
        _monthsWithProof[month] = proof != null; // Set to true if proof exists
      });
    }
  }

  Future<void> _onMonthSelected(
      String month, Map<String, dynamic> room, BuildContext context) async {
    if (!mounted) return;

    _selectedMonth = month; // Update the selected month
    _currentMonthIndex =
        months.indexOf(month); // Update the current month index

    proofFuture = getProofOfPaymentForSelectedMonth(
            widget.room!['_id'], widget.token, month)
        .then((data) {
      if (data != null) {
        setState(() {
          _status = data['paymentStatus'] ?? 'pending'; // Update status
        });
      }
      return data;
    });

    // Close any existing dialogs
    _scrollToSelectedMonth(_currentMonthIndex);
    //Navigator.of(context).pop();
  }

  // Function to scroll to the selected month and center it
  void _scrollToSelectedMonth(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = 80; // Estimated width of each button
    final double scrollPosition =
        index * itemWidth - (screenWidth - itemWidth) / 2;

    _scrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildMonthButtons(
      Map<String, dynamic> room, BuildContext context, int currentMonthIndex) {
    return Container(
      decoration: ShapeDecoration(shape: RoundedRectangleBorder()),
      height: 42,
      width: double.infinity,
      child: Row(
        children: [
          if (months.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: SizedBox(
                width: 20,
                child: IconButton(
                  icon: Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    // Handle left arrow click (optional)
                  },
                ),
              ),
            ),

          // Month Buttons with ScrollController
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              itemBuilder: (BuildContext context, int index) {
                String month = months[index];
                bool isSelected = index == currentMonthIndex;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4),
                  child: Stack(
                    alignment: Alignment
                        .centerRight, // Position the icons to the right
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _onMonthSelected(month, room, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color.fromARGB(255, 26, 100, 238)
                              : _themeController.isDarkMode.value
                                  ? const Color.fromARGB(255, 134, 133, 133)
                                  : const Color.fromARGB(255, 134, 134, 134),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 2,
                        ),
                        child: Row(
                          children: [
                            Text(
                              month,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Display icon based on payment status
                      Positioned(
                        right: 2,
                        top: 2, // Adjust position
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: getProofOfPaymentForSelectedMonth(
                              widget.room?['_id'], widget.token, month),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox
                                  .shrink(); // Don't show anything while loading
                            }
                            if (snapshot.hasData) {
                              final paymentStatus =
                                  snapshot.data?['paymentStatus'];
                              if (paymentStatus == 'completed') {
                                return Icon(Icons.circle,
                                    color:
                                        const Color.fromARGB(255, 80, 199, 84),
                                    size: 12);
                              } else if (paymentStatus == 'pending') {
                                return Icon(Icons.circle,
                                    color: Colors.orange,
                                    size: 12); // Red dot for pending
                              } else if (paymentStatus == 'rejected') {
                                return Icon(Icons.circle,
                                    color: Colors.red,
                                    size: 12); // 'X' for rejected
                              }
                            }
                            return SizedBox
                                .shrink(); // No icon if no proof or invalid status
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (months.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 20,
                child: IconButton(
                  icon: Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    // Handle right arrow click (optional)
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> updatePaymentStatus(String monthPaymentId, String status) async {
    final String apiUrl =
        'https://rentconnect.vercel.app/payment/monthlyPayments/$monthPaymentId/status';

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

  Future<void> handleUpdateStatus(String selectedMonth, String status) async {
    final proofData = await getProofOfPaymentForSelectedMonth(
      widget.room?['_id'],
      widget.token,
      selectedMonth,
    );

    if (proofData != null) {
      final monthlyPaymentId =
          proofData['monthlyPaymentId']; // Get the monthlyPaymentId
      await updatePaymentStatus(
          monthlyPaymentId, status); // Pass it to the update function
      // Update the due date if the status is 'completed' (or any other condition you want)
      if (status == 'completed') {
        await updateDueDate(widget.room?['_id'], widget.selectedDueDate!,
            widget.token); // Call the new update function
      }
    } else {
      print('No payment data available for the selected month.');
    }
  }





@override
Widget build(BuildContext context) {
  print(widget.room?['_id']);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rent payment details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'manrope'),
          ),
          
          IconButton(
                icon: Icon(Icons.help_rounded, color: Colors.blue,),
                onPressed: _showTutorial, // Trigger the tutorial
              ),
        ],
      ),
      const SizedBox(height: 5),
      InkWell(
         key: _dueDateKey,
          onTap: () => _selectDueDate(context),
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 230, // Set the desired width here
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: _themeController.isDarkMode.value? Colors.white:Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _themeController.isDarkMode.value
                              ? Colors.white
                              : const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center, // Aligns text centrally
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
                          child: Text(
                            widget.selectedDueDate != null
                                ? DateFormat('MMMM dd, yyyy').format(widget.selectedDueDate!)
                                : 'Tap to Select Due Date',
                            style: TextStyle(
                              color: _themeController.isDarkMode.value
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.all(10.0), // Add padding to the container
        decoration: BoxDecoration(
          border: Border.all(width: 0.6),
          color: _themeController.isDarkMode.value
              ? const Color.fromARGB(185, 0, 12, 20) // Dark mode background
              : const Color.fromARGB(0, 75, 148, 207), // Light mode background
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Text(
                'Rental price: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₱${widget.room?['price']?.toString() ?? 'N/A'}',
                style: TextStyle(
                  fontFamily: 'geistmono',
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  fontSize: 20, // Adjust the size as needed
                ),
              ),
            ],
          ),

            const SizedBox(height: 5),
            Row(
              
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap the months to see the photo.',
                  style: TextStyle(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 189, 189, 189)
                        : const Color.fromARGB(172, 71, 71, 71),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPaymentStatusLegend(context),
                  child: Icon(Icons.help_outline_outlined),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              key: _monthlyPaymentKey,
              child: buildMonthButtons(widget.room!, context, _currentMonthIndex)),
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
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text(
                      'No proof of payment found for ${_selectedMonth ?? 'the selected month'}.');
                } else {
                  final proofData = snapshot.data!['proofOfPayment'];
                  print("Proof of payment data: $proofData");

                  if (proofData != null && proofData.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullscreenImage(imageUrl: proofData),
                              ),
                            );
                          },
                          child: Container(
                            key: _proofOfPaymentKey,
                            height: 130,
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    proofData,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return Center(
                                          child: Text('Failed to load image'));
                                    },
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Text(
                                      '${_selectedMonth ?? 'No month selected'}',
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
                        const SizedBox(height: 10),
                        Text(
                          'Payment Status:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          key: _paymentStatus,
                          children: [
                            ShadButton(
                              backgroundColor: _themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black,
                              onPressed: () async {
                                if (_selectedMonth != null) {
                                  await handleUpdateStatus(_selectedMonth, _status);
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
                                'Update',
                                style: TextStyle(
                                  color: _themeController.isDarkMode.value
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                           Wrap(
                              spacing: 10.0,
                              runSpacing: 5.0,
                              alignment: WrapAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Complete',
                                      style: TextStyle(fontFamily: 'manrope', fontSize: 12, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    Checkbox(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      activeColor: const Color.fromARGB(255, 4, 230, 154),
                                      value: _status == 'completed',
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _status = 'completed';
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Reject',
                                      style: TextStyle(fontFamily: 'manrope', fontSize: 12, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    Checkbox(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      activeColor: const Color.fromARGB(255, 221, 6, 53),
                                      value: _status == 'rejected',
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _status = 'rejected';
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )

                          ],
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text('No proof uploaded for ${_selectedMonth}.'),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    ],
  );
}




// Function to show Cupertino Dialog with payment status
// Function to show Cupertino Dialog with all payment statuses (legend)
  void _showPaymentStatusLegend(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Payment Status Legend"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow(
                  'Completed', Colors.green), // Green dot for completed
              SizedBox(height: 8),
              _buildStatusRow(
                  'Pending', Colors.orange), // Orange dot for pending
              SizedBox(height: 8),
              _buildStatusRow('Rejected', Colors.red), // Red dot for rejected
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Helper function to build each row with status dot and label
  Widget _buildStatusRow(String status, Color dotColor) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: dotColor,
          size: 16, // Small dot size
        ),
        SizedBox(width: 8),
        Text(
          status, // Status label
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> updateDueDate(
      String roomId, DateTime dueDate, String token) async {
    final String apiUrl =
        'https://rentconnect.vercel.app/rooms/${widget.room!['_id']}/due-date';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'dueDate': dueDate.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.selectedDueDate = dueDate; // Update the due date
        });
        // Optionally refresh the proof of payment data
        proofFuture = getProofOfPaymentForSelectedMonth(
          widget.room?['_id'],
          widget.token,
          _selectedMonth,
        );
      } else {
        print('Failed to update due date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating due date: $e');
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
      // Set the time to midnight and add 1 day
      DateTime selectedDate =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day)
              .add(Duration(days: 1));

      setState(() {
        widget.selectedDueDate =
            selectedDate.toUtc(); // Convert the adjusted date to UTC

        // Log the selected date to check
        print(
            'Due Date Selected (after adding 1 day): ${widget.selectedDueDate?.toIso8601String()}');

        // Call your function to save the due date (send UTC to backend)
        updateDueDate(
            widget.room!['_id'], widget.selectedDueDate!, widget.token);
      });
    }
  }

  void _updateDueDateToNextMonth() {
    if (widget.selectedDueDate != null) {
      // Get the current selected due date
      DateTime dueDate = widget.selectedDueDate!;
      // Create a new date for the same day next month
      DateTime nextMonthDueDate =
          DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      setState(() {
        widget.selectedDueDate = nextMonthDueDate; // Update the due date
      });
    }
  }

// Future<Map<String, dynamic>?> getProofOfPaymentForSelectedMonth(
//     String roomId, String token, String selectedMonth) async {
//   final String apiUrl = 'https://rentconnect.vercel.app/payment/room/$roomId/monthlyPayments';

//   try {
//     print('API URL: $apiUrl');

//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
//         final List<dynamic> monthlyPayments = data['monthlyPayments'];

//         // Find the payment for the selected month
//         final paymentForMonth = monthlyPayments.firstWhere(
//           (payment) => payment['month'] == selectedMonth,
//           orElse: () => null, // If no payment is found for that month
//         );

//         if (paymentForMonth != null) {
//           final proofOfPayment = paymentForMonth['proofOfPayment'];
//           final paymentStatus = paymentForMonth['status']; // Get the status
//           final monthlyPaymentId = paymentForMonth['_id']; // Get the monthlyPaymentId
//           return {
//             'proofOfPayment': proofOfPayment,
//             'paymentStatus': paymentStatus, // Include the status
//             'monthlyPaymentId': monthlyPaymentId,
//           };
//         }
//       }
//     }
//   } catch (e) {
//     print('Error fetching proof of payment: $e');
//   }
//   return null;
// }

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
