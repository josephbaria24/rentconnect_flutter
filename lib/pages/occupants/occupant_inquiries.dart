// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/pages/components/countdown_reservation.dart';
import 'package:rentcon/pages/components/glassmorphism.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/pages/occupants/widgets/PaymentUploadWidget.dart';
import 'package:rentcon/pages/occupants/widgets/approvedButNotRented.dart';
import 'package:rentcon/pages/occupants/widgets/bills.dart';
import 'package:rentcon/pages/occupants/widgets/bodypaymentUploadWidget.dart';
import 'package:rentcon/pages/occupants/widgets/detail_room_property.dart';
import 'package:rentcon/pages/occupants/widgets/payment_details_tab.dart';
import 'package:rentcon/pages/occupants/widgets/pending.dart';
import 'package:rentcon/pages/occupants/widgets/request_details_tab.dart';
import 'package:rentcon/pages/occupants/widgets/roomMates.dart';
import 'package:rentcon/pages/occupants/widgets/room_details_tab.dart';
import 'package:rentcon/pages/occupants/widgets/selectMonthButton.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OccupantInquiries extends StatefulWidget {
  final String userId;
  final String token;

  const OccupantInquiries({Key? key, required this.userId, required this.token})
      : super(key: key);

  @override
  State<OccupantInquiries> createState() => _OccupantInquiriesState();
}

class _OccupantInquiriesState extends State<OccupantInquiries> {
  late String userId;
  late String email;
  String requestStatus = 'Pending';
  final ThemeController _themeController = Get.find<ThemeController>();
  final TextEditingController amountController = TextEditingController();
 late ToastNotification toastNotification;
  String? landlordId;
  
  Map<String, dynamic>? propertyRoomDetails;
  List<Map<String, dynamic>> inquiries = [];
  bool isLoading = true;


  


  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final Map<String, String?> selectedMonths = {};

Map<String, dynamic>? roomDetails;
String? inquiryId;

@override
void initState() {
  super.initState();
  initializeDetails();
  _initializeInquiries();
}

Future<void> initializeDetails() async {
  toastNotification = ToastNotification(context);
  final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
  email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
  userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown ID';

  await loadPropertyDetails(userId, widget.token);
  
  // Ensure propertyRoomDetails is populated before fetching landlord ID
  if (propertyRoomDetails != null && propertyRoomDetails!['_id'] != null) {
    _fetchLandlordId(propertyRoomDetails!['_id']);
  } else {
    print('Property details not found');
  }
}

Future<void> _initializeInquiries() async {
  try {
    final fetchedInquiries = await fetchInquiries(widget.userId, widget.token);
    
    setState(() {
      inquiries = fetchedInquiries;
      if (inquiries.isNotEmpty) {
        // Initialize roomDetails and inquiryId with the first inquiry's details
        inquiryId = inquiries[0]['_id'];
        roomDetails = inquiries[0]['roomId'];
      }
      isLoading = false;
    });

    print('Inquiries: $inquiries'); // Print to confirm data retrieval
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error loading inquiries: $e');
  }
}


    
 Future<List<Map<String, dynamic>>> fetchInquiries(
      String userId, String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.8:3000/inquiries/occupant/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((inquiry) => inquiry as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load inquiries');
    }
  }

