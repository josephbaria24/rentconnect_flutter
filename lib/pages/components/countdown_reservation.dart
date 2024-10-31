import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rentcon/theme_controller.dart';

class RemainingTimeWidget extends StatefulWidget {
  final DateTime approvalDate;
  final int reservationDuration; // duration in days

  RemainingTimeWidget({required this.approvalDate, required this.reservationDuration});

  @override
  _RemainingTimeWidgetState createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends State<RemainingTimeWidget> {
  Duration remainingTime = Duration.zero;
  late DateTime endDate;
  Timer? _timer;
  final ThemeController _themeController = Get.find<ThemeController>();

  // For testing, set a lower speed factor to slow down progress
  final int speedFactor = 1; // Reduced to 1 second for smoother progress

  @override
  void initState() {
    super.initState();
    endDate = widget.approvalDate.add(Duration(days: widget.reservationDuration));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          remainingTime = endDate.difference(now) - Duration(seconds: speedFactor);
          if (remainingTime.isNegative) {
            _timer?.cancel();
            remainingTime = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = remainingTime.inDays;
    final hours = remainingTime.inHours % 24;
    final totalSeconds = widget.reservationDuration * 24 * 3600; // Total seconds for the duration
    final remainingSeconds = remainingTime.inSeconds;

    // Ensure remainingSeconds is not negative for percentage calculation
    final percent = remainingSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    // Calculate the threshold for 0.5% of total time
    final threshold = totalSeconds * 0.005; // 0.5%

    // Adjust percentage to reflect the gap if less than 0.5% has passed
    final adjustedPercent = remainingSeconds < threshold ? 0.0 : percent;

    return Tooltip(
      waitDuration: Duration(microseconds: 0),
      message: 'This is the remaining time for you to occupy the room.',
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 69, 70, 83) : Colors.black,
        ),
        child: CircularPercentIndicator(
          // animation: true,
          // animationDuration: 1000,
          
          radius: 34.0,
          lineWidth: 9.0,
          percent: adjustedPercent.clamp(0.0, 1.0), // Ensure percent stays within 0 to 1
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: const Color.fromARGB(255, 41, 41, 41),
          progressColor: _themeController.isDarkMode.value
              ? const Color.fromARGB(255, 248, 207, 24)
              : const Color.fromARGB(255, 248, 207, 24),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${days}d',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.white,
                ),
              ),
              Text(
                '${hours}h',
                style: TextStyle(
                  fontSize: 14,
                  color: _themeController.isDarkMode.value ? Colors.white70 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
