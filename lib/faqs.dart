import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart'; // Adjust the import according to your file structure

class Faqs extends StatelessWidget {
  const Faqs({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? const Color(0xFF121212) // Dark background
          : Colors.white, // Light background
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontFamily: 'geistsans',
            fontSize: 18,
            color: themeController.isDarkMode.value ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: themeController.isDarkMode.value
            ? const Color.fromARGB(0, 30, 30, 30) // Dark AppBar
            : const Color.fromARGB(0, 33, 149, 243), // Light AppBar
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
                  width: 0.90, // Outline width
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                elevation: 0, // Remove elevation to get the outline effect
                padding: EdgeInsets.all(0), // Remove any padding to center the icon
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),

          
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFaqItem(
              context,
              themeController,
              question: "What is RentConnect?",
              answer: "RentConnect is a platform that connects landlords and occupants to simplify property renting.",
            ),
            const SizedBox(height: 10),
            _buildFaqItem(
              context,
              themeController,
              question: "How do I create an account?",
              answer: "You can create an account by downloading the app and following the registration process.",
            ),
            const SizedBox(height: 10),
            _buildFaqItem(
              context,
              themeController,
              question: "What should I do if I forget my password?",
              answer: "You can reset your password by clicking the 'Forgot Password' link on the login screen.",
            ),
            // Add more FAQs here...
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, ThemeController themeController, {
    required String question,
    required String answer,
  }) {
    return Card(
      color: themeController.isDarkMode.value ? Colors.grey[850] : Colors.white, // Background color of the card
      elevation: 4, // Shadow for the card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                color: themeController.isDarkMode.value ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