  Future<void> fetchPropertyDetails(String roomId) async {
    final url = 'http://192.168.1.8:3000/inquiries/room/$roomId/property';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Assuming the API returns a JSON response
        final details = jsonDecode(response.body);
        setState(() {
          propertyRoomDetails = details; // Update state with fetched details
        });
      } else {
        throw Exception('Failed to load property details');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> loadPropertyDetails(String userId, String token) async {
    try {
      // Fetch inquiries for the user
      List<Map<String, dynamic>> inquiries =
          await fetchInquiries(userId, token);

      if (inquiries.isNotEmpty) {
        // Assuming you want to get the roomId from the first inquiry
        String roomId = inquiries[0]['roomId']
            ['_id']; // Adjust based on your response structure
        await fetchPropertyDetails(
            roomId); // Fetch property details using the roomId
      } else {
        print('No inquiries found for user: $userId');
      }
    } catch (error) {
      print('Error loading property details: $error');
    }
  }

Future<void> _uploadProofOfReservation(
    String inquiryId, String occupantId, String roomId, String landlordId, String landlordEmail, String occupantName) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (landlordId == null) {
    Fluttertoast.showToast(
      msg: 'Landlord ID is required.',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return;
  }

  if (image != null) {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.8:3000/payment/uploadProofOfReservation'),
    );

    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.fields['inquiryId'] = inquiryId;
    request.fields['occupantId'] = occupantId;
    request.fields['roomId'] = roomId;
    request.fields['landlordId'] = landlordId;
    request.fields['landlordEmail'] = landlordEmail;
    request.fields['occupantName'] = occupantName;

    final fileStream = http.ByteStream(Stream.castFrom(image.openRead()));
    final length = await image.length();

    String contentType = 'application/octet-stream';
    if (image.name.endsWith('.jpg') || image.name.endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (image.name.endsWith('.png')) {
      contentType = 'image/png';
    } else if (image.name.endsWith('.gif')) {
      contentType = 'image/gif';
    }

    request.files.add(
      http.MultipartFile(
        'proofOfReservation',
        fileStream,
        length,
        filename: image.name,
        contentType: MediaType.parse(contentType),
      ),
    );

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        Get.snackbar(
          '',
          '',
          duration: Duration(milliseconds: 1500),
          titleText: Text(
            'Success',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          messageText: Text(
            'Proof of reservation uploaded and email sent successfully!',
          ),
        );

        // Notification payload - extract relevant details from inquiries
        final selectedInquiry = inquiries.firstWhere(
          (inquiry) => inquiry['_id'] == inquiryId,
          orElse: () => {},
        );

        if (selectedInquiry.isNotEmpty) {
          final roomDetails = selectedInquiry['roomId'];
          final notificationBody = {
            'userId': roomDetails['ownerId'],
            'message': 'Your room ${roomDetails['roomNumber']} reservant has uploaded proof of reservation photo',
            'roomId': roomDetails['_id'],
            'roomNumber': roomDetails['roomNumber'],
            'requesterEmail': landlordEmail,
            'inquiryId': inquiryId,
          };

          // Send notification request
          final notificationResponse = await http.post(
            Uri.parse('http://192.168.1.8:3000/notification/create'),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(notificationBody),
          );

          final notificationResponseData = jsonDecode(notificationResponse.body);

          if (notificationResponse.statusCode == 200 && notificationResponseData['status'] == true) {
            print('Notification sent successfully.');
          } else {
            print('Failed to send notification: ${notificationResponse.body}');
          }
        } else {
          print('Inquiry not found for notification.');
        }

        setState(() {});
      } else {
        toastNotification.error('Failed to upload proof of reservation: ${responseData.body}');
      }
    } catch (e) {
      toastNotification.error('Error uploading proof of reservation: $e');
    }
  } else {
    Get.snackbar(
      '',
      '',
      duration: Duration(milliseconds: 1500),
      titleText: Text(
        'Warning',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        'No image selected.',
      ),
    );
  }
}


