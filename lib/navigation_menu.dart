import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/bookmark.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/message.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/pages/trends.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:rentcon/theme_controller.dart';

class NavigationMenu extends StatefulWidget {
  final String token;
  const NavigationMenu({required this.token, Key? key}) : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late String email;
  late FToast ftoast;
  late ToastNotification toast;
  final themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    // Using ?? operator to avoid null errors
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    print("MessagePage initialized with email: $email");
  }
  void showToast() {
    Fluttertoast.showToast(
      msg: "This is a test toast!",  // Message displayed in the toast
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(token: widget.token));
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: themeController.isDarkMode.value ? Colors.grey[850] : Color.fromRGBO(9, 10, 9, 1),
            labelTextStyle: WidgetStateProperty.all(
              TextStyle(
                color:  themeController.isDarkMode.value ? Colors.white : Color.fromRGBO(37, 36, 34, 1),
                fontWeight: FontWeight.normal,
              ),
            ),
            iconTheme: WidgetStateProperty.all(
               IconThemeData(
                 color: themeController.isDarkMode.value ?Color.fromARGB(255, 132, 238, 90) : Color.fromARGB(255, 72, 128, 49),
              ),
            ),
          ),
          child: NavigationBar(
            height: 80,
            backgroundColor: themeController.isDarkMode.value ? Color.fromARGB(255, 19, 19, 19) : Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
            destinations: const [
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/home.png')), label: 'Home'),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/bookmark.png')), label: 'Bookmark'),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/trend.png'), size: 30), label: ''),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/message.png')), label: 'Message'),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/profile.png')), label: 'Profile'),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  late FToast ftoast;
  late ToastNotification toast;
  final String token;

  NavigationController({required this.token});

  final screens = <Widget>[];

  @override
  void onInit() {
    super.onInit();
    screens.addAll([
      HomePage(token: token),
      BookmarkPage(token: token),
      TrendPage(token: token),
      MessagePage(token: token),
      ProfilePage(token: token),
    ]);
  }
}