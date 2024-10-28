// room_details_tab.dart
import 'package:flutter/material.dart';

class RequestDetailsTab extends StatefulWidget {
  @override
  State<RequestDetailsTab> createState() => _RequestDetailsTabState();
}

class _RequestDetailsTabState extends State<RequestDetailsTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Room Details code here
          Text('Request Details Content'),
        ],
      ),
    );
  }
}
