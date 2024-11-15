import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login.dart';
import 'signup.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<String> descriptions = [
    'A place where you can seamlessly connect\nwith your ideal rental property and list property.',
    'Find your dream property and stay connected\nwith RentConnect services.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/findinghouse.jpg',
                  height: 500.0,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 500.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                )
              ],
            ),
          ),
          
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            child: Text(
              'RentConnect',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'manrope',
                fontWeight: FontWeight.w800,
                fontSize: 37.0,
                color: Colors.white.withOpacity(1),
              ),
            ),
          ),

          Positioned.fill(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 450),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 253, 253, 253),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: Image.asset('assets/icons/ren.png'),
                                ),
                                Text(
                                  'RentConnect',
                                  style: TextStyle(
                                    fontFamily: 'manrope',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Animated Text Kit for descriptions
                            SizedBox(
                              height: 60,
                              child: AnimatedTextKit(
                                repeatForever: true,
                                pause: const Duration(seconds: 1),
                                animatedTexts: descriptions.map((text) {
                                  return TypewriterAnimatedText(
                                    text,
                                    textAlign: TextAlign.center,
                                    textStyle: const TextStyle(
                                      fontFamily: 'manrope',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                      color: Color.fromARGB(253, 0, 0, 0),
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  );
                                }).toList(),
                              ),
                            ),

                            const Spacer(),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 6, 17),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(400, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontFamily: 'manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(400, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 1, 25, 48),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontFamily: 'manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: Color.fromARGB(255, 14, 14, 14),
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
