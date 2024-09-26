import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart'; // Importing Shadcn UI
import 'login.dart';
import 'package:rentcon/config.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcnui;

class SignUpPage extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController(); // Added confirm password controller
  bool _isNotValidate = false;
  bool _isLoading = false; // Loading state
  bool obscure = true;
  bool obscureConfirm = true; // For confirm password visibility toggle

@override
void initState() {
  super.initState();
  
  // Set the status bar color to match your app's theme
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color.fromARGB(255, 255, 255, 255), // Set to your desired color
    statusBarIconBrightness: Brightness.dark, // Choose Brightness.light for light icons or Brightness.dark for dark icons
  ));
}



  void registerUser() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      if (passwordController.text == confirmPasswordController.text) {
        var regBody = {
          "email": emailController.text,
          "password": passwordController.text,
        };

        var response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse['status']);

        if (jsonResponse['status']) {
          // Show success dialog
          _showSuccessDialog();
        } else {
          print("Something went wrong");
        }
      } else {
        _showErrorDialog('Passwords do not match.'); // Show error if passwords don't match
      }
    } else {
      // Show Cupertino dialog if fields are empty
      _showErrorDialog('Please fill in all fields.');
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              isDefaultAction: true,
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Success dialog
  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Your account has been created successfully.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              isDefaultAction: true,
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset("assets/icons/signup.svg", 
            height: 100,),
            
            const Text(
              'Sign Up',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: ShadInput(
                cursorColor: Colors.black,
                style: TextStyle(
                  color: Colors.black
                ),
                controller: emailController, // Added controller
                placeholder: const Text('Email'),
                keyboardType: TextInputType.emailAddress,
                prefix: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: ShadImage.square(
                      size: 16, LucideIcons.mail, color: Color.fromARGB(255, 25, 22, 32)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: TextStyle(
                  color: Colors.black
                ),
              controller: passwordController, // Added controller
              placeholder: const Text('Password'),
              obscureText: obscure,
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(
                    size: 16, LucideIcons.lock, color: Color.fromARGB(255, 25, 22, 32)),
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
                  setState(() => obscure = !obscure);
                },
              ),
            ),
            const SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: TextStyle(
                  color: Colors.black
                ),
              controller: confirmPasswordController, // Confirm password controller
              placeholder: const Text('Confirm Password'),
              obscureText: obscureConfirm,
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(
                    size: 16, LucideIcons.lock, color: Color.fromARGB(255, 25, 22, 32)),
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
                  obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                ),
                onPressed: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
              ),
            ),
            const SizedBox(height: 20.0),
        
            // ShadButton for Sign Up
            ShadButton(
              backgroundColor: Color.fromARGB(255, 10, 0, 40),
              height: 40,
              width: 159,
              onPressed: _isLoading ? null : registerUser,
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8), // Spacing between icon and text
                        const Text('Signing up'),
                      ],
                    )
                  : const Text('Sign Up', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
        
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Already have an account?",
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Color.fromARGB(255, 25, 22, 32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
