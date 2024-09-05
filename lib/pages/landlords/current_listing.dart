import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/profile.dart';

class CurrentListingPage extends StatefulWidget {
  final token;
  const CurrentListingPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CurrentListingPage> createState() => _CurrentListingPageState();
}

class _CurrentListingPageState extends State<CurrentListingPage> {
  late String userId;
late String email;
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    getPropertyList(userId);
    
  }

void getPropertyList(userId) async{
        var regBody = {
        "userId":userId,
       
      };

      var response = await http.post(Uri.parse(getProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      var jsonResponse = jsonDecode(response.body);
      items = jsonResponse['success'];

      setState(() {
        
      });

}
  // void getPropertyList(String userId) async {
  //   try {
  //     final uri = Uri.parse('$getUserPropertyList?userId=$userId');
  //     var response = await http.post(
  //       uri,
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     if (response.statusCode == 200) {
  //       var jsonResponse = jsonDecode(response.body);
  //       if (jsonResponse['success'] != null) {
  //         setState(() {
  //           items = jsonResponse['success'];
  //         });
  //       } else {
  //         print("Error: ${jsonResponse['error']}");
  //       }
  //     } else {
  //       print("Error: ${response.statusCode}");
  //       print("Response Body: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error fetching property list: $e");
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 252, 242, 1),
        title: Text('Property Listings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationMenu(token: widget.token),
              ),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 252, 242, 1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Icon(Icons.list, size: 30.0),
                  backgroundColor: Colors.white,
                  radius: 30.0,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Your Listings $email',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${items?.length ?? 0} Properties',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          ),
Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: items == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items!.length,
              itemBuilder: (context, index) {
                final item = items![index];
                final photoUrl = item['photo'] != null && item['photo'].isNotEmpty
                  ? (item['photo'].startsWith('http') 
                      ? item['photo'] 
                      : '$url${item['photo']}')
                  : 'https://via.placeholder.com/150';  // Fallback URL


                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display property image
                      Image.network(
                        photoUrl,
                        height: 150.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display property description
                            Text(
                              item['description'] ?? 'No Description',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            // Display property address
                            Text(
                              item['address'] ?? 'No Address',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5.0),
                            // Display property price
                            Text(
                              'Price: \$${item['price']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            // Display number of rooms
                            Text(
                              'Rooms: ${item['numberOfRooms']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5.0),
                            // Display amenities
                            Text(
                              'Amenities: ${item['amenities']?.join(', ') ?? 'None'}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5.0),
                            // Display status
                            Text(
                              'Status: ${item['status']}',
                              style: TextStyle(
                                color: item['status'] == 'available'
                                    ? Colors.green
                                    : item['status'] == 'reserved'
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    ),
  ),
),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyInsertPage(token: widget.token),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}