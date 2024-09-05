import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/fullscreenImage.dart';
import 'package:rentcon/navigation_menu.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({required this.token, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String email;
  late String userId;
  late Future<List<Property>> propertiesFuture;
  List<String> bookmarkedPropertyIds = [];

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    propertiesFuture = fetchProperties();
     fetchUserBookmarks();
  }

  // Fetch properties from the API
  Future<List<Property>> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse(getAllProperties));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['success'];
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (error) {
      throw Exception('Failed to load properties: $error');
    }
  }




  Future<void> fetchUserBookmarks() async {
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      final response = await http.get(
        Uri.parse('https://rentconnect-backend-nodejs.onrender.com/getUserBookmarks/$userId'), // Adjust endpoint if necessary
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        // Populate the bookmarkedPropertyIds list
        bookmarkedPropertyIds = List<String>.from(jsonMap['properties'].map((property) => property['_id']));
      } else {
        throw Exception('Failed to fetch bookmarks');
      }
    } catch (error) {
      print('Error loading user bookmarks: $error');
    }
  }





  // Fetch user email from API
  Future<String> fetchUserEmail(String userId) async {
    try {
      final response = await http.get(Uri.parse('https://rentconnect-backend-nodejs.onrender.com/getUserEmail/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['email'];
      } else {
        throw Exception('Failed to load user email');
      }
    } catch (error) {
      throw Exception('Failed to load user email: $error');
    }
  }

  // Refresh function to reload the properties
  Future<void> _refreshProperties() async {
    setState(() {
      propertiesFuture = fetchProperties(); // Re-fetch properties on refresh
    });
  }


// Function to bookmark a property
  Future<void> bookmarkProperty(String propertyId) async {
    final url = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/addBookmark'); // Your API endpoint
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      if (bookmarkedPropertyIds.contains(propertyId)) {
        // If already bookmarked, remove it
        final removeUrl = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/removeBookmark'); // Adjust this endpoint if you have a remove API
        await http.post(removeUrl,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'userId': userId,
            'propertyId': propertyId,
          }));
        setState(() {
          bookmarkedPropertyIds.remove(propertyId); // Update local state
        });
        Get.snackbar('Success', 'Property removed from bookmarks!');
      } else {
        // If not bookmarked, add it
        await http.post(url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'userId': userId,
            'propertyId': propertyId,
          }));
        setState(() {
            if (bookmarkedPropertyIds.contains(propertyId)) {
              bookmarkedPropertyIds.remove(propertyId);
            } else {
              bookmarkedPropertyIds.add(propertyId);
          }
  });
      }

      // Refresh properties to reflect changes immediately
      await _refreshProperties();
    } catch (error) {
      print('Error toggling bookmark: $error');
      Get.snackbar('Error', 'Failed to toggle bookmark');
    }
  }











  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find<NavigationController>();

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.0),
            Text(
              "Welcome $email!",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            _searchField(),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProperties, // Add refresh function here
                child: FutureBuilder<List<Property>>(
                  future: propertiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No properties available.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final property = snapshot.data![index];
                          final imageUrl = property.photo.startsWith('http')
                              ? property.photo
                              : 'https://rentconnect-backend-nodejs.onrender.com/${property.photo}';

                          return FutureBuilder<String>(
                            future: fetchUserEmail(property.userId),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (userSnapshot.hasError) {
                                return Center(child: Text('Error: ${userSnapshot.error}'));
                              } else if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                                return Center(child: Text('No user email found.'));
                              } else {
                                final userEmail = userSnapshot.data!;

                                return Card(
                                  color: Color.fromRGBO(255, 252, 242, 1),
                                  elevation: 5.0,
                                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          userEmail,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FullscreenImage(
                                                    imageUrl: imageUrl,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Hero(
                                              tag: imageUrl,
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 200,
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 10,
                                            top: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                bookmarkedPropertyIds.contains(property.id) 
                                                  ? Icons.bookmark 
                                                  : Icons.bookmark_border,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                bookmarkProperty(property.id); // Call the toggle bookmark function
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          property.description,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(property.address),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '₱${property.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );


                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search field widget
  Container _searchField() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff101617).withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(15),
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/icons/search.png',
              width: 16.0,
              height: 16.0,
            ),
          ),
          suffixIcon: Container(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalDivider(
                    indent: 10,
                    endIndent: 10,
                    color: Colors.black,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/icons/filter.png',
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class Property {
  final String id;
  final String description;
  final String address;
  final double price;
  final String photo;
  final String userId;

  Property({
    required this.id,
    required this.description,
    required this.address,
    required this.price,
    required this.photo,
    required this.userId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'],
      description: json['description'],
      address: json['address'],
      price: json['price'].toDouble(),
      photo: json['photo'],
      userId: json['userId'],
    );
  }
}
