import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentcon/pages/profileSection/personalInformation.dart';
import 'package:rentcon/pages/profileSection/profileChecker.dart';

class Setupprofilebutton extends StatefulWidget {
  final String token;

  const Setupprofilebutton({required this.token, Key? key}) : super(key: key);
  
  @override
  State<Setupprofilebutton> createState() => _SetupprofilebuttonState();
}

class _SetupprofilebuttonState extends State<Setupprofilebutton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  Timer? _shakeTimer;
  int shakeCount = 5; // Number of shakes
  int shakeSpeed = 30; // Speed of each shake in milliseconds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: shakeSpeed),
    );

    // Shake animation using a Tween for up and down movement
    _shakeAnimation = Tween<double>(begin: 0, end: 5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ));

    // Start the timer to trigger shake every 5 seconds
    _shakeTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _startShaking(); // Start the shaking sequence
    });
  }

  void _startShaking() async {
    for (int i = 0; i < shakeCount; i++) {
      await _controller.forward(); // Move up
      await _controller.reverse(); // Move down
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _shakeAnimation.value), // Vertical shake
          child: InkWell(
            onTap: () {
              // Navigate to PersonalInformation page when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePageChecker(token: widget.token),
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 238, 0, 91),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Setup your profile now!',
                  style: TextStyle(
                    fontFamily: 'GeistSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // Increased font size for visibility
                    color: Colors.white, // Setting text color to white for visibility
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
