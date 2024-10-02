// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:ui';
import 'package:http_parser/http_parser.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/pages/components/glassmorphism.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OccupantInquiries extends StatefulWidget {
  final String userId;
  final String token;

  const OccupantInquiries({Key? key, required this.userId, required this.token}) : super(key: key);

  @override
  State<OccupantInquiries> createState() => _OccupantInquiriesState();
}

class _OccupantInquiriesState extends State<OccupantInquiries> {
  late String userId;
  late String email;
  String requestStatus = 'Pending';
    final ThemeController _themeController = Get.find<ThemeController>();
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
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown ID';
  }

  Future<List<Map<String, dynamic>>> fetchInquiries(String userId, String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.31:3000/inquiries/occupant/$userId'),
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




Future<void> _uploadProofOfReservation(String inquiryId, String occupantId, String roomId, String landlordId) async {
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
      Uri.parse('http://192.168.1.31:3000/payment/uploadProofOfReservation'),
    );

    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.fields['inquiryId'] = inquiryId;

    // Add required IDs to the request
    request.fields['occupantId'] = occupantId; // Add occupant ID
    request.fields['roomId'] = roomId;         // Add room ID
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
        contentType: MediaType.parse(contentType), // Set content type dynamically
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
  final url = 'http://192.168.1.31:3000/payment/room/$roomId/proofOfReservation';

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
      return data['proofOfReservation']; // Adjust based on the actual API response structure
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
  final uri = Uri.parse('http://192.168.1.31:3000/rooms/getRoom/$roomId');

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
      msg: 'Failed to fetch room details. Status code: ${response.statusCode}',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}



