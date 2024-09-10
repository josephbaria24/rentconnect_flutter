import 'package:flutter/material.dart';
import 'package:rentcon/models/property.dart';

class PropertyDetailPage extends StatelessWidget {
  final Property property;
  final String userEmail;

  const PropertyDetailPage({required this.property, required this.userEmail, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.photo.startsWith('http')
        ? property.photo
        : 'http://192.168.1.16:3000/${property.photo}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details $userEmail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: imageUrl,
              child: Image.network(imageUrl, height: 250, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text(
              property.description,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Text(
            //   //'₱${property.price.toStringAsFixed(2)}',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: 8),
            Text('Address: ${property.address}'),
            SizedBox(height: 8),
            Text('Posted by: $userEmail'),
            SizedBox(height: 8),
            // Text('Rooms: ${property.rooms.length}'),
            // Display additional details about the property here
          ],
        ),
      ),
    );
  }
}
