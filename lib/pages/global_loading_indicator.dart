import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class GlobalLoadingIndicator extends StatelessWidget {
  final double size;
  final List<Color> colors;

  GlobalLoadingIndicator({
    this.size = 50.0, 
    this.colors = const [Colors.red, Colors.green, Colors.blue], // Default colors
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballPulseSync,
          colors: colors,
          strokeWidth: 2,
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          pathBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
        ),
      ),
    );
  }
}
