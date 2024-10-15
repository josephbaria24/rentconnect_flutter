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
import 'package:rentcon/pages/occupants/widgets/detail_room_property.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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

  late String landlordId;

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

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken =
        JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown ID';
    loadPropertyDetails(userId, widget.token);
  }

  Future<List<Map<String, dynamic>>> fetchInquiries(
      String userId, String token) async {
    final response = await http.get(
      Uri.parse('https://rentconnect-backend-nodejs.onrender.com/inquiries/occupant/$userId'),
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

  Map<String, dynamic>? propertyRoomDetails;

  Future<void> fetchPropertyDetails(String roomId) async {
    final url = 'https://rentconnect-backend-nodejs.onrender.com/inquiries/room/$roomId/property';

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

  Future<void> _uploadProofOfReservation(String inquiryId, String occupantId,
      String roomId, String landlordId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (landlordId == null) {
      // Handle the case where landlordId is null
      Fluttertoast.showToast(
        msg: 'Landlord ID is required.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return; // Early exit if landlordId is null
    }
    if (image != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/payment/uploadProofOfReservation'),
      );

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['inquiryId'] = inquiryId;

      // Add required IDs to the request
      request.fields['occupantId'] = occupantId; // Add occupant ID
      request.fields['roomId'] = roomId; // Add room ID
      request.fields['landlordId'] = landlordId; // Add landlord ID

      final fileStream = http.ByteStream(Stream.castFrom(image.openRead()));
      final length = await image.length();

      // Determine the content type based on the file extension
      String contentType = 'application/octet-stream'; // Default type
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
          contentType:
              MediaType.parse(contentType), // Set content type dynamically
        ),
      );

      try {
        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: 'Proof of reservation uploaded successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          setState(() {});
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to upload proof of reservation: ${responseData.body}',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error uploading proof of reservation: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No image selected.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<String?> getProofOfReservation(String roomId, String token) async {
    final url =
        'https://rentconnect-backend-nodejs.onrender.com/payment/room/$roomId/proofOfReservation';

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
    final uri = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/rooms/getRoom/$roomId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final roomDetails = jsonDecode(response.body);

      // Check if roomDetails contain the propertyId
      if (roomDetails != null && roomDetails['room'] != null) {
        String propertyId = roomDetails['room']['propertyId'];

        // Fetch landlordId using propertyId
        await _fetchLandlordId(propertyId);
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

  Future<void> _fetchLandlordId(String propertyId) async {
    final uri = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/getPropertiesByIds');

    final response = await http.post(
      uri,
      body: jsonEncode({'ids': propertyId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final propertyDetails = jsonDecode(response.body);

      // Check if propertyDetails is valid and has the expected structure
      if (propertyDetails['status'] == true &&
          propertyDetails['properties'].isNotEmpty) {
        // Get the userId as landlordId
        landlordId = propertyDetails['properties'][0]
            ['userId']; // Adjust if you have a separate landlordId
      } else {
        Fluttertoast.showToast(
          msg: 'No properties found or status is false.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg:
            'Failed to fetch property details. Status code: ${response.statusCode}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<String?> getProofOfPayment(String roomId, String token) async {
    final String apiUrl =
        'https://rentconnect-backend-nodejs.onrender.com/room/$roomId/monthlyPayments'; // Update with your API endpoint

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
        'https://rentconnect-backend-nodejs.onrender.com/payment/room/$roomId/payment/month/proof/reservation';

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
          Uri.parse(
              'https://rentconnect-backend-nodejs.onrender.com/payment/createoraddMonthlyPayment'),
        );

        // Adding headers
        paymentRequest.headers['Authorization'] = 'Bearer $token';

        // Adding fields
        paymentRequest.fields['occupantId'] = userId;
        paymentRequest.fields['landlordId'] = landlordId;
        paymentRequest.fields['roomId'] = roomId;

        // Ensure correct form-data format for monthlyPayments as an array
        paymentRequest.fields['monthlyPayments[0][amount]'] =
            amount.toString(); // Pass amount dynamically
        paymentRequest.fields['monthlyPayments[0][month]'] =
            month; // Month for payment
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
        } else {
          print(
              'Failed to create or add monthly payment. Status code: ${paymentResponse.statusCode}');
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
        'https://rentconnect-backend-nodejs.onrender.com/inquiries/delete/$inquiryId';
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
    print('Property detail: $propertyRoomDetails');
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
          padding: const EdgeInsets.all(18.0),
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

                          final String? roomPhotoUrl = roomDetails['photo1'] ??
                              roomDetails['photo2'] ??
                              roomDetails['photo3'];
                          final String defaultPhoto =
                              'https://via.placeholder.com/150';

                          // Initialize selected month for this inquiry if not already done
                          if (!selectedMonths.containsKey(inquiryId)) {
                            selectedMonths[inquiryId] = null; // Default to null
                          }

                          // FutureBuilder to get proof of reservation photo
                          return FutureBuilder<String?>(
                            future: getProofOfReservation(
                                roomDetails['_id'], widget.token),
                            builder: (context, proofSnapshot) {
                              final String? proofOfReservation =
                                  proofSnapshot.data ?? '';

                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ShadCard(
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                  backgroundColor:
                                      _themeController.isDarkMode.value
                                          ? Color.fromARGB(255, 36, 38, 43)
                                          : const Color.fromARGB(
                                              255, 255, 255, 255),
                                  border: Border(),
                                  width: 350,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Align title and details
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Room: ${roomDetails['roomNumber']}',
                                          style: TextStyle(
                                            fontFamily: 'GeistSans',
                                            color: _themeController
                                                    .isDarkMode.value
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (propertyRoomDetails != null) {
                                            final coordinates =
                                                propertyRoomDetails!['location']
                                                    [
                                                    'coordinates']; // Ensure it's not null
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PropertyDetailsWidget(
                                                  location:
                                                      '${propertyRoomDetails!['street']}, ${propertyRoomDetails!['barangay']}, ${propertyRoomDetails!['city']}', // Format the location
                                                  amenities: jsonDecode(
                                                      propertyRoomDetails![
                                                              'amenities'][
                                                          0]), // Parse the JSON string to get the list
                                                  description: propertyRoomDetails![
                                                      'description'], // Get the description
                                                  coordinates: coordinates.cast<
                                                      double>(), // Ensure coordinates are in double format
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'View details',
                                          style: TextStyle(
                                            color: _themeController
                                                    .isDarkMode.value
                                                ? const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                : const Color.fromARGB(
                                                    255, 0, 0, 0),
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'geistsans',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        CupertinoIcons.chevron_forward,
                                        size: 16,
                                      )
                                    ],
                                  ),
                                  description: Text(
                                    'Request Status: ${inquiry['status']}\nPrice: ₱${roomDetails['price']}',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Colors.white),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 1),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Add Remaining Time Widget
                                        if (inquiry['requestType'] ==
                                                'reservation' &&
                                            inquiry['status'] == 'approved' &&
                                            inquiry['isRented'] == false) ...[
                                          RemainingTimeWidget(
                                            approvalDate: DateTime.parse(
                                                inquiry['approvalDate']),
                                            reservationDuration: inquiry[
                                                'reservationDuration'], // Assuming this is in days
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 36, 38, 43): const Color.fromARGB(255, 255, 255, 255), // Background color
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
                                                mainAxisSize: MainAxisSize.min, // Adjust size based on content
                                                children: [
                                                  Icon(
                                                    _isImageVisible ? Icons.visibility_off : Icons.visibility,
                                                    color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                                                  ),
                                                  SizedBox(width: 8), // Add some space between the icon and the text
                                                  Text(
                                                    _isImageVisible ? 'Hide Image' : 'Show Room Image',
                                                    style: TextStyle(
                                                      color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
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
                                                builder: (context) => FullscreenImage(
                                                  imageUrl: roomPhotoUrl,
                                                ),
                                              ),
                                            );
                                          },
                                            child: Hero(
                                              tag: roomPhotoUrl!,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(width: 1, color: _themeController.isDarkMode.value?
                                                  Colors.white: Colors.black)
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Image.network(
                                                    roomPhotoUrl ?? defaultPhoto,
                                                    fit: BoxFit.contain,
                                                    height: 150,
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return const Icon(Icons.error,
                                                          color: Color.fromARGB(
                                                              255, 190, 5, 51));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Request Type: ${inquiry['requestType']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (inquiry['status'] == 'approved' &&
                                            inquiry['requestType'] ==
                                                'reservation' &&
                                            inquiry['isRented'] == false) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                              'Reservation fee: ${roomDetails['reservationFee']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('Proof of reservation fee:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.info_outline_rounded),
                                              SizedBox(
                                                  width:
                                                      8), // Add spacing between the icon and the text
                                              Flexible(
                                                child: Text(
                                                  'You can upload photo of receipt or hand-to-hand payment',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'geistsans',
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  softWrap:
                                                      true, // Enable text to wrap to the next line
                                                  overflow: TextOverflow
                                                      .visible, // Ensure the overflow is handled gracefully
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          proofOfReservation != null &&
                                                  proofOfReservation.isNotEmpty
                                              ? Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        DecoratedBox(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .black)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                Image.network(
                                                              proofOfReservation,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              height: 150,
                                                              width: 300,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return const Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top:
                                                              8, // Adjust the distance from the top as needed
                                                          right:
                                                              8, // Adjust the distance from the right as needed
                                                          child:
                                                              GestureDetector(
                                                      onTap: () async {
                                                        // Show confirmation dialog with custom theme
                                                        final bool? shouldDelete = await showDialog<bool>(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                'Confirm Deletion',
                                                                style: TextStyle(
                                                                  fontSize: 20.0,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: _themeController.isDarkMode.value ? CupertinoColors.white : CupertinoColors.black,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Are you sure you want to delete this proof of reservation?',
                                                                style: TextStyle(
                                                                  fontSize: 16.0,
                                                                  color: _themeController.isDarkMode.value ? CupertinoColors.white.withOpacity(0.7) : CupertinoColors.black.withOpacity(0.87),
                                                                ),
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                      color: _themeController.isDarkMode.value ? CupertinoColors.activeBlue : CupertinoColors.activeBlue,
                                                                    ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop(false); // Close dialog and return false
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      color: CupertinoColors.destructiveRed,
                                                                    ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop(true); // Close dialog and return true
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        // Check if user confirmed deletion
                                                        if (shouldDelete == true) {
                                                          print('Room ID before delete: ${roomDetails["_id"]},'); // Debugging line
                                                          await deleteProof(roomDetails["_id"], proofOfReservation); // Call your delete function here
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => OccupantInquiries(userId: userId, token: widget.token),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                          
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.6), // Background for the icon
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      4.0), // Adjust padding for the icon
                                                              child: const Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    ElevatedButton.icon(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            _themeController
                                                                    .isDarkMode
                                                                    .value
                                                                ? Colors.white
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    1,
                                                                    0,
                                                                    40), // Set background color based on dark mode
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16.0,
                                                            vertical:
                                                                10.0), // Add padding for button
                                                      ),
                                                      onPressed: () async {
                                                        await _uploadProofOfReservation(
                                                          inquiry['_id'],
                                                          widget.userId,
                                                          roomDetails['_id'],
                                                          roomDetails[
                                                              'ownerId'],
                                                        );
                                                      },
                                                      icon: SvgPicture.asset(
                                                        'assets/icons/change.svg',
                                                        color: _themeController
                                                                .isDarkMode
                                                                .value
                                                            ? Colors.black
                                                            : Colors
                                                                .white, // Set icon color based on dark mode
                                                      ),
                                                      label: Text(
                                                        'Change Photo',
                                                        style: TextStyle(
                                                          color: _themeController
                                                                  .isDarkMode
                                                                  .value
                                                              ? Colors.black
                                                              : Colors
                                                                  .white, // Set text color based on dark mode
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : ShadButton(
                                                  backgroundColor:
                                                      _themeController
                                                              .isDarkMode.value
                                                          ? Colors.white
                                                          : const Color
                                                              .fromARGB(
                                                              255, 1, 0, 40),
                                                  onPressed: () async {
                                                    await _uploadProofOfReservation(
                                                      inquiry['_id'],
                                                      widget.userId,
                                                      roomDetails['_id'],
                                                      roomDetails['ownerId'],
                                                    );
                                                  },
                                                  icon: Icon(Icons.add_a_photo),
                                                  child: Text(
                                                    'Upload Photo',
                                                    style: TextStyle(
                                                      color: _themeController
                                                              .isDarkMode.value
                                                          ? Colors.black
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .transparent, // No background color (transparent)
                                            elevation: 0, // Remove shadow
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical:
                                                    12.0), // Add padding if necessary
                                          ),
                                          onPressed: () async {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                    "Cancel Inquiry",
                                                    style: TextStyle(
                                                      color: _themeController
                                                              .isDarkMode.value
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  content: Text(
                                                      "This action is irreversible. Do you want to proceed?"),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text("No"),
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      onPressed: () async {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                        await _cancelInquiry(
                                                            inquiry['_id'],
                                                            widget.token);
                                                      },
                                                      child: Text("Yes"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            'Cancel Inquiry',
                                            style: TextStyle(
                                                color: _themeController
                                                        .isDarkMode.value
                                                    ? Colors.red
                                                    : Colors.red,
                                                fontFamily: 'geistsans',
                                                fontWeight: FontWeight
                                                    .w700), // Set text color as white
                                          ),
                                        )
                                        ],
                                        if (inquiry['status'] == 'approved' &&
                                            inquiry['requestType'] ==
                                                'reservation' &&
                                            inquiry['isRented'] == true) ...[
                                              PaymentUploadWidget(inquiryId: inquiryId, userId: userId, roomDetails: roomDetails, token: widget.token, selectedMonths: selectedMonths, uploadProofOfPayment: uploadProofOfPayment, isDarkMode: isDarkMode, amountController: amountController)
                                            ],
                                        
                                      ],
                                    ),
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
