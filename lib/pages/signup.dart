import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;


class SignUpPage extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
  
  }
//const SignUpPage({super.key});
class _RegistrationState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passworController = TextEditingController();
  bool _isNotValidate = false;

  void registerUser() async {
    if(emailController.text.isNotEmpty && passworController.text.isNotEmpty) {

    }else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50,),
            const Text(
              'Sign Up to RentConnect',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),

            // const SizedBox(height: 20.0),
            // TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Firstname',
            //     filled: true,
            //     fillColor: Colors.grey[200],
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //       borderSide: BorderSide.none,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 10.0),
            // TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Lastname',
            //     filled: true,
            //     fillColor: Colors.grey[200],
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //       borderSide: BorderSide.none,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 10.0),
            // TextField(
            //   decoration: InputDecoration(
            //     labelText: 'Username',
            //     filled: true,
            //     fillColor: Colors.grey[200],
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //       borderSide: BorderSide.none,
            //     ),
            //   ),
            // ),


            const SizedBox(height: 10.0),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                errorStyle: TextStyle(color: const Color.fromARGB(255, 255, 0, 0)),
                errorText: _isNotValidate ? "Enter Proper Info" : null,
                
              ),
            ),

            const SizedBox(height: 10.0),
            TextField(
              controller: passworController,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                errorStyle: TextStyle(color: const Color.fromARGB(255, 255, 0, 0)),
                errorText: _isNotValidate ? "Enter Proper Info" : null,
                labelText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.visibility),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => {
                registerUser()
                // Navigator.push(context,
                //  MaterialPageRoute(builder: (context) => const LoginPage()),
                //  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D57),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  color: Colors.white,
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
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Color(0xFFFF3D57),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

}