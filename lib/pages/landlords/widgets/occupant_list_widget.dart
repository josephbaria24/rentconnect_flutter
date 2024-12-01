// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rentcon/pages/agreementDetails.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OccupantListWidget extends StatefulWidget {
  final List<dynamic> occupantUsers;
  final List<dynamic> occupantNonUsers;
  final Map<String, dynamic> userProfiles;
  final Map<String, dynamic> profilePic;
  final Function(String) fetchUserProfile;
  final bool isDarkMode;
  final Map<String, dynamic> room; // Room passed to access the agreement
  final Map<String, List<dynamic>>
      propertyInquiries; // Added property inquiries

  const OccupantListWidget({
    super.key,
    required this.occupantUsers,
    required this.occupantNonUsers,
    required this.userProfiles,
    required this.profilePic,
    required this.fetchUserProfile,
    required this.isDarkMode,
    required this.room,
    required this.propertyInquiries, // Ensure property inquiries are passed
  });

  @override
  State<OccupantListWidget> createState() => _OccupantListWidgetState();
}



class _OccupantListWidgetState extends State<OccupantListWidget> {

late Future<List<dynamic>> _occupantNonUsersFuture;


    @override
  void initState() {
    super.initState();
     _occupantNonUsersFuture = getOccupantNonUsers(widget.occupantNonUsers);
  }
  
Future<List<dynamic>> getOccupantNonUsers(List<dynamic> occupantNonUserIds) async {
  // Join the occupantNonUserIds into a comma-separated string
  final String ids = occupantNonUserIds.join(',');

  // Modify the URL to include the list of IDs as query parameters
  final String url = 'https://rentconnect.vercel.app/rooms/occupant?ids=$ids';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Successfully fetched data
      final data = json.decode(response.body);
      print('Response Body: ${response.body}');
      // Assuming the response contains the list of occupants
      return data;
    } else {
      // Handle server errors or not found
      throw Exception('Failed to load occupant non-users');
    }
  } catch (error) {
    print('Error fetching occupant non-users: $error');
    throw Exception('Error fetching occupant non-users');
  }
}


  @override
  Widget build(BuildContext context) {
    print('occupant: ${widget.occupantNonUsers}');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Occupants',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'manrope',
              ),
            ),
            ElevatedButton(
          onPressed: () {
            // Access the inquiries for the specific room using room ID
            final inquiries = widget.propertyInquiries[widget.room['_id']];
            if (inquiries != null && inquiries.isNotEmpty) {
              // Pass the first inquiry's ID or handle accordingly
              final inquiry = inquiries.first; // Get the first inquiry object
              final inquiryId = inquiry['_id']; // Get the inquiry ID

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgreementDetails(
                    inquiryId:
                        inquiryId, // Pass the inquiry ID to the details page
                  ),
                ),
              );
            } else {
              // Handle case where inquiry data is missing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No agreement details available.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDarkMode
                ? const Color.fromARGB(255, 41, 43, 53)
                : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Adjusts the button size to fit its contents
            children: [
              Icon(Icons.assignment,
                  color: widget.isDarkMode ? Colors.white : Colors.black),
              const SizedBox(width: 2), // Space between icon and text
              Text(
                'Agreement',
                style: TextStyle(
                  fontFamily: 'manrope',
                  fontSize: 12,

                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ), // Button text
            ],
          ),
        ),
          ],
        ),
        
        const SizedBox(height: 4),
        // List of occupants
        Container(
          height: 80, // Adjust to fit within available space
          decoration: BoxDecoration(
            border: Border.all(width: 0.5),
            borderRadius: BorderRadius.circular(10),
            color: widget.isDarkMode
                ? Color.fromARGB(255, 41, 43, 53)
                : Color.fromARGB(255, 255, 255, 255),
            
          ),
          child: widget.occupantUsers.length > 3
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildOccupantRows(context), // Pass context here
                  ),
                )
              : Row(
                  children: _buildOccupantRows(context), // Pass context here
                ),
        ),
        const SizedBox(height: 10),
        // Add button to navigate to the agreement page
        
      ],
    );
  }

List<Widget> _buildOccupantRows(BuildContext context) {
  // Combine occupantUsers and occupantNonUsers
  final combinedOccupants = [
    ...widget.occupantUsers.map((id) => {'type': 'user', 'id': id}),
  ];

  return combinedOccupants.map<Widget>((occupant) {
    if (occupant['type'] == 'user') {
      // Handle occupantUsers
      final occupantId = occupant['id'];
      if (widget.userProfiles.containsKey(occupantId)) {
        var occupantProfile = widget.userProfiles[occupantId];
        var profilePicture = widget.profilePic[occupantId];
        String fullName = '${occupantProfile['firstName']} ${occupantProfile['lastName']}';
        String profilePictureUrl = profilePicture ?? '';

        return GestureDetector(
          onTap: () {
            // Show details dialog for user occupant
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text('Occupant Details'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullscreenImage(imageUrl: profilePictureUrl),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: profilePictureUrl.isNotEmpty
                                    ? NetworkImage(profilePictureUrl)
                                    : AssetImage('assets/images/profile.png') as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: $fullName',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gender: ${occupantProfile['gender']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phone: ${occupantProfile['contactDetails']['phone']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Address: ${occupantProfile['contactDetails']['address']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: _buildOccupantAvatar(fullName, profilePictureUrl, widget.isDarkMode, true),
        );
      } else {
        widget.fetchUserProfile(occupantId);
        return _buildOccupantAvatar('Loading...', null, widget.isDarkMode, true);
      }
    } else if (occupant['type'] == 'nonUser') {
      // Handle occupantNonUsers
      final nonUser = occupant['data'];
      String guestName = nonUser['name'] ?? 'Guest';
      String guestAvatar = nonUser['avatar'] ?? '';  // You can use avatar if needed

      return _buildOccupantAvatar(guestName, guestAvatar, widget.isDarkMode, false);
    }
    return Container(); // Fallback (shouldn't be reached)
  }).toList();
}


Widget _buildOccupantAvatar(
    String name, String? imageUrl, bool isDarkMode, bool isUser) {
  return Container(
    height: 63,
    width: 70,
    margin: EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode
                  ? const Color.fromARGB(255, 33, 243, 233)
                  : const Color.fromARGB(255, 22, 22, 22),
              width: 1.0,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : AssetImage(
                        isUser ? 'assets/images/profile.png' : 'assets/images/guest.png')
                    as ImageProvider,
          ),
        ),
        const SizedBox(height: 5),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'manrope',
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    ),
  );
}
}
