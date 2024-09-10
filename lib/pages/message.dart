import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'toast.dart'; // Import ToastNotification

class MessagePage extends StatefulWidget {
  final String token;
  const MessagePage({required this.token, Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late String email;
  late FToast ftoast;
  late ToastNotification toast;
  final themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    email = JwtDecoder.decode(widget.token)['email']?.toString() ?? 'Unknown email';
  }

  @override
  Widget build(BuildContext context) {
    // Initialize FToast and ToastNotification here
    ftoast = FToast();
    ftoast.init(context);
    toast = ToastNotification(ftoast);

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value ? Color.fromRGBO(0, 0, 0, 1) : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome $email",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              toast.success("This is a test toast!");
            },
            child: Text("Show Toast"),
          ),
        ],
      ),
    );
  }
}
