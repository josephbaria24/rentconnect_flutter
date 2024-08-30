import 'package:flutter/material.dart';
import 'package:rentcon/dbHelper/mongodb.dart';
import 'package:rentcon/display.dart';
import 'package:rentcon/insert.dart';
import 'package:rentcon/insertListing.dart';
import 'package:rentcon/pages/index.dart';
import 'package:rentcon/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: IndexPage(),
      routes: {
        '/login':(context) => const LoginPage(),
      },
    );
  }
}
