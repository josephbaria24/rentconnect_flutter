import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/dbHelper/mongodb.dart';
import 'package:rentcon/display.dart';
import 'package:rentcon/insert.dart';
import 'package:rentcon/insertListing.dart';
import 'package:rentcon/nav_try.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/index.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/login.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await MongoDatabase.connect();
  String? token = prefs.getString('token'); // Nullable token
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token; // Nullable token
  final themeController = Get.put(ThemeController());

   MyApp({
    this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if token is null or expired
    bool isAuthenticated = token != null && !JwtDecoder.isExpired(token!);

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Poppins'),
          darkTheme: ThemeData.dark(), // Set dark theme
          themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          //home: NavTry(),
          home: isAuthenticated ? NavigationMenu(token: token!) : IndexPage(),
          routes: {
            '/login': (context) => LoginPage(),
            '/current-listing': (context) => CurrentListingPage(token: token!),
          },
        ));
  }
}
