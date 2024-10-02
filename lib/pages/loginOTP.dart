import 'package:flutter/material.dart';

class Loginotp extends StatefulWidget {
  const Loginotp({super.key});

  @override
  State<Loginotp> createState() => _LoginotpState();
}

class _LoginotpState extends State<Loginotp> {
  String email = '';
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ProgressHUD(
          inAsyncCall: isApiCallProcess,
          opacity: .3,
          key: UniqueKey(),
          child: Form(
            key: globalKey,
            child: loginUI(),
            )
        ),
      ));
  }
  
  loginUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Login', style: TextStyle(
            color: Colors.white
          ),)
        ],
      ),
    );
  }
}

ProgressHUD({required bool inAsyncCall, required double opacity, required UniqueKey key, required Form child}) {
}