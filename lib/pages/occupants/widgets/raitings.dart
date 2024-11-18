// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'dart:convert';

import 'package:shadcn_ui/shadcn_ui.dart';

class RatingWidget extends StatefulWidget {
  final String propertyId; // Property ID to rate
  final String userId; // User ID of the person rating

  RatingWidget({
    required this.propertyId,
    required this.userId,
  });

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _ratingValue = 0; // Store the rating value
  TextEditingController _commentController = TextEditingController(); // Controller for comment input
  Map<String, dynamic>? _existingRating; // Store the existing rating details
   final ThemeController _themeController = Get.find<ThemeController>();
   late ToastNotification toastNotification;
  @override
  void initState() {
    super.initState();
    toastNotification = ToastNotification(context);
    _fetchExistingRating(); // Fetch existing rating when widget initializes
  }

  Future<void> _fetchExistingRating() async {
    final url = 'http://192.168.1.115:3000/getRating/${widget.propertyId}/${widget.userId}'; // Assuming you have a route to get a user's rating for a property

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final ratingData = json.decode(response.body);
      setState(() {
        _existingRating = ratingData; // Store the existing rating details
        if (ratingData != null) {
          _ratingValue = (ratingData['ratingValue'] is int)
              ? (ratingData['ratingValue'] as int).toDouble() // Convert to double
              : ratingData['ratingValue']; // Already a double
          _commentController.text = ratingData['comment'];
        }
      });
    } else {
     //toastNotification.error('Error fetching ratings.');
    }
  }

  Future<void> _submitRating() async {
    final url = 'http://192.168.1.115:3000/rateProperty/${widget.propertyId}';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': widget.userId,
        'ratingValue': _ratingValue,
        'comment': _commentController.text,
      }),
    );

    if (response.statusCode == 200) {
      toastNotification.success('Rating submitted successfully!');
      _fetchExistingRating(); // Refresh existing rating
    } else {
      toastNotification.error('Error submitting rating.');
    }
  }

  Future<void> _updateRating() async {
    final url = 'http://192.168.1.115:3000/updateRating/${widget.propertyId}/${_existingRating!['_id']}'; // Update rating route

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ratingValue': _ratingValue,
        'comment': _commentController.text,
      }),
    );

    if (response.statusCode == 200) {
      toastNotification.success('Rating updated successfully!.');
      _fetchExistingRating(); // Refresh existing rating
    } else {
      toastNotification.error('Error updating rating.');
    }
  }

  Future<void> _deleteRating() async {
    final url = 'http://192.168.1.115:3000/deleteRating/${widget.propertyId}/${_existingRating!['_id']}'; // Delete rating route

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      toastNotification.success('Rating deleted successfully!');
      setState(() {
        _existingRating = null; // Clear existing rating
        _ratingValue = 0; // Reset rating value
        _commentController.clear(); // Clear comment
      });
    } else {
      toastNotification.error('Error deleting rating.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _themeController.isDarkMode.value? Colors.black: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this Property',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _ratingValue ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _ratingValue = index + 1.0; // Set the rating value based on the star clicked
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 2),
            ShadInputFormField(
              cursorColor: _themeController.isDarkMode.value? Colors.white: Colors.black,
              style: TextStyle(color: _themeController.isDarkMode.value? Colors.white: Colors.black),
              controller: _commentController,
              placeholder: Text('Leave a comment'),
              label: Text('Comment',style: TextStyle(color: _themeController.isDarkMode.value? Colors.white: Colors.black),),
              minLines: 1,
              maxLines: 3,
            ),
            SizedBox(height: 10),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_existingRating != null) ...[
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _deleteRating,
                    child: Text(
                      'Delete Rating',
                      style: TextStyle(
                        fontFamily: 'manrope',
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      side: BorderSide(
                        color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                        width: 1,
                      ),
                      backgroundColor: const Color.fromARGB(0, 131, 26, 19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
                
                ElevatedButton(
                  onPressed: _existingRating != null ? _updateRating : _submitRating,
                  child: Text(
                    _existingRating != null ? 'Update Rating' : 'Submit Rating',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value ? Colors.white : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeController.isDarkMode.value ? const Color.fromARGB(255, 14, 196, 126) : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            
          ],
        ),
      ),
    );
  }
}
