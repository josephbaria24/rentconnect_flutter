// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class MonthlyViewsBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> monthlyViewsData;

//   const MonthlyViewsBarChart({Key? key, required this.monthlyViewsData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.70,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           titlesData: FlTitlesData(
//             bottomTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 38,
//               getTitlesWidget: (value, meta) {
//                 const style = TextStyle(
//                   fontFamily: 'manrope',
//                   fontWeight: FontWeight.w500,
//                   fontSize: 10,
//                 );
//                 final monthIndex = value.toInt();
//                 return Text(months[monthIndex], style: style);
//               },
//             ),
//             leftTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//               getTitlesWidget: (value, meta) {
//                 return Text(value.toInt().toString());
//               },
//             ),
//           ),
//           borderData: FlBorderData(
//             show: true,
//             border: Border.all(color: const Color(0xff37434d)),
//           ),
//           barGroups: getBarGroups(),
//           maxY: getMaxY(), // Adjust maxY to fit your data
//         ),
//       ),
//     );
//   }

//   List<BarChartGroupData> getBarGroups() {
//     return List.generate(monthlyViewsData.length, (index) {
//       final monthData = monthlyViewsData[index];
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: monthData['views'].toDouble(), // Adjust according to your data
//             color: Colors.blue,
//             width: 20,
//           ),
//         ],
//       );
//     });
//   }

//   double getMaxY() {
//     return monthlyViewsData.map((data) => data['views']).reduce((a, b) => a > b ? a : b).toDouble() + 1; // For better visualization
//   }
// }

// // List of month names
// const List<String> months = [
//   'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
// ];
