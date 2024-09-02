import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/landlords/analytics.dart';
import 'package:rentcon/pages/landlords/components/listingNavMenu.dart';
import 'package:rentcon/pages/landlords/inbox.dart';
import 'package:rentcon/pages/profile.dart';

class CurrentListingPage extends StatefulWidget {
  final String token;
  const CurrentListingPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CurrentListingPage> createState() => _CurrentListingPageState();
}

class _CurrentListingPageState extends State<CurrentListingPage> {
  late String email;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    // Using ?? operator to avoid null errors
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      appBar: AppBar(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      title: Text('Listing'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(token: widget.token),
            ),
          );
        },
      ),
    ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            buildImageSection(),
            SizedBox(height: 10),
            buildLocationAndTypeSection(),
            SizedBox(height: 10),
            buildDescriptionSection(),
            SizedBox(height: 10),
            buildAmenitiesSection(),
            SizedBox(height: 10),
            buildRoomsSection(),
          ],
        ),
      ),
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> PropertyInsertPage(token: widget.token,)),);
          // Add your onPressed code here!
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    // bottomNavigationBar: ListingNavigationMenu()
    );
  }

  Widget buildImageSection() {
    return Card(
      child: Column(
        children: [
          Image.network(
            'https://img.freepik.com/free-photo/3d-house-model-with-modern-architecture_23-2151004049.jpg?size=626&ext=jpg&ga=GA1.1.2008272138.1725148800&semt=ais_hybrid', // Replace with your image URL
            fit: BoxFit.cover,
          ),
          // Add dots or other indicators if needed
        ],
      ),
    );
  }

  Widget buildLocationAndTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on),
            SizedBox(width: 5),
            Text(
              'Lacao St. Barangay Maningning PPC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          'Apartment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          'Cozy apartment and boarding house listings offering convenient, comfortable spaces for modern living. Explore our selection of well-appointed, affordable accommodations.',
        ),
      ],
    );
  }

  Widget buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text('Laundry Area'),
        Text('Parking Space'),
        Text('Wifi'),
        Text('Communal Kitchen'),
      ],
    );
  }

  Widget buildRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRoomCard('Room/Unit no.1', '3,500', '4', 'Reserved'),
        SizedBox(height: 10),
        buildRoomCard('Room/Unit no.2', '5,000', '5', 'Available'),
      ],
    );
  }

  Widget buildRoomCard(String roomTitle, String price, String capacity, String status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Image.network(
              'https://img.freepik.com/free-photo/3d-house-model-with-modern-architecture_23-2151004049.jpg?size=626&ext=jpg&ga=GA1.1.2008272138.1725148800&semt=ais_hybrid', // Replace with your image URL
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(roomTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Price: $price'),
                  Text('Capacity: $capacity'),
                  Text('Status: $status', style: TextStyle(color: status == 'Reserved' ? Colors.red : Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
