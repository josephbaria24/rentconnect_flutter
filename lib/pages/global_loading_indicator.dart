import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:rentcon/theme_controller.dart';

class GlobalLoadingIndicator extends StatelessWidget {
  
  final double size;
  final List<Color> colors;
final ThemeController _themeController = Get.find<ThemeController>();
  GlobalLoadingIndicator({
    this.size = 50.0, 
    this.colors = const [ Color.fromARGB(255, 255, 0, 76), Color.fromARGB(255, 255, 0, 76), Color.fromARGB(255, 255, 0, 76)], // Default colors
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballBeat,
          colors: colors,
          strokeWidth: 2,
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          pathBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
        ),
      ),
    );
  }
}
