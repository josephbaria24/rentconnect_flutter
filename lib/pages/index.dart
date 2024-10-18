import 'package:flutter/material.dart';
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

  

  int currentIndex = 0;

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

          // Background RentConnect text
          Positioned(
            top: 200, // Adjust as needed
            left: 20,
            right: 20,
            child: Text(
              'RENTCONNECT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeistSans',
                fontWeight: FontWeight.w700,
                fontSize: 37.0, // Adjust font size
                color: const Color.fromARGB(255, 255, 255, 255)
                    .withOpacity(1), // Semi-transparent background effect
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
                                Text('RentConnect', style: TextStyle(
                                  fontFamily: 'geistsans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17
                                ),),
                              ],
                            ),
                            
                            SizedBox(
                              height: 100,
                              
                              child: PageView.builder(
                                itemCount: descriptions.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        
                                        const SizedBox(
                                            height: 2.0), // Space between icon and text
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              descriptions[index],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontFamily: 'GeistSans',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15.0,
                                                color: Color.fromARGB(
                                                    253, 0, 0, 0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 5.0),

                            // Page Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                descriptions.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  height: 8.0,
                                  width: currentIndex == index ? 24.0 : 8.0,
                                  decoration: BoxDecoration(
                                    color: currentIndex == index
                                        ? Colors.black
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Sign Up Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 16, 46),
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
                                  fontFamily: 'GeistSans',
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
                                  MaterialPageRoute(builder: (context) => LoginPage()),
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
                                  fontFamily: 'GeistSans',
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
