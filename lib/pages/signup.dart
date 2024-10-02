import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart';
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
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;
  bool obscure = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(255, 255, 255, 255),
      statusBarIconBrightness: Brightness.dark,
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
        try {
          var regBody = {
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
          };

          var response = await http.post(
            Uri.parse(registration), // Ensure this URL is correct
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody),
          );

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status']) {
              // Success: Show OTP dialog
              _showOtpDialog(emailController.text.trim());
            } else {
              _showErrorDialog(jsonResponse['error'] ?? "Registration failed. Please try again.");
            }
          } else {
            _showErrorDialog("Server error: ${response.statusCode}. Please try again.");
          }
        } catch (error) {
          _showErrorDialog("Error: $error. Please check your connection.");
        }
      } else {
        _showErrorDialog('Passwords do not match.');
      }
    } else {
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

  // Method to show OTP dialog
void _showOtpDialog(String email) {
  TextEditingController otpController = TextEditingController();
  String hash = ""; // Generate or retrieve hash if needed
  bool _isCooldown = false; // Tracks cooldown status
  int _secondsRemaining = 0; // Tracks remaining seconds for cooldown
  Timer? _timer; // Timer for managing cooldown

  // Start cooldown timer for 5 minutes
  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _secondsRemaining = 300; // 5 minutes = 300 seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  // Function to resend OTP
  Future<void> _resendOtp() async {
    if (!_isCooldown) {
      try {
        var response = await http.post(
          Uri.parse('http://192.168.1.31:3000/resend-otp'), // Replace with your resend OTP endpoint
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'email': email}),
        );

        if (response.statusCode == 200) {
          _startCooldown(); // Start cooldown on successful resend
          _showErrorDialog('OTP resent successfully. Please check your email.');
        } else {
          _showErrorDialog('Error resending OTP. Please try again.');
        }
      } catch (error) {
        _showErrorDialog("Error: $error. Please check your connection.");
      }
    }
  }

  // Cleanup the timer when dialog is closed
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  showCupertinoDialog(
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          _stopTimer(); // Stop timer when dialog is dismissed
          return true;
        },
        child: CupertinoAlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A verification code has been sent to your email. Please enter it below:'),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: otpController,
                placeholder: 'OTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              if (_isCooldown)
                Text('Please wait ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} before requesting again.'),
              if (!_isCooldown)
                CupertinoButton(
                  child: const Text('Resend OTP'),
                  onPressed: _resendOtp,
                ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () async {
                // Call the OTP verification function here
                bool isVerified = await verifyOtp(email, otpController.text.trim(), hash);
                if (isVerified) {
                  _stopTimer(); // Stop timer when verification is successful
                  // Navigate to the login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                } else {
                  _showErrorDialog('Invalid OTP. Please try again.');
                }
              },
              isDefaultAction: true,
              child: const Text('Verify'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                _stopTimer(); // Stop timer when dialog is closed
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    },
  );
}


  Future<bool> verifyOtp(String email, String otp, String hash) async {
    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.31:3000/verify-email-otp'), // Replace with your verification endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'hash': hash, // Include hash if necessary
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'] == true; // Adjust based on your backend response
      } else {
        _showErrorDialog("Server error: ${response.statusCode}. Please try again.");
        return false;
      }
    } catch (error) {
      _showErrorDialog("Error: $error. Please check your connection.");
      return false;
    }
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
            SvgPicture.asset("assets/icons/signup.svg", height: 100),
            const Text(
              'Sign Up',
              style: TextStyle(
                fontFamily: 'GeistSans',
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              controller: emailController,
              placeholder: const Text('Email'),
              keyboardType: TextInputType.emailAddress,
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(size: 16, LucideIcons.mail, color: Color.fromARGB(255, 25, 22, 32)),
              ),
            ),
            const SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              controller: passwordController,
              placeholder: const Text('Password'),
              obscureText: obscure,
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(size: 16, LucideIcons.lock, color: Color.fromARGB(255, 25, 22, 32)),
              ),
              suffix: ShadButton(
                width: 24,
                height: 24,
                padding: EdgeInsets.zero,
                icon: ShadImage.square(size: 16, obscure ? LucideIcons.eyeOff : LucideIcons.eye),
                onPressed: () {
                  setState(() => obscure = !obscure);
                },
              ),
            ),
            const SizedBox(height: 10.0),
            ShadInput(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              controller: confirmPasswordController,
              placeholder: const Text('Confirm Password'),
              obscureText: obscureConfirm,
              prefix: const Padding(
                padding: EdgeInsets.all(4.0),
                child: ShadImage.square(size: 16, LucideIcons.lock, color: Color.fromARGB(255, 25, 22, 32)),
              ),
              suffix: ShadButton(
                width: 24,
                height: 24,
                padding: EdgeInsets.zero,
                icon: ShadImage.square(size: 16, obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye),
                onPressed: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
              ),
            ),
            const SizedBox(height: 24.0),
            if (_isNotValidate) ...[
              Text(
                'Invalid input!',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 10.0),
            ],
            ShadButton(
              backgroundColor: Colors.black,
              onPressed: _isLoading ? null : registerUser,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(color: Colors.black),
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
