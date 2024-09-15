import 'package:flutter/material.dart';
import 'package:rentcon/pages/profileSection/personalInformation.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';

class Setupprofilebutton extends StatefulWidget {
  final String token;

  const Setupprofilebutton({required this.token, Key? key}) : super(key: key);
  @override
  State<Setupprofilebutton> createState() => _SetupprofilebuttonState();
}

class _SetupprofilebuttonState extends State<Setupprofilebutton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to PersonalInformation page when the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePageChecker(token: widget.token,),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 80, 114, 224),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Setup your profile now!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Colors.white, // Setting text color to white for visibility
            ),
          ),
        ),
      ),
    );
  }
}
