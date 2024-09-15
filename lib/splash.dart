import 'package:flutter/material.dart';
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
    await Future.delayed(Duration(milliseconds: 1800), () {});
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
            Container(height: 130,width: 100,
              child: Image.asset('assets/icons/ren.png')),
              SizedBox(height: 20,),
            Container(
              child: Text(
                'RentConnect',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
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