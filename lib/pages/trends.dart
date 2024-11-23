import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/config.dart';
import 'package:rentcon/pages/charts/lineChart.dart';
import 'package:rentcon/pages/charts/propertyViews.dart';
import 'package:rentcon/pages/propertyDetailPage.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:rentcon/models/property.dart';

class TrendPage extends StatefulWidget {
  final String token;

  TrendPage({required this.token, Key? key}) : super(key: key);

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> with SingleTickerProviderStateMixin {
  late String email;
  late String userId;
  late TabController tabController;

  final themeController = Get.find<ThemeController>();
  late List<Map<String, dynamic>> monthlyOccupancyData = [];
  final ThemeController _themeController = Get.find<ThemeController>();
  String userRole = '';
  String profileStatus = 'none'; 
  List<Map<String, String>> propertyList = [];

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
    fetchMonthlyOccupancyData();
    getPropertyList(userId);
    fetchUserProfileStatus();
    tabController = TabController(length: 2, vsync: this); // Two tabs
     fetchMostViewedProperties();
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
      }
    } catch (e) {
      print("Error fetching property list: $e");
    }
  }

  Future<void> fetchMonthlyOccupancyData() async {
    final response = await http.get(Uri.parse("https://rentconnect.vercel.app/trends/monthly-occupancy"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['monthlyOccupancyData'];
      setState(() {
        monthlyOccupancyData = data.map((item) {
          final String monthString = item['month'];
          final int year = int.parse(monthString.split('-')[0]);
          final int month = int.parse(monthString.split('-')[1]);
          final occupancyCount = item['occupancyCount'] ?? 0;

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
    final url = Uri.parse('https://rentconnect.vercel.app/profile/checkProfileCompletion/$userId');
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



List<Map<String, dynamic>> mostViewedProperties = [];

Future<void> fetchMostViewedProperties() async {
  try {
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/trends/most-viewed-property'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Convert properties to list and filter out those with 0 views
        mostViewedProperties = List<Map<String, dynamic>>.from(data['properties'] ?? [])
            .where((property) => property['views'] != null && property['views'].length > 0)
            .toList();
        
        // Sort properties based on views
        mostViewedProperties.sort((a, b) {
          return b['views'].length.compareTo(a['views'].length);
        });
      });
    } else {
      print('Failed to fetch most-viewed properties: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching most-viewed properties: $e');
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ensures the body doesn't overflow when the keyboard is visible
    backgroundColor: themeController.isDarkMode.value
        ? Color.fromRGBO(28, 29, 34, 1)
        : const Color.fromARGB(255, 255, 255, 255),
    appBar: AppBar(
      backgroundColor: themeController.isDarkMode.value
          ? Color.fromRGBO(28, 29, 34, 1)
          : const Color.fromARGB(255, 255, 255, 255),
      title: Row(
        children: [
          Text(
            'Trends',
            style: TextStyle(
              fontFamily: 'manrope',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: themeController.isDarkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          Lottie.asset('assets/icons/analytics.json', height: 30, repeat: false),
        ],
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: themeController.isDarkMode.value ? Colors.white : Colors.black,
        tabs: const [
          Tab(text: 'General Data'),
          Tab(text: 'Your Data'),
        ],
      ),
    ),
    body: TabBarView(
      controller: tabController,
      children: [
        // General Data Visualization
        SingleChildScrollView(  // Wrap this in SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                if (mostViewedProperties.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Most Viewed Properties',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mostViewedProperties.length,
                          itemBuilder: (context, index) {
                            final property = mostViewedProperties[index];
                            return GestureDetector(
                              onTap: () {
                                print('Property data: ${property.toString()}');
                                final propertyObject = Property.fromJson(property);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailPage(
                                      userRole: userRole,
                                      profileStatus: profileStatus,
                                      userEmail: email,
                                      token: widget.token,
                                      property: propertyObject,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 0,
                                color: Colors.transparent,
                                margin: const EdgeInsets.only(right: 3, left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
                                          child: property['photo'] != null && property['photo'] != ''
                                              ? Image.network(
                                                  property['photo'],
                                                  width: 210,
                                                  height: 180,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                                                )
                                              : Image.asset(
                                                  'assets/images/placeholder.png',
                                                  width: 150,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          left: 8,
                                          top: 8,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset('assets/icons/tap.svg', height: 17, color: Colors.white),
                                                Text(
                                                  '${property['views'].length}',
                                                  style: TextStyle(
                                                    fontFamily: 'manrope',
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6),
                      color: themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 7, 7, 8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LineChartSample2(monthlyOccupancyData: monthlyOccupancyData),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Your Account Data Visualization
        SingleChildScrollView( // Wrap this in SingleChildScrollView too
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: userRole == 'landlord' && profileStatus == 'approved'
                ? Column(
                    children: propertyList.map((property) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: PropertyDetailsBox(
                          propertyId: property['id'],
                          propertyIndex: int.parse(property['index']!),
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text(
                      'No data available.',
                      style: TextStyle(
                        color: themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

}
