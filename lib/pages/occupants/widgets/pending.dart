// inquiry_buttons.dart

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:timeline_tile/timeline_tile.dart';

class Pending extends StatefulWidget {
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
  State<Pending> createState() => _PendingState();
}

class _PendingState extends State<Pending> {


    final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    
if (widget.inquiry['status'] == 'pending' &&
    widget.inquiry['requestType'] == 'reservation' &&
    widget.inquiry['isRented'] == false) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'Request Type: ${widget.inquiry['requestType']}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20), // Add spacing before the timeline
      // Timeline using TimelineTile
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: _themeController.isDarkMode.value? Colors.white:Colors.black)
        ),
        child: Column(
          children: [
            TimelineTile(
              alignment: TimelineAlign.manual,
              beforeLineStyle: LineStyle(color: Colors.blue),
              lineXY: 0.1,
              isFirst: true,
              indicatorStyle: IndicatorStyle(
                iconStyle: IconStyle(iconData: Icons.pending_actions, color: Colors.white),
                width: 30,
                height: 30,
                color: Colors.blue,
                
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Check your email frequently for the inquiry result.',
                      style: TextStyle(color:_themeController.isDarkMode.value?Colors.white60: Colors.black54)
                    ),
                  ],
                ),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.1,
              isLast: true,
              indicatorStyle: IndicatorStyle(
                 iconStyle: IconStyle(iconData: Icons.check_circle_outline, color: Colors.white),
                width: 30,
                height: 30,
                color: Colors.grey,
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approved',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Contact the landlord immediately for the payment of reservation.',
                      style: TextStyle(color:_themeController.isDarkMode.value?Colors.white60: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                    color: widget.isDarkMode ? Colors.white : Colors.black,
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
                      await widget.cancelInquiry(widget.inquiry['_id'], widget.token);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined,color: Colors.red,),
            Text(
              'Cancel Inquiry',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'geistsans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
    if (widget.inquiry['status'] == 'pending' &&
        widget.inquiry['requestType'] == 'rent' &&
        widget.inquiry['isRented'] == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Type: ${widget.inquiry['requestType']}',
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
                        color: widget.isDarkMode ? Colors.white : Colors.black,
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
                          await widget.cancelInquiry(widget.inquiry['_id'], widget.token);
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
