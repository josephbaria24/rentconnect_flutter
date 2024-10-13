import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RoomDetailPage extends StatefulWidget {
  final dynamic room;
  final Map<String, dynamic> userProfiles;

  RoomDetailPage({required this.room, required this.userProfiles});

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime? _selectedDueDate;
  PageController pageController = PageController();
  final ThemeController _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    super.initState();
    calculateDueDate();
  }

  // Function to calculate due date based on room data
  void calculateDueDate() {
    int selectedDay = widget.room['dueDate'] != null 
        ? DateTime.parse(widget.room['dueDate']).day 
        : 5; // Default to the 5th day

    DateTime today = DateTime.now();
    _selectedDueDate = DateTime(today.year, today.month, selectedDay);

    // If the selected day has already passed this month, move to next month
    if (today.day > selectedDay) {
      _selectedDueDate = DateTime(today.year, today.month + 1, selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> photos = [
      (widget.room['photo1'] as String?)?.toString() ?? '',
      (widget.room['photo2'] as String?)?.toString() ?? '',
      (widget.room['photo3'] as String?)?.toString() ?? '',
    ].where((photo) => photo.isNotEmpty).toList();

    bool hasOccupants = widget.room['occupantUsers'] != null && widget.room['occupantUsers'].isNotEmpty;
    bool hasReserver = widget.room['reservationInquirers'] != null && widget.room['reservationInquirers'].isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Room Details"),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Photo Carousel
            if (photos.isNotEmpty) 
              Container(
                height: 200.0,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return Image.network(photos[index], fit: BoxFit.cover);
                  },
                ),
              ),

            // Room Status
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Room Status: ${widget.room['roomStatus']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Due Date
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Next Due Date: ${_selectedDueDate != null ? _selectedDueDate.toString().split(' ')[0] : 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Occupants Information
            if (hasOccupants) Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Occupants: ${widget.room['occupantUsers'].length}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: widget.room['occupantUsers'].map<Widget>((occupant) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(widget.userProfiles[occupant]['profilePicture'] ?? ''),
                        ),
                        title: Text(widget.userProfiles[occupant]['fullName'] ?? 'Unknown'),
                        subtitle: Text(widget.userProfiles[occupant]['email'] ?? 'No email provided'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Reservation Info
            if (hasReserver) Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Reserver(s): ${widget.room['reservationInquirers'].length}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Payment Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Amount: ₱${widget.room['totalAmount'] ?? '0.00'}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Selected Month of Proof of Payment: ${widget.room['proofOfPaymentMonth'] ?? 'Not available'}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Additional Room Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Description: ${widget.room['description'] ?? 'No description available'}",
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Amenities, Prices, and Other Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Amenities: ${widget.room['amenities'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
