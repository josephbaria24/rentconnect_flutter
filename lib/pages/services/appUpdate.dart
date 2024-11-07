import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class UpdateChecker {
  Future<void> checkForUpdates(BuildContext context) async {
    // Get the current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Fetch the latest version info from the Node.js backend
    final response = await http.get(Uri.parse('https://rentconnect.vercel.app/download/version'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String latestVersion = data['latest_version'];
      String downloadUrl = data['download_url'];
      print('Latest Version from API: $latestVersion');
      print('Current App Version: $currentVersion');
      if (latestVersion.split('+')[0] != currentVersion.split('+')[0]) {
        _showUpdateDialog(context, downloadUrl);
        print('Current context: $context');
      }
    } else {
      // Handle error if the version check fails
      print('Failed to fetch version info.');
    }
  }

  void _showUpdateDialog(BuildContext context, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,  // Prevent dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,  // Prevent back button from closing the dialog
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Reduced border radius
            ),
            title: Center(
              child: const Text(
                'Update Available',
                style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold), // Manrope font family for title
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/icons/update.json', // Replace with the path to your Lottie animation
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                Center(
                  child: const Text(
                    'A new version of the app is available. Please update to continue.',
                    style: TextStyle(fontFamily: 'Manrope'), // Manrope font family for content
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Exit the app when 'Exit' is pressed
                  Navigator.of(context).pop();
                  Future.delayed(Duration.zero, () {
                    SystemNavigator.pop(); // Close the app
                  });
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(fontFamily: 'Manrope'), // Manrope font family for button text
                ),
              ),
              TextButton(
                onPressed: () {
                  _launchURL(downloadUrl); // Launch the URL for updating
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Colors.blueAccent), // Manrope font family for button text
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
