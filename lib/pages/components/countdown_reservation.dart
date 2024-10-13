import 'dart:async';
import 'package:flutter/material.dart';

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
          remainingTime = endDate.difference(now);
          if (remainingTime.isNegative) {
            _timer?.cancel(); // Stop the timer if time is up
            remainingTime = Duration.zero; // Avoid negative values
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = remainingTime.inDays;
    final hours = remainingTime.inHours % 24;
    final minutes = remainingTime.inMinutes % 60;
    final seconds = remainingTime.inSeconds % 60;

    return Column(
      children: [
        Text('Remaining Time:'),
        Text('${days}d ${hours}h ${minutes}m ${seconds}s'),
      ],
    );
  }
}
