import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/theme_controller.dart';
import 'toast.dart';
import 'global_loading_indicator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/models/property.dart';
 // Make sure to import your theme controller

Future<List<Property>> getBookmarkedProperties(String token, String userId) async {
  final url = Uri.parse('http://192.168.1.16:3000/getUserBookmarks/$userId'); 

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['status'] == true) {
        final List<dynamic> properties = data['properties'];
        return properties.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookmarked properties: ${data['error'] ?? 'Unknown error'}');
      }
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to load bookmarked properties. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error loading bookmarked properties: $error');
    throw Exception('Error loading bookmarked properties: $error');
  }
}

class BookmarkPage extends StatefulWidget {
  final String token;

  const BookmarkPage({required this.token, Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<Property>> bookmarkedProperties;
  late String email;
  late String userId;
  late FToast ftoast;
  late ToastNotification toast;
  final ThemeController _themeController = Get.find<ThemeController>();


  @override
  void initState() {
    super.initState();
    ftoast = FToast();
    ftoast.init(context);
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userID';
    bookmarkedProperties = getBookmarkedProperties(widget.token, userId);
    toast = ToastNotification(ftoast);
  }

  @override
  Widget build(BuildContext context) {
    ftoast = FToast();
    ftoast.init(context);
    toast = ToastNotification(ftoast);


    return Scaffold(
      backgroundColor: _themeController.isDarkMode.value ? Color.fromARGB(255, 0, 0, 0) : Color.fromRGBO(252, 252, 252, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bookmark',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: bookmarkedProperties,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GlobalLoadingIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No bookmarked properties.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final property = snapshot.data![index];
                      final imageUrl = property.photo.startsWith('http')
                          ? property.photo
                          : 'http://192.168.1.16:3000/${property.photo}';

                      return Card(
                        color: _themeController.isDarkMode.value ? Colors.grey[850] : Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: ListTile(
                          title: Text(property.description, style: TextStyle(color: _themeController.isDarkMode.value ? Colors.white : Colors.black)),
                          subtitle: Text('${property.address}',
                            style: TextStyle(
                              color: _themeController.isDarkMode.value ? Colors.white70 : Colors.black54,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Image.network(imageUrl, width: 100, fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
