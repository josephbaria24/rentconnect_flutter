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
  bool _obscurePassword = true;  // New variable to toggle password visibility
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
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };
      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationMenu(token: myToken)),
        );
      } else {
        print("Something went wrong");
      }
    }
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
                  ? const Color.fromARGB(255, 255, 255, 255)  // Label color in dark mode
                  : const Color.fromARGB(255, 148, 148, 148), // Label color in light mode
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
                        ? const Color.fromARGB(255, 253, 253, 253) // Border color in dark mode
                        : const Color.fromARGB(255, 56, 55, 55), // Border color in light mode
                    width: 1.0,
                  )
                ),
                // Focused border when the field is pressed
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 133, 177, 139) // Focused border color in dark mode
                        : Colors.blue,  // Focused border color in light mode
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,  // Bind this with _obscurePassword
              decoration: InputDecoration(
                labelText: 'Password',
                floatingLabelStyle: TextStyle(
                  color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 255, 255, 255)  // Label color in dark mode
                  : const Color.fromARGB(255, 148, 148, 148), // Label color in light mode
                ),
                labelStyle: TextStyle(
                  color: _themeController.isDarkMode.value
                  ? const Color.fromARGB(255, 252, 252, 252)  // Label color in dark mode
                  : const Color.fromARGB(255, 148, 148, 148), // Label color in light mode
                ),
                filled: false,
                fillColor: _themeController.isDarkMode.value
                    ? Color.fromARGB(255, 241, 241, 241)
                    : Color.fromRGBO(117, 117, 117, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 253, 253, 253) // Border color in dark mode
                        : const Color.fromARGB(255, 56, 55, 55), // Border color in light mode
                    width: 1.0,
                  )
                ),
                // Focused border when the field is pressed
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: _themeController.isDarkMode.value
                        ? Color.fromARGB(255, 133, 177, 139) // Focused border color in dark mode
                        : Colors.blue,  // Focused border color in light mode
                    width: 2.0,
                  ),
                ),
                // Add IconButton for show/hide password
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
              onPressed: () {
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
                'Login',
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
                  child:  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: _themeController.isDarkMode.value
                      ? Color.fromARGB(255, 15, 243, 72)
                      : Color.fromRGBO(22, 104, 11, 1),
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
