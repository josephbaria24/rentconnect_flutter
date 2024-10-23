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
  late ToastNotification toastNotification;

  @override
  void initState() {
    super.initState();
    initSharedPref();
     toastNotification = ToastNotification(context);
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
        Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Success',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Login successfully!', // Customize message text color if needed
        ),
      );
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

void _showForgotPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  bool _isSubmitting = false;

  showCupertinoDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return CupertinoAlertDialog(
            title: Text('Forgot Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Please enter your email address. We will send you a link to reset your password.'),
                SizedBox(height: 10),
                CupertinoTextField(
                  controller: emailController,
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel',
                  style: TextStyle(
                    color: themeController.isDarkMode.value ? Colors.white : Colors.black
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() {
                          _isSubmitting = true; // Show loading indicator
                        });

                        // Call your backend API to send the reset link
                        final response = await _sendPasswordResetEmail(emailController.text);

                        setState(() {
                          _isSubmitting = false; // Hide loading indicator
                        });

                        if (response) {
                          // Close the keyboard
                          FocusScope.of(context).unfocus();

                          // Close the dialog
                          Navigator.of(context).pop();
                          Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Success',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Reset password link sent to ${emailController.text}', // Customize message text color if needed
        ),
      );
                        } else {
                          Get.snackbar(
        '', // Leave title empty because we're using titleText for customization
        '', // Leave message empty because we're using messageText for customization
        duration: Duration(milliseconds: 1500),
        titleText: Text(
          'Failed',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold), // Customize the color of 'Success'
        ),
        messageText: Text(
          'Failed to send reset link', // Customize message text color if needed
        ),
      );
                        }
                      },
                child: _isSubmitting
                    ? CupertinoActivityIndicator() // Show loading indicator
                    : Text('Send'),
              ),
            ],
          );
        },
      );
    },
  );
}


Future<bool> _sendPasswordResetEmail(String email) async {
  // Replace with your actual endpoint and logic
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:3000/forgot-password'), // Update with your API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true; // Successfully sent reset link
    } else {
      return false; // Failed to send reset link
    }
  } catch (e) {
    print(e);
    return false; // Error occurred
  }
}



void _showErrorDialog(BuildContext context, String message) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _resetPassword(String email) {
  // Your logic to send password reset email
  // For example, call your API here
  print('Reset link sent to: $email'); // Replace with actual logic
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Color.fromRGBO(252, 252, 252, 1),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    child: Image.asset('assets/icons/ren.png'),
                  ),
                  Text(
                    'RentConnect',
                    style: TextStyle(
                      fontFamily: 'geistsans',
                      fontWeight: FontWeight.w700,
                      color: Colors.black
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70,),
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
              const SizedBox(height: 10.0),
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
              SizedBox(height: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                     _showForgotPasswordDialog(context);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'GeistSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0,
                        color: Color.fromRGBO(95, 95, 95, 1),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
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
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontFamily: 'GeistSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.0,
                      color:Color.fromARGB(255, 97, 97, 97),
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
              const SizedBox(height: 180),
              Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      const Text(
                        "By signing up, you agree to our ",
                        style: TextStyle(
                          fontFamily: 'GeistSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Terms of Service page
                        },
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontFamily: 'GeistSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Color.fromRGBO(25, 22, 32, 1),
                          ),
                        ),
                      ),
                      const Text(
                        ' and ',
                        style: TextStyle(
                          fontFamily: 'GeistSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Privacy Policy page
                        },
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontFamily: 'GeistSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Color.fromRGBO(25, 22, 32, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

}
