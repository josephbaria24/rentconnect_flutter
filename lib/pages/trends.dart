import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TrendPage extends StatefulWidget {
  final String token;
  const TrendPage({required this.token, Key? key}) : super(key: key);

  @override
  State<TrendPage> createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage> {
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
            "Welcome $email"
          )
        ],
       ),
    );
  }
}

