import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

const Color buttonNavBgColor = Color.fromARGB(97, 13, 1, 65);
class NavTry extends StatefulWidget {
  const NavTry({super.key});

  @override
  State<NavTry> createState() => _NavTryState();
}

class _NavTryState extends State<NavTry> {

  // final List<Widget> _navItem = [
  //   Icon(Icons.home, color: const Color.fromARGB(255, 7, 7, 7)),
  //   Icon(Icons.bookmark,color: const Color.fromARGB(255, 8, 8, 8)),
  //   Icon(Icons.pie_chart,color: const Color.fromARGB(255, 7, 7, 7)),
  //   Icon(Icons.message_outlined,color: const Color.fromARGB(255, 7, 7, 7)),
  //   Icon(Icons.person_2_outlined,color: const Color.fromARGB(255, 7, 7, 7)),
  // ];

  Color bgColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(child: 
      Container(
        height: 56,
        padding: EdgeInsets.all(14),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: buttonNavBgColor.withOpacity(0.8),
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: buttonNavBgColor.withOpacity(0.3),
              offset: Offset(0, 20),
              blurRadius: 20,
            )
          ]
        ),
      )),
    );
  }
}
