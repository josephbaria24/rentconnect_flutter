import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPreferences(); // Load the saved theme on initialization
  }

  Future<void> toggleTheme(bool isDark) async {
    isDarkMode.value = isDark;
    Get.changeTheme(isDark ? ThemeData.dark() : ThemeData.light()); // Apply theme immediately
    await _saveThemeToPreferences(isDark); // Save theme preference
  }

  Future<void> _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDarkMode') ?? false;
    isDarkMode.value = isDark;
    Get.changeTheme(isDark ? ThemeData.dark() : ThemeData.light());
  }

  Future<void> _saveThemeToPreferences(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }
}
