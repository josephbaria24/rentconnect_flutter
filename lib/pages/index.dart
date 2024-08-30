import 'package:flutter/material.dart';
import 'login.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      body: Stack(
        children: <Widget>[
           // Background SVG Images
          Positioned(
            top: 10,
            left: -70,
            child: SvgPicture.asset(
              'assets/images/blob.svg', // Replace with your SVG asset path
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            top: 100,
            right: -100,
            child: SvgPicture.asset(
              'assets/images/blob2.svg', // Replace with your SVG asset path
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: SvgPicture.asset(
              'assets/images/blob2.svg', // Replace with your SVG asset path
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: SvgPicture.asset(
              'assets/images/blob.svg', // Replace with your SVG asset path
              width: 120,
              height: 120,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.jpg', // Replace with your logo asset path
                      height: 50.0,
                    ),
                    const SizedBox(width: 10.0), // Space between logo and text
                    const Text(
                      'RentConnect',
                      style: TextStyle(
                        fontFamily:
                            'Poppins', // Ensure this matches the family name in pubspec.yaml
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SvgPicture.asset(
                  'assets/images/indexPic.svg', // Replace with your house image asset path
                  height: 180.0,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'A place where you can seamlessly connect\nwith your ideal rental property and list property.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Handle Discover button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromRGBO(235, 94, 40, 1), // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Discover',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'or',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromRGBO(37, 36, 34, 1), // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Continue with email',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
