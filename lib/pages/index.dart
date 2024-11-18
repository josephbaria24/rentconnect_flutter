// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'login.dart';
// import 'signup.dart';

// class IndexPage extends StatefulWidget {
//   const IndexPage({super.key});

//   @override
//   _IndexPageState createState() => _IndexPageState();
// }

// class _IndexPageState extends State<IndexPage> {
//   final List<String> descriptions = [
//     'A place where you can seamlessly connect\nwith your ideal rental property and list property.',
//     'Find your dream property and stay connected\nwith RentConnect services.',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   leading: Padding(
      //     padding: const EdgeInsets.only(left: 20.0),
      //     child: Row(
      //       children: [
      //         Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(13),
      //             color: const Color.fromARGB(255, 3, 3, 3),
      //           ),
      //           height: 35,
      //           alignment: Alignment.topCenter,
      //           child: Padding(
      //             padding: const EdgeInsets.all(5.0),
      //             child: Image.asset('assets/icons/ren2.png'),
      //           ),
      //         ),
      //         // Add spacing between the icon and text
      //       ],
      //     ),
      //   ),
      //   title: Row(
      //     children: [
      //       Text(
      //         'RentConnect',
      //         style: TextStyle(
      //           fontFamily: 'manrope',
      //           fontWeight: FontWeight.w600,
      //           fontSize: 17,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: <Widget>[
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Stack(
//               children: [
//                 Image.asset(
//                   'assets/icons/bg.jpg',
//                   height: 400.0,
//                   fit: BoxFit.contain,
//                 ),
//                 Container(
//                   height: 600.0,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.0),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Positioned(
//             top: 350,
//             left: 20,
//             right: 20,
//             child: RichText(
//               textAlign: TextAlign.left,
//               text: TextSpan(
//                 style: TextStyle(
//                   fontFamily: 'manrope',
//                   fontWeight: FontWeight.w700, // Enhanced emphasis
//                   fontSize: 37.0, // Slightly reduced for better readability
//                   height: 1.4, // Adjusted line height for clean spacing
//                   color: const Color.fromARGB(255, 0, 0, 0)
//                       .withOpacity(0.9), // Slight opacity for a soft effect
//                 ),
//                 children: [
//                   const TextSpan(
//                     text: 'Embrace the ',
//                   ),
//                   TextSpan(
//                     text: 'Modernity',
//                     style: TextStyle(
//                       color: const Color.fromARGB(
//                           255, 23, 211, 195), // Cyan color for "Modernity"
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Column(
//             children: <Widget>[
//               const SizedBox(height: 450),
//               Expanded(
//                 child: Stack(
//                   children: [
                    
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 10),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: Positioned(
//                               left: 10,
//                               child: Container(
//                                 height: 65,
//                                 child: AnimatedTextKit(
//                                   totalRepeatCount: 1,
//                                   repeatForever: false,
//                                   pause: const Duration(seconds: 2),
//                                   animatedTexts: descriptions.map((text) {
//                                     return TypewriterAnimatedText(
//                                       text,
//                                       textAlign: TextAlign.left,
//                                       textStyle: const TextStyle(
//                                         fontFamily: 'manrope',
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 14.0,
//                                         color:
//                                             Color.fromARGB(251, 105, 105, 105),
//                                       ),
//                                       speed: const Duration(milliseconds: 50),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20.0),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => LoginPage(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromARGB(255, 0, 6, 17),
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 14.0),
//                               minimumSize: const Size(400, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(
//                                 fontFamily: 'manrope',
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16.0,
//                                 color: Color.fromARGB(255, 255, 255, 255),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SignUpPage(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               elevation: 0,
//                               backgroundColor:
//                                   const Color.fromARGB(255, 255, 255, 255),
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 14.0),
//                               minimumSize: const Size(400, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             child: const Text(
//                               'Register',
//                               style: TextStyle(
//                                 decoration: TextDecoration.underline,
//                                 fontFamily: 'manrope',
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 16.0,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           const Spacer(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

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
            appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: const Color.fromARGB(255, 3, 3, 3),
                ),
                height: 35,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset('assets/icons/ren2.png'),
                ),
              ),
              // Add spacing between the icon and text
            ],
          ),
        ),
        title: Row(
          children: [
            Text(
              'RentConnect',
              style: TextStyle(
                fontFamily: 'manrope',
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  'assets/icons/bg.jpg',
                  height: 400.0,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 500.0,
                  decoration: BoxDecoration(
                    
                  ),
                )
              ],
            ),
          ),
          
         Positioned(
            top: 350,
            left: 20,
            right: 20,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'manrope',
                  fontWeight: FontWeight.w700, // Enhanced emphasis
                  fontSize: 37.0, // Slightly reduced for better readability
                  height: 1.2, // Adjusted line height for clean spacing
                  color: const Color.fromARGB(255, 0, 0, 0)
                      .withOpacity(0.9), // Slight opacity for a soft effect
                ),
                children: [
                  const TextSpan(
                    text: 'Embrace the ',
                  ),
                  TextSpan(
                    text: 'Modernity',
                    style: TextStyle(
                      color: const Color.fromARGB(
                          255, 23, 211, 195), // Cyan color for "Modernity"
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 435),
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
                            

                            // Animated Text Kit for descriptions
                            Padding(
                              padding: const EdgeInsets.only(right: 65.0),
                              child: SizedBox(
                                height: 60,
                                child: AnimatedTextKit(
                                  totalRepeatCount: 1,
                                  repeatForever: false,
                                  pause: const Duration(seconds: 1),
                                  animatedTexts: descriptions.map((text) {
                                    return TypewriterAnimatedText(
                                      text,
                                      textAlign: TextAlign.left,
                                      textStyle: const TextStyle(
                                        fontFamily: 'manrope',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.0,
                                        color: Color.fromARGB(252, 94, 94, 94),
                                      ),
                                      speed: const Duration(milliseconds: 50),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const Spacer(),

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
                                    const Color.fromARGB(255, 0, 6, 17),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(400, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
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
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(400, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Sign up',
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