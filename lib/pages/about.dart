import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class AboutPage extends StatefulWidget {
  final String token;
  const AboutPage({required this.token, Key? key}) : super(key: key);
  
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late String email;
  final _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    email = JwtDecoder.decode(widget.token)['email']?.toString() ?? 'Unknown email';
  }

  // Method to open Gmail with a specific recipient
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rentconnect.it@gmail.com',
      query: 'subject=Inquiry from RentConnect App',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color.fromARGB(0, 68, 137, 255),
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                  width: 0.90,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
                padding: EdgeInsets.all(0),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25),
        child: Column(
          children: [
            // Logo with Rounded Box
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 100,
                height: 100,
                color: const Color.fromARGB(0, 224, 224, 224),
                child: _themeController.isDarkMode.value ? Image.asset(
                  'assets/icons/ren2.png',
                  fit: BoxFit.cover,
                ) : Image.asset(
                  'assets/icons/ren.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App Name and Tagline
            Text(
              'RentConnect',
              style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
            Text(
              'Connecting Landlords and Occupants Seamlessly',
              style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 18,
                color: _themeController.isDarkMode.value ? const Color.fromARGB(255, 255, 255, 255) : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // About Text
            Text(
              'At RentConnect, we strive to create a reliable platform for landlords and occupants. Our aim is to facilitate seamless communication, efficient management, and enjoyable rental experiences.',
              style: TextStyle(
                fontFamily: 'manrope',
                fontSize: 16,
                color: _themeController.isDarkMode.value ? Colors.white : const Color.fromARGB(209, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Social Media Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: Icon(Icons.mail_rounded),
                  onPressed: _sendEmail, // Opens Gmail with recipient email
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
