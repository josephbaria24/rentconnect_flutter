import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/theme_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';
import 'toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false; // New variable to track login status
  late SharedPreferences prefs;
  final themeController = Get.find<ThemeController>();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    initSharedPref();
    fToast = FToast();
    fToast.init(context);
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }



void loginUser() async {
  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
    setState(() {
      _isLoggingIn = true; // Start loading state
    });

    var reqBody = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      // Check for internet connection
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        showErrorDialog('No internet connection. Please check your connection.');
        return;
      }

      // Make the login request
      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.body.isEmpty) {
        print("Received an empty response from the server.");
        showErrorDialog('No response from the server.');
        return;
      }

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        var myToken = jsonResponse['token'];

        // Clear any old session data
        await prefs.clear();

        // Store the new token
        prefs.setString('token', myToken);

        // Reset the login form
        emailController.clear();
        passwordController.clear();

        // Navigate to the main app screen
        ToastNotification(fToast).success('Login successful!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationMenu(token: myToken)),
          (route) => false,  // Clear the backstack to avoid returning to login
        );
      } else {
        // Show Cupertino dialog for invalid password or other errors
        showErrorDialog(jsonResponse['error'] ?? 'Login failed.');
      }
    } catch (error) {
      showErrorDialog('Failed to connect to the server.');
    } finally {
      setState(() {
        _isLoggingIn = false; // Stop loading state
      });
    }
  } else {
    // Show Cupertino dialog if fields are empty
    showErrorDialog('Email and password cannot be empty.');
  }
}

// Method to show error dialog
void showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromRGBO(252, 252, 252, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/icons/login.svg', height: 100),
            Text(
              'Login',
              style: TextStyle(
                fontFamily: 'GeistSans',
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Color.fromRGBO(5, 5, 5, 1),
              ),
            ),
            const SizedBox(height: 40.0),
            ShadInput(
              cursorColor: Colors.black,
              style: TextStyle(
                color: themeController.isDarkMode.value ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
              ),
              controller: emailController,
              placeholder: const Text('Email'),
              keyboardType: TextInputType.emailAddress,
              prefix: const Padding(
                padding: EdgeInsets.all(3.0),
                child: ShadImage.square(size: 16, LucideIcons.mail, color: Color.fromARGB(255, 25, 22, 32)),
              ),
            ),
            SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: TextStyle(
                color: themeController.isDarkMode.value ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
              ),
              controller: passwordController,
              obscureText: _obscurePassword,
              placeholder: const Text('Password'),
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(size: 16, LucideIcons.lock, color: Color.fromARGB(255, 25, 22, 32)),
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
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            const SizedBox(height: 40.0),
            ShadButton(
              backgroundColor: Color.fromARGB(255, 10, 0, 40),
              height: 40,
              width: 150,
              onPressed: _isLoggingIn ? null : loginUser,
              child: _isLoggingIn
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Logging in...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : const Text('Login', style: TextStyle(fontFamily: 'GeistSans', color: Colors.white)),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontFamily: 'GeistSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'GeistSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Color.fromRGBO(25, 22, 32, 1),
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
