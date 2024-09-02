import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/dbHelper/mongodb.dart';
import 'package:rentcon/display.dart';
import 'package:rentcon/insert.dart';
import 'package:rentcon/insertListing.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/pages/index.dart';
import 'package:rentcon/pages/landlords/addListing.dart';
import 'package:rentcon/pages/login.dart';
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

  const MyApp({
    this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if token is null or expired
    bool isAuthenticated = token != null && !JwtDecoder.isExpired(token!);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: isAuthenticated ? NavigationMenu(token: token!) : IndexPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/storeProperty': (context) => PropertyInsertPage(),
      },
    );
  }
}













// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await MongoDatabase.connect();
//   runApp(MyApp(token: prefs.getString('token'),));
// }

// class MyApp extends StatelessWidget {

//   final token;

//   const MyApp({
//     @required this.token,
//     Key? key,
//   }): super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(fontFamily: 'Poppins'),
//       home: (JwtDecoder.isExpired(token) == false) ?NavigationMenu(token: token):LoginPage(),
//       routes: {
//         '/login':(context) => LoginPage(),
//         '/storeProperty': (context) => PropertyInsertPage(),
//       },
//     );
//   }
// }
