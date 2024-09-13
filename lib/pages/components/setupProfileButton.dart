import 'package:flutter/material.dart';

class Setupprofilebutton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 69, 192, 110),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Setup your profile now!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white, // You can set the color to white for visibility
          ),
        ),
      ),
    );
  }
}
