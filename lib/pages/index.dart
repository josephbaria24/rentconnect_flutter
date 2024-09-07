import 'package:flutter/material.dart';
import 'login.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  // List of strings to display on slide
  final List<String> descriptions = [
    'A place where you can seamlessly connect\nwith your ideal rental property and list property.',
    'Control your smart home devices and enjoy\nhassle-free management.',
    'Find your dream property and stay connected\nwith RentConnect services.',
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/findinghouse.jpg', // Replace with your top background image
              height: 500.0, // Adjust the height accordingly
              fit: BoxFit.cover, // Ensure it covers the top area
            ),
          ),
          Positioned.fill(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 420), // Space to push content below the background image
                Expanded(
                  child: Stack(
                    children: [
                      // Dark green curved background at the bottom
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 8, 34, 28), // Dark green background
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                
                          children: [
                            Text('RentConnect'
                            ),
                            const SizedBox(height: 40),

                            // Slider for text content
                            SizedBox(
                              height: 120, // Set the height of the PageView container
                              child: PageView.builder(
                                itemCount: descriptions.length, // Number of pages to slide through
                                onPageChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        descriptions[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15.0,
                                          color: Colors.white70, // Lighter white text
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                // Handle Discover button press
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 115, 212, 77), // Green button
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Let\'s Get Started',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                    color: Colors.white70, // Default color for the first part of the text
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Sign in',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.0,
                                        color: Colors.green, // Your desired color for "Sign in"
                                        decoration: TextDecoration.underline, // Underline for emphasis
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
