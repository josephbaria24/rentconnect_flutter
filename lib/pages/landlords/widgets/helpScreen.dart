import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart'; // Make sure to import Lottie package

class Helpscreen extends StatefulWidget {
  const Helpscreen({super.key});

  @override
  State<Helpscreen> createState() => _HelpscreenState();
}

class _HelpscreenState extends State<Helpscreen> {
  double _opacity = 0.0;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    // Start the animation after the screen is built
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0; // Fade in
      });
    });

    // Add listener to page controller to update current page index
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 300),
      child: Container(
        width: 300, // Set a width for the dialog
        height: 365, // Set a fixed height for the dialog
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _themeController.isDarkMode.value?const Color.fromARGB(255, 49, 48, 58): Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close button at the top right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('How to add a property?', style: TextStyle(
                  fontFamily: 'geistsans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                ),),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 20,),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  // Add your help pages here with Lottie animations
                  _buildHelpPage(
                    'Step 1',
                    'Tap the plus icon below to add your listing property.',
                    'https://lottie.host/b3331e23-31fd-44b0-a3dc-543b72b17126/CnOjuoM5mC.json', // Replace with your Lottie URL
                  ),
                  _buildHelpPage(
                    'Step 2',
                    'Fill in the details of your property, and don’t forget to upload a photo of your property along with legal documents.',
                    'https://lottie.host/96112f95-ef6a-42dd-9418-6675c714ed48/fCigDF5e7l.json', // Replace with your Lottie URL
                  ),
                  _buildHelpPage(
                    'Step 3',
                    'Once you are done with the details of your property, add the desired rooms along with the details, then press submit.',
                    'https://lottie.host/6d8926ea-f4bb-489c-9242-f83529eaa4a5/rxvFo58qGR.json', // Replace with your Lottie URL
                  ),
                  _buildHelpPage(
                    'Step 4',
                    'After submitting, it will not be directly posted to the app because it will be reviewed first by the admins. If the provided details are correct, then it will be approved and posted to the app.',
                    'https://lottie.host/af3511e7-2e55-4713-ba3e-cfaae9b272c5/9GeaqIjIe7.json', // Replace with your Lottie URL
                  ),
                ],
              ),
            ),
            SizedBox(height: 10), // Spacing between PageView and indicator
            Center(
              child: SmoothPageIndicator(
                controller: _pageController, // PageController
                count: 4, // Total number of pages
                effect: WormEffect(
                  activeDotColor: const Color.fromARGB(255, 4, 218, 189),
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpPage(String title, String description, String lottieUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lottie animation
        Lottie.network(lottieUrl, height: 70), // Display Lottie animation
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
          color: _themeController.isDarkMode.value? Colors.white:Colors.black),
        ),
        SizedBox(height: 20),
        Text(
          description,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
