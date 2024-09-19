import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
  String requestStatus = 'Pending'; // Default request status for the dropdown

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown ID';
  }

  // Fetch occupant inquiries from the database
  Future<List<Map<String, dynamic>>> fetchInquiries(String userId, String token) async {
    print('Fetching inquiries for userId: $userId'); // Debugging line
    final response = await http.get(
      Uri.parse('http://192.168.1.6:3000/inquiries/occupant/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Inquiries fetched successfully'); // Debugging line
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((inquiry) => inquiry as Map<String, dynamic>).toList();
    } else {
      print('Failed to load inquiries: ${response.statusCode}'); // Debugging line
      throw Exception('Failed to load inquiries');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Inquiries"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Dropdown Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.home, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[850],
                        value: requestStatus,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (String? newValue) {
                          setState(() {
                            requestStatus = newValue!;
                          });
                        },
                        items: <String>['Pending', 'Approved', 'Rejected']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expanded list of inquiries
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchInquiries(widget.userId, widget.token), // Fetch inquiries
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('Error fetching inquiries: ${snapshot.error}'); // Debugging line
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final inquiries = snapshot.data!;

                    if (inquiries.isEmpty) {
                      print('No inquiries found'); // Debugging line
                      return const Center(child: Text('No inquiries found.'));
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2, // Adjusted for card size with image
                      ),
                      itemCount: inquiries.length, // Adjusted for dynamic inquiries
                      itemBuilder: (context, index) {
                        final inquiry = inquiries[index];
                        final roomDetails = inquiry['roomId']; // roomId now contains room details

                        if (roomDetails == null) {
                          print('Error: roomDetails is null for inquiry: $inquiry'); // Debugging line
                          return const Center(child: Text('Invalid room information.'));
                        }

                        // Select the first available photo from photo1, photo2, or photo3
                        final String? roomPhotoUrl = roomDetails['photo1'] ?? roomDetails['photo2'] ?? roomDetails['photo3'];
                        final String defaultPhoto = 'https://via.placeholder.com/150'; // Placeholder image

                        return Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.pending_actions, size: 40, color: Colors.purpleAccent),
                                const SizedBox(height: 8),
                                Text(
                                  'Request Status: ${inquiry['status']}',
                                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Room: ${roomDetails['roomNumber']}',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  'Price: ₱${roomDetails['price']}',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 8),
                                // Display the room photo at the bottom
                                Image.network(
                                  roomPhotoUrl ?? defaultPhoto,
                                  fit: BoxFit.cover,
                                  height: 100, // Fixed height for the image
                                  width: double.infinity, // Takes up the card's width
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error, color: Colors.red);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No inquiries found.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
