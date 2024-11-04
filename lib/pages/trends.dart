import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/charts/lineChart.dart';
import 'package:rentcon/pages/charts/propertyViews.dart';
import 'package:rentcon/theme_controller.dart';

class TrendPage extends StatefulWidget {
  final String token;

  TrendPage({required this.token, Key? key}) : super(key: key);

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  late String email;
  late String userId;
  final themeController = Get.find<ThemeController>();
  late List<Map<String, dynamic>> monthlyOccupancyData = [];
  final ThemeController _themeController = Get.find<ThemeController>();
  String userRole = '';
  String profileStatus = 'none'; // Default value
  List<Map<String, String>> propertyList = []; // State variable to hold property IDs with indices

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    fetchMonthlyOccupancyData(); // Fetch data on init
    getPropertyList(userId);
    fetchUserProfileStatus();
  }

  Future<void> getPropertyList(String userId) async {
    try {
      var regBody = {"userId": userId};
      var response = await http.post(
        Uri.parse(getProperty),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> properties = jsonResponse['success'] ?? [];
        print("Response Body: ${properties}");
        // Extract property IDs and their indices from response and update state
        setState(() {
          propertyList = properties.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> property = entry.value;
            return {
              'index': index.toString(),
              'id': property['_id'].toString(),
            };
          }).toList();
        });
      } else {
        print("Error: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching property list: $e");
    }
  }

  Future<void> fetchMonthlyOccupancyData() async {
    final response = await http.get(Uri.parse("https://rentconnect-backend-nodejs.onrender.com/trends/monthly-occupancy"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['monthlyOccupancyData'];
      setState(() {
        monthlyOccupancyData = data.map((item) {
          final String monthString = item['month'];
          final int year = int.parse(monthString.split('-')[0]);
          final int month = int.parse(monthString.split('-')[1]);
          final occupancyCount = item['occupancyCount'] ?? 0;

          // Format month and year into a readable format
          final formattedDate = DateFormat('MMMM yyyy').format(DateTime(year, month));

          return {
            'monthName': formattedDate,
            'occupancyCount': occupancyCount,
          };
        }).toList();
      });
    } else {
      print("Failed to load monthly occupancy data");
    }
  }

  Future<void> fetchUserProfileStatus() async {
    final url = Uri.parse('https://rentconnect-backend-nodejs.onrender.com/profile/checkProfileCompletion/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        setState(() {
          profileStatus = jsonMap['profileStatus'] ?? 'none';
          userRole = jsonMap['userRole'] ?? 'none';
        });
      } else {
        print('Failed to fetch profile status');
      }
    } catch (error) {
      print('Error fetching profile status: $error');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: themeController.isDarkMode.value
        ? Color.fromRGBO(28, 29, 34, 1)
        : const Color.fromARGB(255, 255, 255, 255),
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          scrolledUnderElevation: 0,
          floating: true,
          snap: true, // If you want the AppBar to snap into view when scrolling up
          backgroundColor: themeController.isDarkMode.value
              ? Color.fromRGBO(28, 29, 34, 1)
              : const Color.fromARGB(255, 255, 255, 255),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Trends',
              style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 22,
          fontWeight: FontWeight.w700,
                color: _themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text(
                    'General Data Visualization',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? Colors.black
                          : Colors.white,
                      fontFamily: 'manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.6),
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 7, 7, 8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: LineChartSample2(
                      monthlyOccupancyData: monthlyOccupancyData,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Divider(thickness: 1, indent: 5, endIndent: 5),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text(
                    'Your Account Data Visualization',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? Colors.black
                          : Colors.white,
                      fontFamily: 'manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                if (userRole == 'landlord' && profileStatus == 'approved')
                  Column(
                    children: [
                      Text(
                        "The chart below displays how many users have viewed your listed property.",
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? const Color.fromARGB(113, 255, 255, 255)
                              : Colors.black87,
                          fontFamily: 'manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ...propertyList.map((property) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3.0, vertical: 10),
                            child: PropertyDetailsBox(
                              propertyId: property['id'],
                              propertyIndex:
                                  int.parse(property['index']!), // Convert index back to int
                            ),
                          ))
                          .toList(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}
