import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorController extends GetxController {
  Rx<Color> accentColor = Colors.blue.obs; // Default color is blue
  Rx<MaterialColor> materialAccentColor = createMaterialColor(Colors.blue).obs; // Initialize with a MaterialColor

  @override
  void onInit() {
    super.onInit();
    _loadColorFromPreferences(); // Load the saved color on initialization
  }

  Future<void> changeAccentColor(Color newColor) async {
    accentColor.value = newColor; // Set the new color
    materialAccentColor.value = createMaterialColor(newColor); // Convert Color to MaterialColor
    await _saveColorToPreferences(newColor); // Save selected color
  }

  Future<void> _loadColorFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('accentColor') ?? Colors.blue.value;
    accentColor.value = Color(colorValue); // Load color as Color
    materialAccentColor.value = createMaterialColor(accentColor.value); // Load MaterialColor as well
  }

  Future<void> _saveColorToPreferences(Color newColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('accentColor', newColor.value); // Save color as int
  }

  // Utility function to create MaterialColor from Color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
