// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';
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
   TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;
  bool obscure = true;
  bool obscureConfirm = true;
  final _themeController = Get.find<ThemeController>();
    Timer? _timer;
  bool _isCooldown = false;
  int _secondsRemaining = 60;
   late ToastNotification toastNotification;
  // Stop the timer when dialog is dismissed or OTP is verified

  // Function to handle OTP resend
 @override
  void initState() {
    super.initState();
        toastNotification = ToastNotification(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(255, 255, 255, 255),
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    _stopTimer();
    super.dispose();
  }

 

    void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  // Start the countdown timer
  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _secondsRemaining = 60; // Reset to 60 seconds for cooldown
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isCooldown = false;
          _stopTimer(); // Stop timer when cooldown ends
        }
      });
    });
  }



void _handleRegistrationError(String errorMessage) {
  if (errorMessage.contains("Email already registered but not verified")) {
    _showResendOtpDialog(emailController.text.trim());
  } else if (errorMessage.contains("Email already registered and verified")) {
    _showEmailExistsDialog();
  } else {
    _showErrorDialog(errorMessage);
  }
}


  // Function to resend OTP
  Future<void> _resendOtp(String email) async {
    if (!_isCooldown) {
      try {
        var response = await http.post(
          Uri.parse('https://rentconnect.vercel.app/resend-otp'), // Replace with your resend OTP endpoint
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'email': email}),
        );

        if (response.statusCode == 200) {
          _startCooldown(); // Start cooldown on successful resend
          toastNotification.success('OTP resent successfully. Please check your email.');
        } else {
          toastNotification.error('Error resending OTP. Please try again.');
        }
      } catch (error) {
        toastNotification.error("Error: $error. Please check your connection.");
      }
    }
  }

void _showResendOtpDialog(String email) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Email Verification Required'),
        content: const Text('Your email is already registered but not verified. Would you like to resend the OTP?'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resendOtp(email); // Resend OTP and then show OTP dialog
              _showOtpDialog(email); // Show OTP dialog for verification
            },
            isDefaultAction: true,
            child: const Text('Resend OTP'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}


 // Method to show OTP dialog
void _showOtpDialog(String email) {
  List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  String hash = ""; // Generate or retrieve hash if needed
  bool _isCooldown = false; // Tracks cooldown status
  int _secondsRemaining = 60; // Tracks remaining seconds for cooldown
  Timer? _timer; // Timer for managing cooldown

  // Start cooldown timer for 60 seconds
  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _secondsRemaining = 60; // 60 seconds cooldown
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
        child: StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Text('Enter OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('A verification code has been sent to your email. Please enter it below:'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 40,
                        child: CupertinoTextField(
                          controller: otpControllers[index],
                          keyboardType: TextInputType.number,
                          maxLength: 1, // Limit to 1 digit per box
                          textAlign: TextAlign.center,
                          placeholder: '•',
                          onChanged: (value) {
                          // Move to the next box if a digit is entered
                          if (value.isNotEmpty && index < otpControllers.length - 1) {
                            FocusScope.of(context).nextFocus(); // Move to the next field
                          }

                          // Optionally, you can also automatically delete the digit and move back
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus(); // Move to the previous field
                          }
                        },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  if (_isCooldown)
                    Text('Please wait ${(_secondsRemaining ~/ 60)}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} before requesting again.'),
                  if (!_isCooldown)
            CupertinoButton(
              child: const Text('Resend OTP'),
              onPressed: () async {
                await _resendOtp(email); // Call the resend OTP function with the email
              },
            ),
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () async {
                    // Combine OTP inputs into a single string
                    String otp = otpControllers.map((controller) => controller.text).join();

                    // Call the OTP verification function here
                    bool isVerified = await verifyOtp(email, otp.trim(), hash);
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
            );
          },
        ),
      );
    },
  );
}


