import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
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
          'Reservants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'geistsans',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          height: 70,
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
          child: room['reservationInquirers'].length > 4
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildReserverRows(context), // Build reserver rows
                  ),
                )
              : Row(
                  children: _buildReserverRows(context),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildReserverRows(BuildContext context) {
    return room['reservationInquirers'].map<Widget>((reserverId) {
      if (userProfiles.containsKey(reserverId)) {
        var reserverProfile = userProfiles[reserverId];
        var profilePicture = profilePic[reserverId];
        String fullName =
            '${reserverProfile['firstName']} ${reserverProfile['lastName']}';
        String profilePictureUrl = profilePicture ?? '';

        return GestureDetector(
          onTap: () {
            _showReserverDetails(context, fullName, reserverProfile, profilePictureUrl);
          },
          child: Container(
            height: 63,
            width: 100,
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(0.0),
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
                      fontFamily: 'GeistSans',
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
        fetchUserProfile(reserverId);
        return Container(
          height: 63,
          width: 100,
          margin: EdgeInsets.symmetric(horizontal: 10),
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
                    fontFamily: 'GeistSans',
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

  void _showReserverDetails(BuildContext context, String fullName, Map<String, dynamic> profile, String profilePictureUrl) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Reserver Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
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
                        : AssetImage('assets/images/profile.png'),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Name: $fullName'),
                const SizedBox(height: 4),
                Text('Gender: ${profile['gender']}'),
                const SizedBox(height: 4),
                Text('Phone: ${profile['contactDetails']['phone']}'),
                const SizedBox(height: 4),
                Text('Address: ${profile['contactDetails']['address']}'),
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
  }
}
