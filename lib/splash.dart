import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentcon/pages/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //_navigatetoindex();
  }

  _navigatetoindex() async {
    await Future.delayed(Duration(milliseconds: 1000), () {});
    Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 130,width: 130,
              child: Lottie.asset('assets/icons/splash.json')),
              SizedBox(height: 20,),
            Container(
              child: Text(
                'RentConnect',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'GeistSans',
                  fontSize: 18,
            
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}