import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'login.dart';
import 'signup.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  final List<String> descriptions = [
    'A place where you can seamlessly connect\nwith your ideal rental property and list property.',
    'Find your dream property and stay connected\nwith RentConnect services.',
  ];

  final List<String> gifAssets = [
    'assets/images/share.gif', // GIF for the first slide
    'assets/images/link.gif', // GIF for the second slide
  ];

  late final GifController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Example: Start animation or perform state changes after the initial build
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 40.0, // Adjust font size
                color: const Color.fromARGB(255, 255, 255, 255)
                    .withOpacity(1), // Semi-transparent background effect
              ),
            ),
          ),

          Positioned.fill(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 350),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 253, 253, 253),
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
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 170,
                              child: PageView.builder(
                                itemCount: descriptions.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 60,
                                          width: 60,
                                          alignment: Alignment.topCenter,
                                          child: Gif(
                                            controller: _controller,
                                            image: AssetImage(gifAssets[index]),
                                            autostart: Autostart.loop,
                                            placeholder: (context) => const Center(
                                                child: CircularProgressIndicator()),
                                            onFetchCompleted: () {
                                              _controller.reset();
                                              _controller.forward();
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 8.0), // Space between icon and text
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              descriptions[index],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
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
                                backgroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                minimumSize: const Size(400, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),

                            // Login Button
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
                                  borderRadius: BorderRadius.circular(100),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 14, 14, 14),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
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
