import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/profile.dart';

class CurrentListingPage extends StatefulWidget {
  final String token;
  const CurrentListingPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CurrentListingPage> createState() => _CurrentListingPageState();
}

class _CurrentListingPageState extends State<CurrentListingPage> {
  late String userId;
  late String email;
  List<dynamic>? items; // Ensure correct type

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id']?.toString() ?? 'unknown id';
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    getPropertyList(userId);
  }

  Future<void> getPropertyList(String userId) async {
    try {
      var regBody = {
        "userId": userId,
      };

      var response = await http.post(
        Uri.parse(getProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          items = jsonResponse['success'] ?? [];
        });
      } else {
        print("Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching property list: $e");
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      var response = await http.delete(
        Uri.parse('http://192.168.1.16:3000/deleteProperty/$propertyId'), // Adjust URL based on your delete API
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        // Refresh property list after deletion
        getPropertyList(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully')),
        );
      } else {
        print("Error deleting property: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 252, 242, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationMenu(token: widget.token, currentIndex: 4),
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
                                      // Display amenities
                                      Text(
                                        'Amenities: ${item['amenities']?.join(', ') ?? 'None'}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 5.0),
                                      // Display status
                                      Text(
                                        'Status: ${item['status'] ?? 'Unknown'}',
                                        style: TextStyle(
                                          color: item['status'] == 'available'
                                              ? Colors.green
                                              : item['status'] == 'reserved'
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      // Edit and Delete buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Edit Button
                                          IconButton(
                                            icon: Icon(Icons.edit, color: const Color.fromARGB(255, 6, 62, 107)),
                                            onPressed: () {
                                              // Navigate to edit property page
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => PropertyDetailsPage(
                                              //       token: widget.token,
                                              //       propertyId: item['_id'],
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                          ),
                                          // Delete Button
                                          IconButton(
                                            icon: ImageIcon(
                                              AssetImage('assets/icons/trash.png'),
                                              color: Colors.red,),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Delete Property"),
                                                    content: Text("Are you sure you want to delete this property?"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text("Delete"),
                                                        onPressed: () {
                                                          deleteProperty(item['_id']);
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
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
              builder: (context) => PropertyDetailsPage(token: widget.token),
            ),
          );
        },
        child: ImageIcon(
           AssetImage('assets/icons/add.png'),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
