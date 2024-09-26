import 'dart:convert';
import 'dart:ui';
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


  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown ID';
  }

  Future<List<Map<String, dynamic>>> fetchInquiries(String userId, String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.13:3000/inquiries/occupant/$userId'),
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

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34):Colors.white,
    appBar: AppBar(
      backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34):Colors.white,
        title: const Text('My Home & Inquiries',
        style: TextStyle(
          fontFamily: 'GeistSans',
          fontWeight: FontWeight.bold
        ),),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
    body: Padding(
      
      padding: const EdgeInsets.all(25.0),
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

                      if (roomDetails == null) {
                        return const Center(child: Text('Invalid room information.'));
                      }

                      final String? roomPhotoUrl = roomDetails['photo1'] ??
                          roomDetails['photo2'] ??
                          roomDetails['photo3'];
                      final String defaultPhoto = 'https://via.placeholder.com/150';

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ShadCard(
                          backgroundColor: _themeController.isDarkMode.value? Color.fromARGB(255, 36, 38, 43): Colors.grey,
                          border: Border(),
                          width: 350,
                          
                          title: Text(
                            'Room: ${roomDetails['roomNumber']}',
                            style: TextStyle(
                              fontFamily: 'GeistSans',
                            ),
                          ),
                          description: Text(
                            'Request Status: ${inquiry['status']}\nPrice: ₱${roomDetails['price']}',
                            style: TextStyle(
                              fontFamily: 'GeistSans'
                            ),
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
                                    return const Icon(Icons.error,
                                        color: Color.fromARGB(255, 190, 5, 51));
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
                              ],
                            ),
                          ),
                          
                          footer: inquiry['status'] == 'pending'
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ShadButton.outline(
                                      backgroundColor: _themeController.isDarkMode.value? Colors.white: Color.fromARGB(255, 10, 0, 40),
                                      child: Text('Cancel',
                                      style: TextStyle(
                                        color: _themeController.isDarkMode.value 
                                          ? Colors.black 
                                          : Colors.white,
                                      ),),
                                      onPressed: () async {
                                        final confirmCancel = await showCupertinoDialog<bool>(
                                          context: context,
                                          builder: (context) => CupertinoAlertDialog(
                                            title: const Text('Cancel Reservation'),
                                            content: const Text(
                                                'Are you sure you want to cancel this reservation?'),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('No'),
                                              ),
                                              CupertinoDialogAction(
                                                onPressed: () => Navigator.pop(context, true),
                                                isDestructiveAction: true,
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                        
                                        if (confirmCancel == true) {
                                          final cancelResponse = await http.delete(
                                            Uri.parse(
                                                'http://192.168.1.13:3000/inquiries/delete/${inquiry['_id']}'),
                                            headers: {
                                              'Authorization': 'Bearer ${widget.token}',
                                            },
                                          );
                        
                                          if (cancelResponse.statusCode == 200) {
                                            Fluttertoast.showToast(
                                              msg: 'Request canceled successfully',
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                            );
                                            setState(() {});
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: 'Failed to cancel request',
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    // ShadButton(
                                    //   child: const Text('Deploy'),
                                    //   onPressed: () {
                                    //     // Action for deploying
                                    //   },
                                    // ),
                                  ],
                                  
                                )
                                
                              : null,
                              
                        ),
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
}


}
