import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/pages/charts/barchart.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:fl_chart/fl_chart.dart';
 // Ensure this is the correct path for BarChartSample2

class TrendPage extends StatefulWidget {
  final String token;
  const TrendPage({required this.token, Key? key}) : super(key: key);

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
  late String email;
  final themeController = Get.find<ThemeController>();
  late List<int> sampleData; // Sample data to use for charts

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // Safely extracting 'email' from the decoded token
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';

    // Mock data, replace this with real data from your backend
    sampleData = [10, 20, 30, 40, 50];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.isDarkMode.value ? Color.fromRGBO(0, 0, 0, 1) : Colors.white,
      appBar: AppBar(
        title: Text('Trend Data for $email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Welcome $email', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Text("Pie Chart"),
                  // SizedBox(height: 200, child: buildPieChart()),

                  Text("Line Chart"),
                  SizedBox(height: 200, child: buildLineChart()),

                  // Replacing Scatter Chart with BarChartSample2
                  Text("Custom Bar Chart"),
                  SizedBox(height: 300, child: BarChartSample2()), // Integrated custom bar chart
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pie Chart Widget
  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: sampleData
            .map((data) => PieChartSectionData(
                  value: data.toDouble(),
                  title: '$data',
                ))
            .toList(),
      ),
    );
  }

  // Bar Graph Widget
  Widget buildBarGraph() {
    return BarChart(
      BarChartData(
        barGroups: sampleData
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Colors.blue,
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  // Line Chart Widget
  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: sampleData
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                .toList(),
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
