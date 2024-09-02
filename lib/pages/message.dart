import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MessagePage extends StatefulWidget {
  final String token;
  const MessagePage({required this.token, Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late String email;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // Safely extracting 'email' from the decoded token
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color.fromRGBO(255, 252, 242, 1),
       body: Column(
        children: [
          Text(
            "welcome $email",
          )
          
        ],
       ),
    );
  }
}