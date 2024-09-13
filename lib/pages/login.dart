import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/navigation_menu.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _obscurePassword = true;
  bool _isLoggingIn = false; // New variable to track login status
  late SharedPreferences prefs;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    initSharedPref();
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
        var response = await http.post(
          Uri.parse(login), 
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.body.isEmpty) {
          print("Received an empty response from the server.");
          showErrorMessage("Error", "No response from the server.");
          return;
        }

        var jsonResponse;
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (e) {
          print("Error decoding JSON: $e");
          showErrorMessage("Error", "Invalid response format.");
          return;
        }

        if (jsonResponse['status'] == true) {
          var myToken = jsonResponse['token'];
          prefs.setString('token', myToken);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NavigationMenu(token: myToken)),
          );
        } else {
          print("Login failed: ${jsonResponse['message']}");
          showErrorMessage("Login Failed", jsonResponse['message'] ?? "Something went wrong.");
        }
      } catch (error) {
        print("Error during login: $error");
        showErrorMessage("Error", "Failed to connect to the server.");
      } finally {
        setState(() {
          _isLoggingIn = false; // Stop loading state
        });
      }
    } else {
      showErrorMessage("Input Error", "Email and password cannot be empty.");
    }
  }

  void showErrorMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
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
      backgroundColor: _themeController.isDarkMode.value
          ? Color.fromARGB(255, 19, 19, 19)
          : Color.fromRGBO(252, 252, 252, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login to RentConnect',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromRGBO(5, 5, 5, 1),
              ),
            ),
            const SizedBox(height: 40.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                floatingLabelStyle: TextStyle(
                  color: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 148, 148, 148),
                ),
                filled: false,
                fillColor: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 241, 241, 241)
                    : Color.fromRGBO(117, 117, 117, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 253, 253, 253)
                        : const Color.fromARGB(255, 56, 55, 55),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 133, 177, 139)
                        : Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                floatingLabelStyle: TextStyle(
                  color: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 148, 148, 148),
                ),
                filled: false,
                fillColor: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 241, 241, 241)
                    : Color.fromRGBO(117, 117, 117, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 253, 253, 253)
                        : const Color.fromARGB(255, 56, 55, 55),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? Color.fromARGB(255, 133, 177, 139)
                        : Colors.blue,
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: _themeController.isDarkMode.value
                        ? Color.fromARGB(255, 214, 214, 214)
                        : Color.fromRGBO(83, 83, 83, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: _isLoggingIn
                  ? null
                  : () {
                      loginUser();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 115, 212, 77)
                    : Color.fromARGB(255, 5, 12, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 80.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _isLoggingIn ? 'Logging in...' : 'Login',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0,
                  color: _themeController.isDarkMode.value
                      ? Color.fromARGB(255, 5, 5, 5)
                      : Color.fromRGBO(250, 250, 250, 1),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: _themeController.isDarkMode.value
                          ? Colors.green
                          : Colors.blue,
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
