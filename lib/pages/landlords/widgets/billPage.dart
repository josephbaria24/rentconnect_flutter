// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Correct import
import 'dart:convert';
import 'dart:typed_data';

class ViewBillPage extends StatefulWidget {
  final String billId;
  final String userID;
  final String token;

  ViewBillPage({required this.billId, required this.userID, required this.token});

  @override
  _ViewBillPageState createState() => _ViewBillPageState();
}

class _ViewBillPageState extends State<ViewBillPage> with TickerProviderStateMixin{
  final ThemeController _themeController = Get.find<ThemeController>();
  Map<String, dynamic>? bill;
    late ToastNotification toastNotification;


  bool isSending = false;
  bool isSent = false;

  // Lottie controller to control the animation speed
  late AnimationController _animationController;


  bool isLoading = true;
  String? errorMessage;
  GlobalKey _billKey = GlobalKey(); // Key for capturing the bill widget

  @override
  void initState() {
    super.initState();
    fetchBillDetails(widget.billId);
    toastNotification = ToastNotification(context);
    _fetchUserProfile();
     _animationController = AnimationController(vsync: this);
  }


Map<String, dynamic>? userDetails;

Future<void> _fetchUserProfile() async {
  // Ensure userId is converted to String if necessary
  final url = Uri.parse('https://rentconnect.vercel.app/user/${widget.userID}'); // Adjust the endpoint if needed
  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userDetails = data; // Properly decode the response
      });
    } else {
      print('No profile yet');
    }
  } catch (error) {
    print('Error fetching profile data: $error');
  }
}

Future<bool> canSendEmail() async {
  final uri = Uri(scheme: 'mailto', path: 'test@example.com');
  return await canLaunchUrl(uri);
}


  Future<void> sendBillViaBackend() async {
    

    try {
      setState(() {
      isSending = true;
      isSent = false;
    });
      // Capture the bill image as Uint8List
      final imageBytes = await _captureBillImage();

      // Send the file as multipart form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/inquiries/send-bill'),
      );

      // Add form fields (e.g., email, billId)
      request.fields['email'] = userDetails?['email'] ?? '';
      request.fields['billId'] = widget.billId.toString();

      // Add the captured image as a part of the form data
      var billFile = http.MultipartFile.fromBytes(
        'billFile', // Field name in the backend
        imageBytes,
        filename: 'bill_${widget.billId}.png', // You can customize the file name
        contentType: MediaType('image', 'png'), // Set content type (correct use of MediaType)
      );
      request.files.add(billFile);

      // Send the request
      var response = await request.send();
      if (response.statusCode == 200) {
        toastNotification.success('Bill sent successfully');
        print('Bill sent successfully');
      } else {
        toastNotification.warn('Failed to send bill');
        print('Failed to send bill: ${response.statusCode}');
      }
    } catch (e) {
      toastNotification.error('Error sending bill');
      print('Error sending bill: $e');
    }

    setState(() {
      isSending = false;
      isSent = true;
    });

    _animationController.stop(); // Finish the animation when done
  }



    @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


Future<Uint8List> _captureBillImage() async {
  RenderRepaintBoundary boundary = _billKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

  Future<void> fetchBillDetails(String billId) async {
    try {
      final response = await http.get(
        Uri.parse('https://rentconnect.vercel.app/inquiries/bills/getBillId/${widget.billId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          bill = json.decode(response.body);
          isLoading = false;
        });
        print(bill);
      } else {
        setState(() {
          errorMessage = 'Failed to load bill details (Error ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while fetching bill details: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://rentconnect.vercel.app/inquiries/bill/delete/$billId'),
      );

      if (response.statusCode == 200) {
        toastNotification.success('Bill deleted successfully');
        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        toastNotification.warn('Failed to delete bill');
      }
    } catch (e) {
      toastNotification.error('An error occurred while deleting the bill');
    }
  }







Future<void> saveBillAsImage() async {
  try {


    RenderRepaintBoundary boundary = _billKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Use SaverGallery to save the image directly
    String imageName = 'bill_${widget.billId}.png';
    final result = await SaverGallery.saveImage(
      pngBytes,
      quality: 100, // Set quality to 100 for best quality
      name: imageName,
      androidRelativePath: 'Pictures/YourAppName/images', // Change 'YourAppName' to your actual app name
      androidExistNotSave: false,
    );

    // Handle the result
    if (result.isSuccess) {
      toastNotification.success('Bill saved as image successfully!');
    } else {
      toastNotification.warn('Failed to save image to gallery.');
    }
  } catch (e) {
   toastNotification.error('An error occurred while saving the bill as an image');
  }
}


// Within your ViewBillPage class

Future<void> markBillAsPaid(String billId) async {
  try {
    final response = await http.patch(
      Uri.parse('https://rentconnect.vercel.app/inquiries/bills/$billId/isPaid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isPaid': true}),
    );

    if (response.statusCode == 200) {
      setState(() {
        bill?['isPaid'] = true;
      });
      toastNotification.success('Bill marked as paid successfully');
    } else {
      toastNotification.warn('Failed to mark bill as paid');
    }
  } catch (e) {
    toastNotification.error('An error occurred');
  }
}

  @override
