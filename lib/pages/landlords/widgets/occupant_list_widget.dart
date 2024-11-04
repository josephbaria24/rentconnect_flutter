// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rentcon/pages/agreementDetails.dart';
import 'package:rentcon/pages/fullscreenImage.dart';

class OccupantListWidget extends StatelessWidget {
  final List<dynamic> occupantUsers;
  final Map<String, dynamic> userProfiles;
  final Map<String, dynamic> profilePic;
  final Function(String) fetchUserProfile;
  final bool isDarkMode;
  final Map<String, dynamic> room; // Room passed to access the agreement
  final Map<String, List<dynamic>>
      propertyInquiries; // Added property inquiries

  const OccupantListWidget({
    Key? key,
    required this.occupantUsers,
    required this.userProfiles,
    required this.profilePic,
    required this.fetchUserProfile,
    required this.isDarkMode,
    required this.room,
    required this.propertyInquiries, // Ensure property inquiries are passed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            final inquiries = propertyInquiries[room['_id']];
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
            backgroundColor: isDarkMode
                ? const Color.fromARGB(255, 41, 43, 53)
                : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set the border radius
              // side: BorderSide(
              //   color: isDarkMode
              //       ? const Color.fromARGB(255, 146, 146, 146)
              //       : Colors.black, // Set border color
              //   width: 0.5, //0.5 Set border width
              // ),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Adjusts the button size to fit its contents
            children: [
              Icon(Icons.assignment,
                  color: isDarkMode ? Colors.white : Colors.black),
              const SizedBox(width: 2), // Space between icon and text
              Text(
                'Agreement',
                style: TextStyle(
                  fontFamily: 'manrope',
                  fontSize: 12,

                  color: isDarkMode ? Colors.white : Colors.black,
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
          height: 71, // Adjust to fit within available space
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDarkMode
                ? Color.fromARGB(255, 41, 43, 53)
                : Color.fromARGB(255, 255, 255, 255),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: occupantUsers.length > 3
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
    return occupantUsers.map<Widget>((occupantId) {
      if (userProfiles.containsKey(occupantId)) {
        var occupantProfile = userProfiles[occupantId];
        var profilePicture = profilePic[occupantId];
        String fullName =
            '${occupantProfile['firstName']} ${occupantProfile['lastName']}';
        String profilePictureUrl = profilePicture ?? '';

        return GestureDetector(
          onTap: () {
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
                        // Add profile picture as a small avatar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullscreenImage(
                                            imageUrl: profilePictureUrl)));
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: profilePictureUrl.isNotEmpty
                                    ? NetworkImage(profilePictureUrl)
                                    : AssetImage('assets/images/profile.png')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(
                                width: 10), // Spacing between image and text
                            Expanded(
                              // Ensure the text fits in available space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name with wrapping and ellipsis if it overflows
                                  Text(
                                    'Name: $fullName',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines:
                                        2, // Wrap to a second line if necessary
                                  ),
                                  const SizedBox(
                                      height: 4), // Spacing between details
                                  // Gender
                                  Text(
                                    'Gender: ${occupantProfile['gender']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  // Phone
                                  Text(
                                    'Phone: ${occupantProfile['contactDetails']['phone']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  // Address with wrapping for long addresses
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
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
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
                    backgroundImage: profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : AssetImage('assets/images/profile.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Text(
                    fullName,
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
          ),
        );
      } else {
        fetchUserProfile(occupantId);
        return Container(
          height: 63,
          width: 45,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  'Loading...',
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
    }).toList(); // Convert map to list of widgets
  }
}
