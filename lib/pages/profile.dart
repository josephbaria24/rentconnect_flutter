import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/landlords/listing.dart';
import 'package:shared_preferences/shared_preferences.dart';


//white 255, 252, 242
// light gray 204, 197, 185
// dark gray 64, 61, 57
// black 37, 36, 34
// orange 235, 94, 40

// black 000000
// blue 14213d
// yellow fca311
// gray e5e5e5
// white ffffff
class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String email;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    // Safely extracting 'email' from the decoded token
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
  }

  
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Replace 'auth_token' with your actual key

    // Navigate to login page or splash screen
    Navigator.pushReplacementNamed(context, '/login'); // Replace '/login' with your actual route name
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            SizedBox(
            width: 120, height: 120,
            child: ClipRRect(borderRadius: BorderRadius.circular(100), 
            child: Image.asset("assets/images/profile.png")),
          ),
          const SizedBox(height: 10),
          Text('Joseph', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Text('$email', style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500
          )),
          const SizedBox(height: 20,),
          SizedBox(
          width: 200, 
          child: ElevatedButton(onPressed: (){}, 
          child: const Text('Edit Profile',
          style: TextStyle(
            color: Colors.black
              ),
            ),
          ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // Menu
          ProfileMenuWidget(title: "Personal Information", icon: LineAwesomeIcons.user, onPress: () {}),
          ProfileMenuWidget(title: "Account Settings", icon: LineAwesomeIcons.cog_solid, onPress: () {}),
          ProfileMenuWidget(title: "Listing", icon: LineAwesomeIcons.list_alt_solid, onPress: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  CurrentListingPage(token: widget.token)),);
          }),
          ProfileMenuWidget(title: "About", icon: LineAwesomeIcons.info_solid, onPress: () {}),
          ProfileMenuWidget(title: "Logout", icon: LineAwesomeIcons.sign_out_alt_solid, textColor: Colors.red, endIcon: false, onPress: _logout),
          ], 
        ),
        
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

final String title;
final IconData icon;
final VoidCallback onPress;
final bool endIcon;
final Color? textColor;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color.fromRGBO(247, 40, 147, 0.1)
        ),
        child: Icon(icon, color: Color.fromRGBO(235, 94, 40, 1),)
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)?.apply(color: textColor)),
      trailing: endIcon? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color.fromRGBO(204, 197, 185, 0.2)
        ),
        child: const Icon(LineAwesomeIcons.angle_right_solid, size: 18.0, color: Color.fromRGBO(94, 94, 94, 1))) : null,
      );
  }
}