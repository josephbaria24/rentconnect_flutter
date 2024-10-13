import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Hasinquiry extends StatelessWidget {
  final List<dynamic> occupantUsers;
  final Map<String, dynamic> userProfiles;
  final Map<String, dynamic> profilePic;
  final Function(String) fetchUserProfile;
  final bool isDarkMode;

  const Hasinquiry({
    Key? key,
    required this.occupantUsers,
    required this.userProfiles,
    required this.profilePic,
    required this.fetchUserProfile,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Occupants',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'geistsans'),
        ),
        const SizedBox(height: 10),
        // List of occupants
        Container(
          height: (60 * occupantUsers.length).toDouble(),  // Adjust height dynamically based on items
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
                String fullName =
                    '${occupantProfile['firstName']} ${occupantProfile['lastName']}';
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
      ],
    );
  }
}
