// inquiry_buttons.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Pending extends StatelessWidget {
  final Map<String, dynamic> inquiry;
  final String token;
  final Function(String inquiryId, String token) cancelInquiry;
  final bool isDarkMode;

  const Pending({
    Key? key,
    required this.inquiry,
    required this.token,
    required this.cancelInquiry,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (inquiry['status'] == 'pending' &&
        inquiry['requestType'] == 'reservation' &&
        inquiry['isRented'] == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Type: ${inquiry['requestType']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            onPressed: () async {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      "Cancel Inquiry",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    content: const Text("This action is irreversible. Do you want to proceed?"),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("No"),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          await cancelInquiry(inquiry['_id'], token);
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              'Cancel Inquiry',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'geistsans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }
    if (inquiry['status'] == 'pending' &&
        inquiry['requestType'] == 'rent' &&
        inquiry['isRented'] == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Type: ${inquiry['requestType']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            onPressed: () async {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      "Cancel Inquiry",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    content: const Text("This action is irreversible. Do you want to proceed?"),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("No"),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          await cancelInquiry(inquiry['_id'], token);
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              'Cancel Inquiry',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'geistsans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink(); // Return an empty widget if conditions are not met
  }
}
