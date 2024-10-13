import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentcon/theme_controller.dart';

class ReserverList extends StatelessWidget {
  final bool hasReserver;
  final Map<String, dynamic> room;
  final Map<String, dynamic> userProfiles;
  final Map<String, dynamic> profilePic;
  final ThemeController _themeController;
  final Function fetchUserProfile;

  const ReserverList({
    required this.hasReserver,
    required this.room,
    required this.userProfiles,
    required this.profilePic,
    required ThemeController themeController,
    required this.fetchUserProfile,
  }) : _themeController = themeController;

  @override
  Widget build(BuildContext context) {
    if (!hasReserver) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservant',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'geistsans'),
        ),
        Container(
          height: (60 * room['reservationInquirers'].length).toDouble(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _themeController.isDarkMode.value
                ? Color.fromARGB(255, 41, 43, 53)
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
            children: room['reservationInquirers'].map<Widget>((reserverId) {
              if (userProfiles.containsKey(reserverId)) {
                var reserverProfile = userProfiles[reserverId];
                var profilePicture = profilePic[reserverId];
                String fullName = '${reserverProfile['firstName']} ${reserverProfile['lastName']}';
                String profilePictureUrl = profilePicture ?? '';

                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _themeController.isDarkMode.value
                            ? const Color.fromARGB(255, 33, 243, 233)
                            : const Color.fromARGB(255, 22, 22, 22),
                        width: 1.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('assets/images/profile.png'),
                    ),
                  ),
                  title: Text(fullName),
                  trailing: IconButton(
                    onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: Text('Reserver Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: $fullName'),
                              Text('Gender: ${reserverProfile['gender']}'),
                              Text('Phone: ${reserverProfile['contactDetails']['phone']}'),
                              Text('Address: ${reserverProfile['contactDetails']['address']}'),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
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
                fetchUserProfile(reserverId);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  title: Text('Loading...'),
                );
              }
            }).toList(),
          ),
        ),
      ],
    );
  }
}
