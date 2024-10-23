import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For Cupertino Dialogs
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AccountSettings extends StatefulWidget {
  final String token;

  const AccountSettings({required this.token, Key? key}) : super(key: key);

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late String email;
  late String userId;
  String? _currentPassword;
  String? _newPassword;
  bool obscure = true;
  final ThemeController _themeController = Get.find<ThemeController>();

  // Add a state variable to manage the selected tab
  String _selectedTab = 'account';

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown userId';
  }

  Future<void> _updateEmail(String newEmail) async {
    final url = Uri.parse('http://192.168.1.4:3000/updateUserInfo');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'email': newEmail,
        }),
      );
      if (response.statusCode == 200) {
        Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Success',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Updated email successfully!', // Customize message text color if needed
        ),
      );
        setState(() {
          email = newEmail; // Update the displayed email
        });
      } else {
        Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Failed',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Failed to update email', // Customize message text color if needed
        ),
      );
      }
    } catch (error) {
      Get.snackbar(
        'Error', 'Error updating email!',duration: Duration(milliseconds: 1500)
      );
    }
  }

  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    final url = Uri.parse('http://192.168.1.4:3000/updatePassword');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) {
       Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Success',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Password updated successfully!', // Customize message text color if needed
        ),
      );
        
        // Optionally, log the user out or clear the passwords
      } else {
        Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Failed',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Failed to update password.', // Customize message text color if needed
        ),
      );
      }
    } catch (error) {
      Get.snackbar('Error','Error updating password!',duration: Duration(milliseconds: 1500)
            );
    }
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Execute the confirm action (update email or password)
              },
            ),
          ],
        );
      },
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Account Settings',
        style: TextStyle(
          fontFamily: 'GeistSans',
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12.0),
          child: SizedBox(
            height: 40,  // Set a specific height for the button
            width: 40,   // Set a specific width to make it a square button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Transparent background to simulate outline
                side: BorderSide(
                  color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Outline color
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
                color: _themeController.isDarkMode.value ? Colors.white : Colors.black, // Icon color based on theme
                size: 16, // Icon size
              ),
            ),
          ),
        ),
    ),
    resizeToAvoidBottomInset: true, // This helps to avoid overflow when keyboard appears
    body: SingleChildScrollView( // Wrap the body in a scroll view
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ShadTabs<String>(
            value: _selectedTab, // Use the selected tab state variable here
            onChanged: (newTab) {
              setState(() {
                _selectedTab = newTab; // Update the selected tab when the user changes tabs
              });
            },
            tabBarConstraints: const BoxConstraints(maxWidth: 400),
            contentConstraints: const BoxConstraints(maxWidth: 400),
            tabs: [
              ShadTab(
                value: 'account',
                child: const Text('Email'),
                content: ShadCard(
                  backgroundColor: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 255, 255, 255),
                  title: Text(
                    'Email',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  description: const Text(
                    "Make changes to your account here. Click save when you're done.",
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        cursorColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        prefix: const Icon(Icons.mail_outlined),
                        label: Text(
                          'Email',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        initialValue: '$email',
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.white
                              : Colors.black, // Set input text color
                        ),
                      ),
                      const SizedBox(height: 8),
                      ShadButton(
                        backgroundColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : const Color.fromARGB(255, 0, 1, 40),
                        child: Text(
                          'Update Email',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? Colors.black
                                : const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        onPressed: () => _showConfirmationDialog(
                          title: 'Confirm Email Update',
                          content: 'Are you sure you want to update your email?',
                          onConfirm: () => _updateEmail(email),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ShadTab(
                value: 'password',
                child: const Text('Password'),
                content: ShadCard(
                  backgroundColor: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 255, 255, 255),
                  title: Text(
                    'Password',
                    style: TextStyle(
                      color: _themeController.isDarkMode.value
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  description: const Text(
                    "Change your password here. After saving, you'll be logged out.",
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        cursorColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        label: Text(
                          'Current password',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        obscureText: obscure,
                        prefix: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: ShadImage.square(size: 16, LucideIcons.lock),
                        ),
                        suffix: ShadButton(
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.zero,
                          decoration: const ShadDecoration(
                            secondaryBorder: ShadBorder.none,
                            secondaryFocusedBorder: ShadBorder.none,
                          ),
                          icon: ShadImage.square(
                            size: 16,
                            obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                          ),
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.white
                              : Colors.black, // Set input text color
                        ),
                        onChanged: (value) {
                          _currentPassword = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      ShadInputFormField(
                        cursorColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        label: Text(
                          'New password',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? Colors.white
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        obscureText: obscure,
                        style: TextStyle(
                          color: _themeController.isDarkMode.value
                              ? Colors.white
                              : Colors.black, // Set input text color
                        ),
                        onChanged: (value) {
                          _newPassword = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      ShadButton(
                        backgroundColor: _themeController.isDarkMode.value
                            ? Colors.white
                            : const Color.fromARGB(255, 0, 1, 40),
                        child: Text(
                          'Update Password',
                          style: TextStyle(
                            color: _themeController.isDarkMode.value
                                ? Colors.black
                                : const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        onPressed: () => _showConfirmationDialog(
                          title: 'Confirm Password Update',
                          content: 'Are you sure you want to update your password?',
                          onConfirm: () => _updatePassword(_currentPassword!, _newPassword!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}