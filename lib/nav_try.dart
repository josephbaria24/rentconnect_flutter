import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavTry extends StatefulWidget {
  const NavTry({super.key});

  @override
  State<NavTry> createState() => _NavTryState();
}

class _NavTryState extends State<NavTry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            color: Colors.white,
            backgroundColor: Colors.black,
            rippleColor: Colors.grey,
            hoverColor: Colors.grey,
            iconSize: 24,
            haptic: true,
            activeColor: const Color.fromARGB(255, 32, 216, 170),
            tabBackgroundColor: const Color.fromARGB(66, 32, 216, 170),
            gap: 8,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            tabs: [
              GButton(
                icon: Icons.home_filled,
                text: 'Home',),
              GButton(icon: Icons.favorite_border,
              text: 'Saved',),
              GButton(icon: Icons.pie_chart_outline,
              text: 'Trends',),
              GButton(icon: Icons.message_outlined,
              text: 'Inbox',),
          
              GButton(icon: Icons.person_2_outlined,
              text: "profile",),
              ]
            ),
        ),
      )
    );
  }
}