void _showEmailExistsDialog() {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Email Exists'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Ensure the column size is minimized
          children: [
            Container(
              width: 100,
              height: 100,
              child: rive.RiveAnimation.asset(
                "assets/flares/alert_icon.riv", // The correct Rive file path
                animations: ['show'],    // The animation name in the Rive file
              ),
            ),
            const SizedBox(height: 16), // Add some space between the animation and the text
            const Text('This email is already registered. Would you like to go to the login page?'),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              ); // Navigate to login page
            },
            isDefaultAction: true,
            child: const Text('Go to Login'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
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

 
void registerUser() async {
  // Check if terms and conditions checkbox is checked
  if (!isChecked) {
    // If the checkbox is not checked, show an error message and return
    setState(() {
      _isNotValidate = true; // Show validation message for the checkbox
    });
    return; // Prevent registration from proceeding
  }

  setState(() {
    _isLoading = true; // Start loading
    _isNotValidate = false; // Reset checkbox validation error if it was previously shown
  });

  // Check if input fields are not empty
  if (emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty) {
    // Check if passwords match
    if (passwordController.text == confirmPasswordController.text) {
      try {
        var regBody = {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        };

        // Make POST request to registration endpoint
        var response = await http.post(
          Uri.parse(registration), // Ensure this URL is correct
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        // Handle the response
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            // Success: Show OTP dialog
            _showOtpDialog(emailController.text.trim());
          } else {
            // Handle error cases
            String errorMessage = jsonResponse['error'] ?? "Registration failed. Please try again.";
            _handleRegistrationError(errorMessage);
          }
        } else if (response.statusCode == 400) {
          // Handle specific client-side errors
          var jsonResponse = jsonDecode(response.body);
          String errorMessage = jsonResponse['error'] ?? "Registration failed. Please try again.";
          _handleRegistrationError(errorMessage);
        } else {
          // Log the server response for debugging
          print('Server responded with status code: ${response.statusCode}');
          print('Response body: ${response.body}'); // Log response body for inspection

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



Future<bool> verifyOtp(String email, String otp, String hash) async {
  try {
    var response = await http.post(
      Uri.parse('https://rentconnect.vercel.app/verify-email-otp'), // Replace with your verification endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'hash': hash,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        // Show Cupertino success dialog with animated check
        await _showSuccessDialog();

        // Navigate to login after showing dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );

        return true;
      } else {
        _showErrorDialog("Invalid OTP. Please try again.");
        return false;
      }
    } else {
      
      return false;
    }
  } catch (error) {
    _showErrorDialog("Error: $error. Please check your connection.");
    return false;
  }
}




Future<void> _showSuccessDialog() async {
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Success'),
        content: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              child: rive.RiveAnimation.asset(
                "assets/flares/checkmark_circle.riv", // The correct Rive file path
                animations: ['Animation 1'],    // The animation name in the Rive file
              ),
            ),
            SizedBox(height: 10),
            Text('Email verified successfully!'),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

  // Method to open the Terms and Conditions URL
  Future<void> _openTermsAndConditions() async {
    const String url = 'https://josephbaria24.github.io/rentconnect_terms-condition/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }


bool isChecked = false;


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    Text('RentConnect', style: TextStyle(
                      fontFamily: 'manrope',
                      fontWeight: FontWeight.w700,
                      color: Colors.black
                    )),
                  ],
                ),
                SizedBox(height: 70,),
                
                SvgPicture.asset("assets/icons/signup.svg", height: 100),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'manrope',
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
                const SizedBox(height: 10.0),

                // Checkbox and agreement text
                Row(
                children: <Widget>[
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                        _isNotValidate = false; // Reset validation error when checked
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color.fromARGB(255, 73, 73, 73),
                          fontFamily: 'manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: 'By agreeing, you accept the '),
                          TextSpan(
                            text: 'terms and conditions',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontFamily: 'manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              _openTermsAndConditions(); // Show the terms and conditions dialog
                            },
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

                if (_isNotValidate) ...[
                  Text(
                    'Please check the box of agreement to proceed.',
                    style: TextStyle(color: Colors.red[700],
                    fontFamily: 'manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
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
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: <Widget>[
                    const Text('Already have an account?',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'manrope'
                    )),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.black,
                        fontFamily: 'manrope',
                        fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

void _showTermsAndConditions(BuildContext context) {
  final isDarkMode = _themeController.isDarkMode.value; // Check if dark mode is enabled

  showShadDialog(
    context: context,
    builder: (context) {
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light, // Set brightness
          primaryColor: isDarkMode ? Colors.white : Colors.black, // Customize colors
        ),
        child: CupertinoAlertDialog(
          title: Text('Terms and Conditions', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      children: [
                        TextSpan(
                          text: 'Welcome to RentConnect! Our platform is designed to facilitate seamless connections between ', 
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        const TextSpan(
                          text: 'landlords',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        const TextSpan(
                          text: 'occupants',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ', making it easier to market and find ',
                        ),
                        const TextSpan(
                          text: 'properties',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: '. By using our services, you agree to comply with all applicable ',
                        ),
                        const TextSpan(
                          text: 'laws',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        const TextSpan(
                          text: 'regulations',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' governing property rentals. Our team is dedicated to ensuring the ',
                        ),
                        const TextSpan(
                          text: 'safety',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        const TextSpan(
                          text: 'compliance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' of every property listed on our platform and the users who engage with them.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      children: [
                        const TextSpan(
                          text: 'We strive to maintain a secure and trustworthy environment for all members of the RentConnect community. By accepting these terms, you acknowledge that you understand your ',
                        ),
                        const TextSpan(
                          text: 'rights',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        const TextSpan(
                          text: 'responsibilities',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' as a user and agree to abide by them. If you have any questions or concerns about these terms, please feel free to contact our ',
                        ),
                        const TextSpan(
                          text: 'support team',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: '.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    },
  );
}




}