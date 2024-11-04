import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rentcon/theme_controller.dart';

class AgreementDetails extends StatefulWidget {
  final String inquiryId; // Accept inquiry ID as a parameter

  const AgreementDetails({Key? key, required this.inquiryId}) : super(key: key);

  @override
  State<AgreementDetails> createState() => _AgreementDetailsState();
}

class _AgreementDetailsState extends State<AgreementDetails> {
  Map<String, dynamic>? agreement; // To store fetched agreement data
  bool isLoading = true; // To manage loading state
  String? errorMessage; // To store error message if any
  String? landlordName;
  String? landlordEmail;
  String? occupantName;
  String? occupantEmail;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    fetchAgreementDetails(); // Fetch agreement details on init
  }

  Future<void> fetchAgreementDetails() async {
    final String apiUrl = 'https://rentconnect-backend-nodejs.onrender.com/rental-agreement/inquiry/${widget.inquiryId}';
    print('Fetching agreement details from: $apiUrl'); // Debugging statement

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Response status: ${response.statusCode}'); // Debugging statement

      // Declare decodedResponse outside the if block
      Map<String, dynamic>? decodedResponse;

      if (response.statusCode == 200) {
        decodedResponse = json.decode(response.body);
        print('Decoded response: $decodedResponse'); // Debugging statement
        
        if (decodedResponse?['agreement'] != null) {
          setState(() {
            agreement = decodedResponse?['agreement'];
            isLoading = false;
          });

          print('Agreement fetched successfully: $agreement'); // Debugging statement
          // Fetch user details after agreement is set
          await fetchUserDetails(); // Call this function here
        } else {
          setState(() {
            errorMessage = 'No agreement found';
            isLoading = false;
          });
          print('Error: No agreement found'); // Debugging statement
        }
      } else {
        decodedResponse = json.decode(response.body); // Decode the response body in case of an error
        setState(() {
          errorMessage = decodedResponse?['error'] ?? 'Error fetching agreement';
          isLoading = false;
        });
        print('Error fetching agreement: ${decodedResponse?['error']}'); // Debugging statement
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load agreement details';
        isLoading = false;
      });
      print('Error: $error'); // Debugging statement
    }
  }

  Future<void> fetchUserDetails() async {
    if (agreement != null) {
      try {
        // Fetch landlord details
        final landlordId = agreement!['landlordId']['_id']; // Use only the ID
        print('Fetching landlord details for ID: $landlordId'); // Debug log

        final landlordResponse = await http.get(
          Uri.parse('https://rentconnect-backend-nodejs.onrender.com/user/$landlordId'), // Correct URL
        );

        if (landlordResponse.statusCode == 200) {
          final landlordData = json.decode(landlordResponse.body);
          setState(() {
            landlordName = '${landlordData['profile']['firstName']} ${landlordData['profile']['lastName']}';
            landlordEmail = landlordData['email'];
          });
        } else {
          print('Landlord response status: ${landlordResponse.statusCode}'); // Debug log
          print('Error fetching landlord details: ${landlordResponse.body}'); // Debug log
          setState(() {
            errorMessage = 'Failed to load landlord details';
          });
        }

        // Fetch occupant details
        final occupantId = agreement!['occupantId']['_id']; // Use only the ID
        print('Fetching occupant details for ID: $occupantId'); // Debug log

        final occupantResponse = await http.get(
          Uri.parse('https://rentconnect-backend-nodejs.onrender.com/user/$occupantId'), // Correct URL
        );

        if (occupantResponse.statusCode == 200) {
          final occupantData = json.decode(occupantResponse.body);
          setState(() {
            occupantName = '${occupantData['profile']['firstName']} ${occupantData['profile']['lastName']}';
            occupantEmail = occupantData['email'];
          });
        } else {
          print('Occupant response status: ${occupantResponse.statusCode}'); // Debug log
          print('Error fetching occupant details: ${occupantResponse.body}'); // Debug log
          setState(() {
            errorMessage = 'Failed to load occupant details';
          });
        }
      } catch (error) {
        print('Exception occurred: $error'); // Debug log
        setState(() {
          errorMessage = 'Failed to load user details';
        });
      }
    }
  }

@override
Widget build(BuildContext context) {
  // Display loading indicator while fetching data
  if (isLoading) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Agreement Details'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  // Display error message if there's any
  if (errorMessage != null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Agreement Details'),
      ),
      body: Center(child: Text(errorMessage!)),
    );
  }

  // Check if agreement is null before accessing it
  if (agreement == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Agreement Details'),
      ),
      body: const Center(child: Text('No agreement data available')),
    );
  }

  // If data is successfully fetched, display agreement details
  final String roomId = agreement!['roomId'] ?? 'N/A'; // Use fallback value
  final int monthlyRent = agreement!['monthlyRent'] ?? 0; // Use fallback value
  final String securityDeposit = agreement!['securityDeposit'] ?? '0.0'; // Use fallback value
  final String leaseStartDate = agreement!['leaseStartDate'] ?? 'N/A'; // Use fallback value
  final String leaseEndDate = agreement!['leaseEndDate'] ?? 'N/A'; // Use fallback value
  final String terms = agreement!['terms'] ?? 'N/A'; // Use fallback value
  final String status = agreement!['status'] ?? 'N/A'; // Use fallback value

  return Scaffold(
    appBar: AppBar(
      title: const Text('Rental Agreement Details'),
      leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove any padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Use stretch to occupy full width
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room ID:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('$roomId', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Landlord Name:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('${landlordName ?? 'Loading...'}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Landlord Email:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('${landlordEmail ?? 'Loading...'}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Occupant Name:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('${occupantName ?? 'Loading...'}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Occupant Email:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('${occupantEmail ?? 'Loading...'}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Rent:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('\$${monthlyRent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Security Deposit:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('\$${securityDeposit}', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Lease Start Date:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('$leaseStartDate', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Lease End Date:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('$leaseEndDate', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Terms:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('$terms', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                    const SizedBox(height: 10),
                    Text('Status:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope')),
                    Text('$status', style: const TextStyle(fontSize: 16, fontFamily: 'manrope')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

}