Future<void> _fetchLandlordId(String propertyId) async {
  final uri = Uri.parse('http://192.168.1.31:3000/getPropertiesByIds');

  final response = await http.post(
    uri,
    body: jsonEncode({'ids': propertyId}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final propertyDetails = jsonDecode(response.body);

    // Check if propertyDetails is valid and has the expected structure
    if (propertyDetails['status'] == true && propertyDetails['properties'].isNotEmpty) {
      // Get the userId as landlordId
      landlordId = propertyDetails['properties'][0]['userId']; // Adjust if you have a separate landlordId
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
  final String apiUrl = 'http://192.168.1.31:3000/room/$roomId/monthlyPayments'; // Update with your API endpoint

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
        final proofOfPayment = monthlyPayments.last['proofOfPayment'] as String?;
        return proofOfPayment; // Return the proof of payment URL
      } else {
        return null; // No payments found
      }
    } else {
      throw Exception('Failed to fetch proof of payment: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching proof of payment: $e');
    return null; // Return null if there's an error
  }
}

Future<void> uploadProofOfPayment(
  String inquiryId,
  String userId,
  String roomId,
  String month,
  String landlordId,
  String token,
) async {
  try {
    // Pick the image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Get the image type
      final String? fileExtension = image.name.split('.').last.toLowerCase();
      print('Selected file extension: $fileExtension');

      // Check for valid file types (e.g., jpg, png, jpeg)
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        Fluttertoast.showToast(
          msg: 'Invalid file type. Please upload a JPG or PNG image.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return; // Stop execution if the file type is invalid
      }

      // Convert image to bytes
      final bytes = await image.readAsBytes();

      // Prepare the request to create a monthly payment
      final paymentRequest = http.MultipartRequest(
        'POST', // Use POST to create a new monthly payment
        Uri.parse('http://192.168.1.31:3000/payment/createMonthlyPayment'),
      );

      paymentRequest.headers['Authorization'] = 'Bearer $token';
      paymentRequest.fields['occupantId'] = userId; // Assuming userId is the occupantId
      paymentRequest.fields['landlordId'] = landlordId;
      paymentRequest.fields['roomId'] = roomId;

      // Prepare monthlyPayments data as a JSON string
      final monthlyPaymentsJson = jsonEncode([
        {
          "month": month,
          "amount": 0, // Replace with actual amount if needed
          "status": "pending" // Add status if needed
        }
      ]);

      // Set monthlyPayments field
      paymentRequest.fields['monthlyPayments'] = monthlyPaymentsJson;

      // Attach the image file for proofOfPayment with content type
      paymentRequest.files.add(http.MultipartFile.fromBytes(
        'proofOfPayment',
        bytes,
        filename: image.name,
        contentType: MediaType('image', fileExtension!), // Explicitly set content type
      ));

      // Send the request to create the monthly payment
      final paymentResponse = await paymentRequest.send();

      if (paymentResponse.statusCode == 201) {
        Fluttertoast.showToast(
          msg: 'Monthly payment created successfully.',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Now update proof of payment for the specific month (optional)
        final updateRequest = http.MultipartRequest(
          'PUT',
          Uri.parse('http://192.168.1.31:3000/payment/updateProofOfPayment'),
        );

        updateRequest.headers['Authorization'] = 'Bearer $token';
        updateRequest.fields['roomId'] = roomId;
        updateRequest.fields['month'] = month;

        // Attach the image file again for proofOfPayment update (if necessary)
        updateRequest.files.add(http.MultipartFile.fromBytes(
          'proofOfPayment',
          bytes,
          filename: image.name,
          contentType: MediaType('image', fileExtension!), // Explicitly set content type
        ));

        final updateResponse = await updateRequest.send();

        if (updateResponse.statusCode == 200) {
          Fluttertoast.showToast(
            msg: 'Proof of payment uploaded successfully.',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          print('Failed to update proof of payment. Status code: ${updateResponse.statusCode}');
          Fluttertoast.showToast(
            msg: 'Failed to update proof of payment.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        print('Failed to create monthly payment. Status code: ${paymentResponse.statusCode}');
        Fluttertoast.showToast(
          msg: 'Failed to create monthly payment.',
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

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 28, 29, 34) : Colors.white,
    appBar: AppBar(
      backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 28, 29, 34) : Colors.white,
      title: const Text(
        'My Home & Inquiries',
        style: TextStyle(fontFamily: 'GeistSans', fontWeight: FontWeight.bold),
      ),
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios_new_outlined),
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
                        return const Center(child: Text('Invalid room information.'));
                      }

                      final String? roomPhotoUrl = roomDetails['photo1'] ?? roomDetails['photo2'] ?? roomDetails['photo3'];
                      final String defaultPhoto = 'https://via.placeholder.com/150';
                      final String placeholderPhoto = 'https://via.placeholder.com/150?text=No+Proof+Uploaded';

                      // Initialize selected month for this inquiry if not already done
                      if (!selectedMonths.containsKey(inquiryId)) {
                        selectedMonths[inquiryId] = null; // Default to null
                      }

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
                          backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 36, 38, 43) : const Color.fromARGB(255, 255, 255, 255),
                          border: Border(),
                          width: 350,
                          title: Text(
                            'Room: ${roomDetails['roomNumber']}',
                            style: TextStyle(
                              fontFamily: 'GeistSans',
                              color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                            ),
                          ),
                          description: Text(
                            'Request Status: ${inquiry['status']}\nPrice: ₱${roomDetails['price']}',
                            style: TextStyle(fontFamily: 'Roboto'),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Image.network(
                                  roomPhotoUrl ?? defaultPhoto,
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 300,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error, color: Color.fromARGB(255, 190, 5, 51));
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Request Type: ${inquiry['requestType']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Show dropdown and upload button only when status is approved
                                if (inquiry['status'] == 'approved') ...[
                                  // Dropdown for selecting the month
                                  DropdownButton<String>(
                                    hint: const Text('Select Month'),
                                    value: selectedMonths[inquiryId],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMonths[inquiryId] = newValue; // Update selected month
                                      });
                                    },
                                    items: months.map<DropdownMenuItem<String>>((String month) {
                                      return DropdownMenuItem<String>(
                                        value: month,
                                        child: Text(month),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Upload Proof of Reservation Fee:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ShadButton(
                                    backgroundColor: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(255, 1, 0, 40),
                                    onPressed: () async {
                                     
                                        // Use the selected month from the dropdown
                                        String? selectedMonth = selectedMonths[inquiryId];

                                        // Check if a month is selected
                                        if (selectedMonth != null && selectedMonth.isNotEmpty) {
                                          await uploadProofOfPayment(
                                            inquiry['_id'],
                                            widget.userId,
                                            roomDetails['_id'],
                                            selectedMonth,
                                            roomDetails['ownerId'],
                                            widget.token,
                                            // Pass the selected month
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Please select a month before uploading.',
                                            backgroundColor: Colors.orange,
                                            textColor: Colors.white,
                                          );
                                        }
                                      
                                    },
                                    child: Text('Upload Proof of Reservation', style: TextStyle(
                                      color: _themeController.isDarkMode.value ? Colors.black : Colors.white,
                                    )),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('No inquiries found.'));
              },
            ),
          ],
        ),
      ),
    ));
  }
}



