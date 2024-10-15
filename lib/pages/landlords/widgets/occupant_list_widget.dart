import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rentcon/pages/agreementDetails.dart';

class OccupantListWidget extends StatelessWidget {
  final List<dynamic> occupantUsers;
  final Map<String, dynamic> userProfiles;
  final Map<String, dynamic> profilePic;
  final Function(String) fetchUserProfile;
  final bool isDarkMode;
  final Map<String, dynamic> room; // Room passed to access the agreement
  final Map<String, List<dynamic>> propertyInquiries; // Added property inquiries

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
        Text(
          'Occupants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'geistsans',
          ),
        ),
        const SizedBox(height: 10),
        // List of occupants
        Container(
          height: (60 * occupantUsers.length).toDouble(), // Adjust height dynamically
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDarkMode
                ? Color.fromARGB(122, 194, 193, 228)
                : Color.fromARGB(255, 249, 248, 255),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: occupantUsers.map<Widget>((occupantId) {
              if (userProfiles.containsKey(occupantId)) {
                var occupantProfile = userProfiles[occupantId];
                var profilePicture = profilePic[occupantId];
                String fullName = '${occupantProfile['firstName']} ${occupantProfile['lastName']}';
                String profilePictureUrl = profilePicture ?? '';

                return ListTile(
                  leading: Container(
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
                          : AssetImage('assets/images/profile.png') as ImageProvider,
                    ),
                  ),
                  title: Text(fullName),
                  trailing: IconButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Occupant Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: $fullName'),
                                Text('Gender: ${occupantProfile['gender']}'),
                                Text('Phone: ${occupantProfile['contactDetails']['phone']}'),
                                Text('Address: ${occupantProfile['contactDetails']['address']}'),
                              ],
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
                    icon: Icon(Icons.contact_emergency),
                  ),
                );
              } else {
                fetchUserProfile(occupantId);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  title: Text('Loading...'),
                );
              }
            }).toList(), // Convert map to list of widgets
          ),
        ),
        const SizedBox(height: 20),
        // Add button to navigate to the agreement page
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
                    inquiryId: inquiryId, // Pass the inquiry ID to the details page
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
            backgroundColor: isDarkMode ? const Color.fromARGB(255, 41, 43, 53) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set the border radius
              side: BorderSide(
                color: isDarkMode ? Colors.white : Colors.black, // Set border color
                width: 1, // Set border width
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Adjusts the button size to fit its contents
            children: [
               Icon(Icons.assignment, color: isDarkMode? Colors.white:Colors.black,), // Add your desired icon here
              const SizedBox(width: 8), // Space between icon and text
               Text('View Agreement', style: TextStyle(
                color: isDarkMode? Colors.white:Colors.black
              ),), // Button text
            ],
          ),
        ),

      ],
    );
  }
}
