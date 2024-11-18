// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:rentcon/theme_controller.dart';

class PropertyDetailsBox extends StatefulWidget {
  final String? propertyId;
  final int propertyIndex; // New parameter for property index

  PropertyDetailsBox({required this.propertyId, required this.propertyIndex, Key? key}) : super(key: key);

  @override
  State<PropertyDetailsBox> createState() => _PropertyDetailsBoxState();
}

class _PropertyDetailsBoxState extends State<PropertyDetailsBox> {


  
  Future<Map<String, int>> fetchPropertyViews(String propertyId) async {
    final String url = 'http://192.168.1.115:3000/properties/$propertyId/views';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debug print

        // Check if success is true and views is a list
        if (data['success'] == true && data['views'] is List) {
          List<dynamic> viewsData = data['views']; // Correctly access the views array
          return _groupViewsByMonth(viewsData);
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load views: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Map<String, int> _groupViewsByMonth(List<dynamic> views) {
    Map<String, int> monthlyViews = {};

    // Initialize months for January to December
    List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Set initial views to 0 for each month
    for (String month in monthNames) {
      monthlyViews[month] = 0; // Start with zero views for each month
    }

    for (var view in views) {
      final timestamp = DateTime.parse(view['timestamp']);
      final monthYear = DateFormat('MMM').format(timestamp); // Use shortened month name

      if (monthlyViews.containsKey(monthYear)) {
        monthlyViews[monthYear] = monthlyViews[monthYear]! + 1;
      }
    }

    return monthlyViews;
  }
final _themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      //margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _themeController.isDarkMode.value? const Color.fromARGB(255, 35, 36, 43): Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(34, 0, 0, 0),
            spreadRadius: 0.2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, int>>(
        future: fetchPropertyViews(widget.propertyId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(width: 8),
                Text('Loading views...'),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final monthlyViews = snapshot.data ?? {};
            final months = monthlyViews.keys.toList();
            final viewsCount = monthlyViews.values.toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property: ${widget.propertyIndex + 1}', // Increment index by 1
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                // Make the chart scrollable horizontally
                SizedBox(
                  width: double.infinity, // Set a fixed width for the chart
                  height: 150, // Set a fixed height for the chart
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AspectRatio(
                      aspectRatio: 2.1, // Adjust for width and height balance
                      child: BarChart(
                        BarChartData(
                          backgroundColor: _themeController.isDarkMode.value
                              ? const Color.fromARGB(0, 255, 193, 7)
                              : Colors.white,
                          alignment: BarChartAlignment.spaceBetween,
                          maxY: viewsCount.isNotEmpty
                              ? (viewsCount.reduce((a, b) => a > b ? a : b) + 1).toDouble()
                              : 1,
                          barGroups: List.generate(months.length, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: viewsCount[index].toDouble(),
                                  width: 15,
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 226, 253, 238), // Start color (pink)
                                      Color.fromARGB(255, 12, 228, 217), // End color (purple)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'manrope',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[value.toInt()],
                                      style: const TextStyle(fontSize: 10, fontFamily: 'manrope', fontWeight: FontWeight.w700),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      )
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