  Future<String?> getProofOfReservation(String roomId, String token) async {
    final url =
        'http://192.168.1.8:3000/payment/room/$roomId/proofOfReservation';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the authorization token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming the proof of reservation URL is in data['proofOfReservation']
        return data[
            'proofOfReservation']; // Adjust based on the actual API response structure
      } else {
        print('Failed to load proof of reservation: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching proof of reservation: $e');
      return null;
    }
  }

  Future<void> _getLandlordId(String roomId) async {
    final uri = Uri.parse('http://192.168.1.8:3000/rooms/getRoom/$roomId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final roomDetails = jsonDecode(response.body);

      // Check if roomDetails contain the propertyId
      if (roomDetails != null && roomDetails['room'] != null) {
        String propertyId = roomDetails['room']['propertyId'];

        // Fetch landlordId using propertyId
        await _fetchLandlordId(propertyId);
      print(propertyId);
      } else {
        Fluttertoast.showToast(
          msg: 'Room details are not available.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg:
            'Failed to fetch room details. Status code: ${response.statusCode}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

void printPropertyId(Map<String, dynamic> propertyDetail) {
  // Retrieve the property ID
  String propertyId = propertyDetail['_id'];

  // Print the property ID to confirm
  print('Property ID: $propertyId');
}


Future<void> _fetchLandlordId(String propertyId) async {
  final uri = Uri.parse('http://192.168.1.8:3000/getPropertiesByIds?ids=${propertyRoomDetails!['_id']}');

  final response = await http.get(
    uri,
    headers: {'Content-Type': 'application/json'},
  );

  // Print the entire response body to inspect its structure
  print('Response Body _fetchlandlordId: ${response.body}');

  if (response.statusCode == 200) {
    final propertyDetails = jsonDecode(response.body);

    // Check if propertyDetails has the expected structure
    if (propertyDetails['status'] == true &&
        propertyDetails['properties'] != null &&
        propertyDetails['properties'].isNotEmpty) {
      
      setState(() {
        // Access the first property in the 'properties' list and get the 'userId'
        landlordId = propertyDetails['properties'][0]['userId'];
      });
      
      print('Landlord ID: $landlordId'); // Print to confirm retrieval
    } else {
      Fluttertoast.showToast(
        msg: 'No properties found or status is false.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } else {
    Fluttertoast.showToast(
      msg: 'Failed to fetch property details. Status code: ${response.statusCode}',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  Future<String?> getProofOfPayment(String roomId, String token) async {
    final String apiUrl =
        'http://192.168.1.8:3000/room/$roomId/monthlyPayments'; // Update with your API endpoint

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Check if the monthly payments exist and extract the proof of payment from the latest payment
        if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
          final List<dynamic> monthlyPayments = data['monthlyPayments'];
          // Get the most recent proof of payment
          final proofOfPayment =
              monthlyPayments.last['proofOfPayment'] as String?;
          return proofOfPayment; // Return the proof of payment URL
        } else {
          return null; // No payments found
        }
      } else {
        throw Exception(
            'Failed to fetch proof of payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching proof of payment: $e');
      return null; // Return null if there's an error
    }
  }

  Future<void> _deletePhoto(String proofOfReservation) async {
    // Assuming you have access to roomId and month in your state.
    String roomId = ''; // Get the roomId from your state or widget.
    String month = 'null'; // Get the month from your state or widget.
    String type = 'reservation'; // You can use proofOfReservation as the type.

    await deleteProof(roomId, type);

    // Optionally, refresh the UI or handle state after deletion
    setState(() {
      // Update your state to reflect the deletion
    });
  }

  Future<void> deleteProof(String roomId, String type) async {
    final url =
        'http://192.168.1.8:3000/payment/room/$roomId/payment/month/proof/reservation';

    print('Attempting to delete: $url'); // Print the URL for debugging

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print('Proof of $type deleted successfully');
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to delete proof. Status code: ${response.statusCode}');
        print(
            'Response body: ${response.body}'); // Print response body for more info
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

Future<String?> fetchLandlordEmail(String ownerId, String token) async {
  final url = Uri.parse('http://192.168.1.8:3000/user/$ownerId');
  try {
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['email']; // Adjust according to your response structure
    } else {
      print('Failed to fetch landlord email: ${response.body}');
      return null;
    }
  } catch (error) {
    print('Error fetching landlord email: $error');
    return null;
  }
}



Future<void> uploadProofOfPayment(
  String inquiryId,
  String userId,
  String roomId,
  String month,
  String landlordId,
  String token,
  double amount, // New argument to pass the amount
) async {
  try {
    // Pick the image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String? fileExtension = image.name.split('.').last.toLowerCase();
      print('Selected file extension: $fileExtension');

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        Fluttertoast.showToast(
          msg: 'Invalid file type. Please upload a JPG or PNG image.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final bytes = await image.readAsBytes();

      // Creating the multipart request
      final paymentRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.8:3000/payment/createoraddMonthlyPayment'),
      );

      // Adding headers
      paymentRequest.headers['Authorization'] = 'Bearer $token';

      // Adding fields
      paymentRequest.fields['occupantId'] = userId;
      paymentRequest.fields['landlordId'] = landlordId;
      paymentRequest.fields['roomId'] = roomId;

      // Ensure correct form-data format for monthlyPayments as an array
      paymentRequest.fields['monthlyPayments[0][amount]'] = amount.toString(); // Pass amount dynamically
      paymentRequest.fields['monthlyPayments[0][month]'] = month; // Month for payment
      paymentRequest.fields['monthlyPayments[0][status]'] = 'pending';

      // Attach the image file for proofOfPayment
      paymentRequest.files.add(http.MultipartFile.fromBytes(
        'proofOfPayment',
        bytes,
        filename: image.name,
        contentType: MediaType('image', fileExtension!),
      ));

      print('Payment Request Fields: ${paymentRequest.fields}');
      print('Payment Request Headers: ${paymentRequest.headers}');

      // Send the request
      final paymentResponse = await paymentRequest.send();

      if (paymentResponse.statusCode == 200) {
        // Handle success
        Fluttertoast.showToast(
          msg: 'Monthly payment created/added successfully.',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Fetch the landlord's email using the ownerId
        final landlordEmail = await fetchLandlordEmail(landlordId, token);

        // Notification payload - extract relevant details from inquiries
        final selectedInquiry = inquiries.firstWhere(
          (inquiry) => inquiry['_id'] == inquiryId,
          orElse: () => {},
        );

        if (selectedInquiry.isNotEmpty) {
          final roomDetails = selectedInquiry['roomId'];
          final notificationBody = {
            'userId': roomDetails['ownerId'],
            'message': 'Your room ${roomDetails['roomNumber']} occupant has uploaded proof of payment photo',
            'roomId': roomDetails['_id'],
            'roomNumber': roomDetails['roomNumber'],
            'requesterEmail': landlordEmail,
            'inquiryId': inquiryId,
          };

          // Send notification request
          final notificationResponse = await http.post(
            Uri.parse('http://192.168.1.8:3000/notification/create'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(notificationBody),
          );

          final notificationResponseData = jsonDecode(notificationResponse.body);

          if (notificationResponse.statusCode == 200 && notificationResponseData['status'] == true) {
            print('Notification sent successfully.');
          } else {
            print('Failed to send notification: ${notificationResponse.body}');
          }
        } else {
          print('Inquiry not found for notification.');
        }
      } else {
        print('Failed to create or add monthly payment. Status code: ${paymentResponse.statusCode}');
        Fluttertoast.showToast(
          msg: 'Failed to create or add monthly payment.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      print('No image selected.');
    }
  } catch (e) {
    print('Error occurred while uploading proof of payment: $e');
  }
}

  bool _isImageVisible = false;
  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible; // Toggle visibility
    });
  }

  Future<void> _cancelInquiry(String inquiryId, String token) async {
    final String apiUrl =
        'http://192.168.1.8:3000/inquiries/delete/$inquiryId';
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Inquiry deleted successfully');
        // You can update the UI or show a success message
        setState(() {});
      } else {
        print('Failed to delete inquiry: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting inquiry: $e');
    }
  }



 
  @override
  Widget build(BuildContext context) {
    print("inquiries: ${inquiries}");
    //print('Property detail: ${propertyRoomDetails!['userId']}');
    //print('landlordId: $landlordId');
    return Obx(() {
      final isDarkMode = _themeController.isDarkMode.value;
      return Scaffold(
        backgroundColor: _themeController.isDarkMode.value
            ? Color.fromARGB(255, 28, 29, 34)
            : Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: _themeController.isDarkMode.value
              ? Color.fromARGB(255, 28, 29, 34)
              : Colors.white,
          title: const Text(
            'My Home & Inquiries',
            style: TextStyle(
              fontFamily: 'GeistSans',
              fontWeight: FontWeight.bold,
            ),
          ),
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
        body: Padding(
          
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchInquiries(widget.userId, widget.token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final inquiries = snapshot.data!;

                      if (inquiries.isEmpty) {
                        return const Center(child: Text('No inquiries found.'));
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: inquiries.length,
                        itemBuilder: (context, index) {
                          final inquiry = inquiries[index];
                          final roomDetails = inquiry['roomId'];
                          final inquiryId = inquiry['_id'];

                          if (roomDetails == null) {
                            return const Center(
                                child: Text('Invalid room information.'));
                          }

                          final String? roomPhotoUrl = roomDetails?['photo1'] ??
                              roomDetails?['photo2'] ??
                              roomDetails?['photo3'];
                          final String defaultPhoto =
                              'https://via.placeholder.com/150';

                          // Initialize selected month for this inquiry if not already done
                          if (!selectedMonths.containsKey(inquiryId)) {
                            selectedMonths[inquiryId!] = null; // Default to null
                          }

                          // FutureBuilder to get proof of reservation photo
                          return FutureBuilder<String?>(
                            future: getProofOfReservation(
                                roomDetails?['_id'], widget.token),
                            builder: (context, proofSnapshot) {
                              final String? proofOfReservation =
                                  proofSnapshot.data ?? '';

                              return Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _themeController
                                                        .isDarkMode.value
                                                    ? const Color.fromARGB(
                                                        255, 36, 38, 43)
                                                    : const Color.fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255), // Background color
                                                foregroundColor: Colors
                                                    .white, // Text (foreground) color
                                                shadowColor: Colors
                                                    .black, // Shadow color
                                                elevation:
                                                    0, // Elevation for shadow
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical:
                                                        10), // Button padding
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Rounded corners
                                                ),
                                              ),
                                              onPressed:
                                                  _toggleImageVisibility, // Button to toggle image visibility
                                              child: Row(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Adjust size based on content
                                                children: [
                                                  Icon(
                                                    _isImageVisible
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: _themeController
                                                            .isDarkMode.value
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          8), // Add some space between the icon and the text
                                                  Text(
                                                    _isImageVisible
                                                        ? 'Hide Image'
                                                        : 'Show Room Image',
                                                    style: TextStyle(
                                                      color: _themeController
                                                              .isDarkMode
                                                              .value
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_isImageVisible) // Conditionally show the image
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FullscreenImage(
                                                  imageUrl: roomPhotoUrl,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: roomPhotoUrl!,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: _themeController
                                                              .isDarkMode
                                                              .value
                                                          ? Colors.white
                                                          : Colors.black)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    roomPhotoUrl ??
                                                        defaultPhoto,
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons.error,
                                                          color: Color.fromARGB(
                                                              255, 190, 5, 51));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 16),
                                      
                                      Row(
                                        
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (propertyRoomDetails != null) {
                                                    final coordinates = propertyRoomDetails!['location']['coordinates'];
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PropertyDetailsWidget(
                                                          location:
                                                              '${propertyRoomDetails!['street']}, ${propertyRoomDetails!['barangay']}, ${propertyRoomDetails!['city']}',
                                                          amenities: jsonDecode(propertyRoomDetails!['amenities'][0]),
                                                          description: propertyRoomDetails!['description'],
                                                          coordinates: coordinates.cast<double>(),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: _themeController.isDarkMode.value?Colors.white: const Color.fromARGB(255, 0, 15, 22),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Room: ${roomDetails?['roomNumber']}',
                                                              style: TextStyle(
                                                                fontFamily: 'GeistSans',
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.w700,
                                                                color: _themeController.isDarkMode.value
                                                                    ? Colors.black
                                                                    : Colors.white,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Status: ${inquiry['status']}\nPrice: ₱${roomDetails?['price']}',
                                                              style: TextStyle(
                                                                fontFamily: 'Roboto',
                                                                color: _themeController.isDarkMode.value
                                                                    ? Colors.black
                                                                    : const Color.fromARGB(255, 255, 255, 255),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color:_themeController.isDarkMode.value? Colors.black: const Color.fromARGB(255, 255, 255, 255),
                                                            borderRadius: BorderRadius.circular(100),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(2.0),
                                                            child: Icon(
                                                              CupertinoIcons.chevron_forward,
                                                              size: 20,
                                                              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(width: 5,),
                                            if (inquiry['requestType'] == 'reservation' &&
                                                inquiry['status'] == 'approved' &&
                                                inquiry['isRented'] == false) ...[
                                              RemainingTimeWidget(
                                                approvalDate: DateTime.parse(inquiry['approvalDate']),
                                                reservationDuration: inquiry['reservationDuration'],
                                              ),
                                            ],
                                            
                                            if (inquiry['status'] == 'approved' &&
                                              inquiry['requestType'] ==
                                                  'reservation' &&
                                              inquiry['isRented'] == true) ...[
                                                InkWell(
                                                  splashColor: Colors.amberAccent,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AllBillsWidget(userId: widget.userId)));
                                                    },
                                                    child: Container(
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.electric_bolt_outlined, color: Colors.amber, size: 29,),
                                                            Text(
                                                              'Bills', style: TextStyle(
                                                                fontFamily: 'geistsans',
                                                                fontWeight: FontWeight.w700,
                                                                color: _themeController.isDarkMode.value? Colors.black:Colors.white
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      height: 85,
                                                      width: 85,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        color: _themeController.isDarkMode.value? Colors.white: Colors.black
                                                      ),
                                                          )
                                              ),
                                                )]
                                          ],
                                        ),
              
                                      if (inquiry['status'] == 'pending' &&
                                          inquiry['requestType'] ==
                                              'reservation' &&
                                          inquiry['isRented'] == false) ...[
                                        Pending(inquiry: inquiry, token: widget.token, cancelInquiry: _cancelInquiry, isDarkMode: isDarkMode)
                                      ],
                                      if (inquiry['status'] == 'pending' &&
                                          inquiry['requestType'] ==
                                              'rent' &&
                                          inquiry['isRented'] == false) ...[
                                        Pending(inquiry: inquiry, token: widget.token, cancelInquiry: _cancelInquiry, isDarkMode: isDarkMode)
                                      ],
                                      if (inquiry['status'] == 'approved' &&
                                          inquiry['requestType'] ==
                                              'rent' &&
                                          inquiry['isRented'] == true) ...[
                                       
                                      //  Bodypaymentuploadwidget(
                                      //       inquiryId: inquiryId,
                                      //       userId: userId,
                                      //       roomDetails: roomDetails,
                                      //       token: widget.token,
                                      //       selectedMonths: selectedMonths,
                                      //       uploadProofOfPayment:
                                      //           uploadProofOfPayment,
                                      //       isDarkMode: isDarkMode,
                                      //       amountController:
                                      //           amountController)
                                      ],
                                
                                      if (inquiry['status'] == 'approved' &&
                                          inquiry['requestType'] ==
                                              'reservation' &&
                                          inquiry['isRented'] == false) ...[
                                        Approvedbutnotrented(inquiry: inquiry, roomDetails: roomDetails!, proofOfReservation: proofOfReservation!, userId: userId, token: widget.token, cancelInquiry: _cancelInquiry, deleteProof: deleteProof, uploadProofOfReservation: _uploadProofOfReservation, isDarkMode: isDarkMode)
                                      ],
                                      
                                      
                                      if (inquiry['status'] == 'approved' &&
                                          inquiry['requestType'] ==
                                              'reservation' &&
                                          inquiry['isRented'] == true) ...[
                                            SizedBox(height: 10,),
                                            Row(
                                            children: [
                                              Text(
                                                'Payment section',
                                                style: TextStyle(
                                                  fontFamily: 'Geistsans',
                                                  fontSize: 16,
                                                  color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 53, 53, 53),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  showCupertinoDialog(
                                                    context: context,
                                                    builder: (context) => CupertinoAlertDialog(
                                                      title: Text("Payment Information"),
                                                      content: Column(
                                                        children: [
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Currently, our app doesn't support direct payment integrations with e-wallets, banks, or other financial systems. "
                                                            "We encourage you to upload proof of payment here to ensure transparency and verification between landlords and occupants. "
                                                            "Your payment receipts are securely stored and provide a record for the landlord to review and confirm transactions."
                                                          ),
                                                          SizedBox(height: 8),
                                                        ],
                                                      ),
                                                      actions: [
                                                        CupertinoDialogAction(
                                                          isDefaultAction: true,
                                                          child: Text("Got it"),
                                                          onPressed: () => Navigator.of(context).pop(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                child: Icon(Icons.help_outline_outlined, color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 54, 54, 54)),
                                              ),
                                            ],
                                          ),

                                        PaymentUploadWidget(
                                            inquiryId: inquiryId,
                                            userId: userId,
                                            roomDetails: roomDetails,
                                            token: widget.token,
                                            selectedMonths: selectedMonths,
                                            uploadProofOfPayment:
                                                uploadProofOfPayment,
                                            isDarkMode: isDarkMode,
                                            amountController:
                                                amountController,
                                         ),

                                         SizedBox(height: 20,),
                                         RoommatesWidget(roomDetails: roomDetails)


                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No inquiries found.'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }



}


