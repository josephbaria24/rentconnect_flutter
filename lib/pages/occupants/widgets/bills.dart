import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';

import 'package:rentcon/theme_controller.dart';

class AllBillsWidget extends StatefulWidget {
  final String userId;

  const AllBillsWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _AllBillsWidgetState createState() => _AllBillsWidgetState();
}

class _AllBillsWidgetState extends State<AllBillsWidget> {
  List<dynamic> roomBills = [];
  List<dynamic> filteredBills = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedMonth = '';
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
    selectedMonth = DateFormat.MMM().format(DateTime.now());
  }

 
Future<void> _fetchInquiries() async {
  final url = 'https://rentconnect-backend-nodejs.onrender.com/inquiries/occupant/${widget.userId}';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final inquiries = json.decode(response.body);
      if (inquiries.isNotEmpty) {
        setState(() {
          roomBills = inquiries[0]['roomBills'] ?? [];
          isLoading = false;
          filteredBills = roomBills.where((bill) {
            final dueDate = bill['dueDate']?.toString();
            return getShortMonthName(dueDate) == selectedMonth;
          }).toList();
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No inquiries found.';
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load inquiries. Status code: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Error: $e';
    });
  }
}
  String formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat.yMMMMd().format(DateTime.parse(date));
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String getShortMonthName(String? date) {
    if (date == null) return 'N/A';
    try {
      final month = DateTime.parse(date).month;
      return DateFormat.MMM().format(DateTime(0, month)); // Short month name
    } catch (e) {
      return 'Invalid Month';
    }
  }

  void _filterBillsByMonth(String month) {
    setState(() {
      selectedMonth = month;
      filteredBills = roomBills.where((bill) {
        final dueDate = bill['dueDate']?.toString();
        return getShortMonthName(dueDate) == month;
      }).toList();
    });
  }

  String getMonthName(String? date) {
    if (date == null) return 'N/A';
    try {
      final month = DateTime.parse(date).month;
      return DateFormat.MMMM().format(DateTime(0, month)); // Full month name
    } catch (e) {
      return 'Invalid Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (roomBills.isEmpty) {
      return Scaffold(
        appBar: AppBar(
        title: Text('All Bills', style: TextStyle(
          fontFamily: 'manrope',
          fontSize: 20,
          fontWeight: FontWeight.w500
        ),),
        backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 15, 16, 22): Colors.white,
        leading: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 11.0, horizontal: 11.0),
            child: SizedBox(
              height: 40, // Set a specific height for the button
              width: 40, // Set a specific width to make it a square button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // Transparent background to simulate outline
                  side: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black, // Outline color
                    width: 0.90, // Outline width
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Optional rounded corners
                  ),
                  elevation: 0, // Remove elevation to get the outline effect
                  padding: EdgeInsets.all(
                      0), // Remove any padding to center the icon
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Icon(
                    Icons.chevron_left,
                    weight: 20,
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black, // Icon color based on theme
                    size: 20, // Icon size
                  ),
                ),
              ),
            ),
          ),
      ),
        body:
            Container(
            color: _themeController.isDarkMode.value? const Color.fromARGB(255, 15, 16, 22): Colors.white,
            child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/icons/empty.json', height: 200, repeat: false),
                Text('No bills available.', style: TextStyle(fontFamily: 'manrope', fontSize: 18,color: _themeController.isDarkMode.value? Colors.white:Colors.black),),
              ],
            ))),
      );
    }

    // Get unique months from room bills
    final uniqueMonths = roomBills.map((bill) {
      return getShortMonthName(bill['dueDate']?.toString());
    }).toSet().toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bills', style: TextStyle(
          fontFamily: 'manrope',
          fontSize: 20,
          fontWeight: FontWeight.w500
        ),),
        backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 15, 16, 22): Colors.white,
        leading: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 11.0, horizontal: 11.0),
            child: SizedBox(
              height: 40, // Set a specific height for the button
              width: 40, // Set a specific width to make it a square button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // Transparent background to simulate outline
                  side: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black, // Outline color
                    width: 0.90, // Outline width
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Optional rounded corners
                  ),
                  elevation: 0, // Remove elevation to get the outline effect
                  padding: EdgeInsets.all(
                      0), // Remove any padding to center the icon
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Icon(
                    Icons.chevron_left,
                    weight: 20,
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black, // Icon color based on theme
                    size: 20, // Icon size
                  ),
                ),
              ),
            ),
          ),
      ),
      body: Container(
        color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 15, 16, 22) : Colors.white,
        child: Row(
          children: [
            // Column of months on the left side
            Padding(
              padding: const EdgeInsets.only(right: 3.0, left: 6, top: 10, bottom: 10),
              child: Container(
                width: 70,
                child: ListView.builder(
                  itemCount: uniqueMonths.length,
                  itemBuilder: (context, index) {
                    final month = uniqueMonths[index];
                    return GestureDetector(
                      onTap: () => _filterBillsByMonth(month),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300), // Animation duration
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedMonth == month ? const Color.fromARGB(255, 42, 53, 63) : const Color.fromARGB(255, 218, 218, 218),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: selectedMonth == month
                              ? [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1)]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            month,
                            style: TextStyle(
                              fontFamily: 'manrope',
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              color: selectedMonth == month ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Bills list on the right side
            Expanded(
              child: ListView.builder(
                itemCount: filteredBills.length,
                itemBuilder: (context, index) {
                  final bill = filteredBills[index];

                  if (bill is! Map) {
                    return ListTile(title: Text('Invalid bill data'));
                  }

                  final dueDate = bill['dueDate']?.toString();
                  final createdAt = bill['created_at']?.toString();
                  final electricityAmount = bill['electricity']?['amount']?.toDouble() ?? 0;
                  final waterAmount = bill['water']?['amount']?.toDouble() ?? 0;
                  final maintenanceAmount = bill['maintenance']?['amount']?.toDouble() ?? 0;
                  final internetAmount = bill['internet']?['amount']?.toDouble() ?? 0;

                  final totalAmount = electricityAmount + waterAmount + maintenanceAmount + internetAmount;

                  return Card(
                    color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 43, 45, 51) : Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      splashColor: Colors.amber,
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Optional: Handle card tap for more details
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(getMonthName(dueDate), style: TextStyle(
                                    fontFamily: 'manrope',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                )),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: bill['isPaid'] ? Colors.green : const Color.fromARGB(255, 245, 161, 5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    bill['isPaid'] ? 'Paid' : 'Pending',
                                    style: TextStyle(color: Colors.white, fontFamily: 'geistmono', fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text('Created: ${formatDate(createdAt)}', style: TextStyle(color: Colors.grey)),
                            Text('Due Date: ${formatDate(dueDate)}', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                            _buildBillRow(Icons.electrical_services, 'Electricity: \₱${electricityAmount.toStringAsFixed(2)}', Colors.blue),
                            _buildBillRow(Icons.water, 'Water: \₱${waterAmount.toStringAsFixed(2)}', Colors.blueAccent),
                            _buildBillRow(Icons.build, 'Maintenance: \₱${maintenanceAmount.toStringAsFixed(2)}', Colors.orange),
                            _buildBillRow(Icons.wifi, 'Internet: \₱${internetAmount.toStringAsFixed(2)}', Colors.green),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 8),
                            Text('Total: \₱${totalAmount.toStringAsFixed(2)}', style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _themeController.isDarkMode.value ? Colors.white : Colors.black
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(IconData icon, String title, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