Widget build(BuildContext context) {
  print(bill);
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'View bills',
        style: TextStyle(
          fontFamily: 'manrope',
          fontWeight: FontWeight.w600,
          color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      actions: [
        if (!(bill?['isPaid'] ?? false))
          Text('Mark as paid'), // Show if not already paid
        IconButton(
          icon: Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => markBillAsPaid(widget.billId),
          tooltip: 'Mark as Paid',
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
        child: SizedBox(
          height: 40,
          width: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                width: 0.90,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
              padding: EdgeInsets.all(0),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left,
              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
              size: 16,
            ),
          ),
        ),
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : Stack(
                children: [
                  // Base content (bill details)
                  buildBillDetails(),

                  // Centered Lottie animation
                  if (isSending) 
                    Positioned.fill(
                      child: Center(
                        child: Lottie.asset(
                          'assets/icons/sent3.json', // Path to your Lottie animation
                          controller: _animationController,
                          onLoaded: (composition) {
                            _animationController
                              ..duration = composition.duration
                              ..forward();
                          },
                        ),
                      ),
                    ),
                ],
              ),
  );
}



Widget buildBillDetails() {
  if (bill == null) {
    return Center(child: Text('No bill details available.'));
  }

  // Extract bill data from response
  final electricityAmount = bill?['electricity']?['amount'] ?? 0;
  final waterAmount = bill?['water']?['amount'] ?? 0;
  final maintenanceAmount = bill?['maintenance']?['amount'] ?? 0;
  final internetAmount = bill?['internet']?['amount'] ?? 0;
  final dueDate = bill?['dueDate'] ?? 'N/A';
  final dateOfCreation = bill?['created_at'] ?? 'N/A';
  final bill_id = bill?['_id'] ?? 'N/A';
  final paymentMethod = bill?['paymentMethod']?['details'] ?? 'N/A';
  final paymentMethodType = bill?['paymentMethod']?['type'] ?? 'N/A';
  // If dueDate is a valid date, format it, otherwise keep 'N/A'
  String formattedDueDate = 'N/A';
  if (dueDate != 'N/A') {
    final DateTime parsedDate = DateTime.parse(dueDate);
    formattedDueDate = DateFormat('MMMM d, yyyy').format(parsedDate);
  }
  String formattedCreationDate = 'N/A';
  if (dateOfCreation != 'N/A') {
    final DateTime parsedDate = DateTime.parse(dateOfCreation);
    formattedCreationDate = DateFormat('MMMM d, yyyy').format(parsedDate);
  }
  
  // Calculate the total amount
  final totalAmount = electricityAmount + waterAmount + maintenanceAmount + internetAmount;

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column( // Change from RepaintBoundary to Column
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RepaintBoundary( // Wrap only bill details in RepaintBoundary
              key: _billKey, // Assign key
              child: Container(
                padding: EdgeInsets.all(16),
                width: 350,
                decoration: BoxDecoration(
                  color: _themeController.isDarkMode.value? const Color.fromARGB(255, 28, 29, 34): Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 30,
                              child: Image.asset(_themeController.isDarkMode.value?'assets/icons/ren2.png':'assets/icons/ren.png')),
                              Text('RentConnect', style: TextStyle(color: _themeController.isDarkMode.value? Colors.white:Colors.black, fontFamily: 'manrope', fontSize: 15, fontWeight: FontWeight.w600),),
                          ],
                        ),
                          
                        if (bill?['isPaid'] ?? false) // Display 'PAID' if isPaid is true
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              'PAID',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        else // Display 'UNPAID' if isPaid is false or null
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              'UNPAID',
                              style: TextStyle(
                                color: Colors.red, // Color for unpaid status
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Billing Statement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        fontFamily: 'manrope',
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Bill Details:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'manrope',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    buildReceiptRow('Created at:', formattedCreationDate),
                    buildReceiptRow('Due Date:', formattedDueDate),
                    Divider(thickness: 2),
                    buildReceiptRow('Electricity:', '₱${electricityAmount.toString()}'),
                    buildReceiptRow('Water:', '₱${waterAmount.toString()}'),
                    buildReceiptRow('Maintenance:', '₱${maintenanceAmount.toString()}'),
                    buildReceiptRow('Internet:', '₱${internetAmount.toString()}'),
                    Divider(thickness: 2),
                    buildReceiptRow('Total:', '₱${totalAmount.toString()}'),
                    SizedBox(height: 10),
                    Text('Payment Method: $paymentMethodType',style: TextStyle( fontSize: 14), overflow: TextOverflow.ellipsis,),
                    Text(
                      '$paymentMethod',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      softWrap: true, // Allow text to wrap to the next line
                    ),
                    SizedBox(height: 20),
                    Text('Bill ID: ${bill_id.toString()}', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
                    SizedBox(height: 20),
                    Text(
                      'Thank you!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'manrope',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: saveBillAsImage, // Call save function
                  child: Row(
                    children: [
                      Icon(Icons.download_rounded, color: _themeController.isDarkMode.value? Colors.white:Colors.black, size: 20),
                      SizedBox(width: 3),
                      Text('Download', style: TextStyle(color:_themeController.isDarkMode.value? Colors.white:Colors.black)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255), // Button color for saving
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isSending ? null : () async {
                    await sendBillViaBackend();
                  },
                  icon: isSending
                      ? SizedBox.shrink() // No icon if sending
                      : Icon(Icons.email), // Default icon when not sending
                  label: Text(isSending ? 'Sending Bill...' : 'Send Bill via Email'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    backgroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                deleteBill(widget.billId); // Call the delete function
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.trash, color: Colors.white, size: 18),
                  SizedBox(width: 3),
                  Text('Delete Bill', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: const Color.fromARGB(255, 226, 31, 74), // Button color
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'manrope', // Font family applied
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'manrope', // Font family applied
            ),
          ),
        ],
      ),
    );
  }
}
