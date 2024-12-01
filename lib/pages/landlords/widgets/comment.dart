import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rentcon/theme_controller.dart';

class CommentPage extends StatefulWidget {
  final String propertyId;

  CommentPage({required this.propertyId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<dynamic> _comments = [];
  bool _isLoading = true;
  String? _error;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final url = 'https://rentconnect.vercel.app/${widget.propertyId}/comments';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _comments = data; // Assuming the API returns a list of comments
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load comments: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('MMMM d, y').format(parsedDate); // Format as October 5, 2024
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(
        rating,
        (index) => Icon(Icons.star, color: Colors.orange, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Property Comments', style: TextStyle(
          fontFamily: 'manrope',
          fontSize: 17
        ),),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove any padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _comments.isEmpty
                  ? Center(child: Text('No comments available for this property.'))
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildTimelineItem(comment);
                      },
                    ),
    );
  }
  Widget _buildTimelineItem(dynamic comment) {
    final date = comment['createdAt'] != null ? _formatDate(comment['createdAt']) : 'Unknown date';
    final rating = comment['ratingValue'] ?? 0;
    final commentText = comment['comment'] ?? 'No comment provided';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              elevation: 0.5,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontSize: 12,fontFamily: 'manrope', color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    _buildStars(rating), // Display stars for the rating
                    SizedBox(height: 8),
                    Text(
                      commentText,
                      style: TextStyle(fontSize: 14, fontFamily: 'manrope'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
