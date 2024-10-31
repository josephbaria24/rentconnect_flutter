// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartSample2 extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyOccupancyData;
  const LineChartSample2({super.key, required this.monthlyOccupancyData});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color.fromARGB(255, 21, 57, 218),
    const Color.fromARGB(255, 1, 255, 255),
  ];

  int selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> getCompleteMonthlyData() {
    List<Map<String, dynamic>> completeData = [];

    for (int i = 0; i < 12; i++) {
      final monthDate = DateTime(selectedYear, i + 1);
      final monthName = DateFormat('MMMM yyyy').format(monthDate);
      final existingData = widget.monthlyOccupancyData.firstWhere(
        (data) => data['monthName'] == monthName,
        orElse: () => {'occupancyCount': 0},
      );

      completeData.add({
        'monthName': monthName,
        'occupancyCount': existingData['occupancyCount'] ?? 0,
      });
    }

    return completeData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                // Inside your widget
                    Row(
                      children: [
                        const Text(
                          "Overall occupancy rate",
                          style: TextStyle(
                            fontFamily: 'geistsans',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text("Occupancy Data"),
                                  content: const Text(
                                    "This data is gathered from all users of this app who have occupied a room. "
                                    "It provides insights into the overall occupancy rate across various properties. "
                                    "Use this information to make informed decisions regarding your property management.",
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Dismiss the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.help_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Select Year:', style: TextStyle(
                                      fontFamily: "geistsans",
                                      fontWeight: FontWeight.w400
                                    ),),
                                    const SizedBox(width: 5),
                      DropdownButton<int>(
                        icon: Icon(Icons.arrow_drop_down_rounded),
                        value: selectedYear,
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString(),style: TextStyle(
                        fontFamily: "geistsans",
                        fontWeight: FontWeight.w600
                      ),),
                          );
                        }),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                        },
                      ),
                      ],
                    ),
            
              ],
            ),
            
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 10,
              left: 8,
              top: 5,
              bottom: 0,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontFamily: 'geistsans',
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    final completeData = getCompleteMonthlyData();
    final index = value.toInt();
    if (index >= 0 && index < completeData.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(completeData[index]['monthName'].substring(0, 3), style: style),
      );
    }
    return const Text('');
  }

  List<FlSpot> getSpots() {
    final completeData = getCompleteMonthlyData();
    return completeData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data['occupancyCount'].toDouble());
    }).toList();
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(29, 106, 107, 107),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color.fromARGB(29, 106, 107, 107),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value * 1).toInt()}',
                style: const TextStyle(
                  fontFamily: 'geistsans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
            reservedSize: 20,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color.fromARGB(150, 55, 67, 77)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: getCompleteMonthlyData()
          .map((d) => d['occupancyCount'])
          .reduce((a, b) => a > b ? a : b)
          .toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: getSpots(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
