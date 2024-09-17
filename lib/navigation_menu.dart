import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/bookmark.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/message.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/pages/trends.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationMenu extends StatefulWidget {
  final String token;
  final int currentIndex;

  NavigationMenu({required this.token, Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late String email;
  final themeController = Get.find<ThemeController>();
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email']?.toString() ?? 'Unknown email';
    print("NavigationMenu initialized with email: $email");
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index
        ? themeController.isDarkMode.value
            ? Color.fromRGBO(255, 255, 255, 1)
            : Color.fromRGBO(255, 255, 255, 1) 
        : themeController.isDarkMode.value
            ? Colors.grey // Adjust color for unselected icons in dark mode
            : Color.fromRGBO(218, 218, 218, 1); // Adjust color for unselected icons in light mode
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(token: widget.token, initialIndex: _selectedIndex));

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? const Color.fromARGB(255, 255, 255, 255)
          : const Color.fromARGB(255, 0, 0, 0),
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          animationDuration: const Duration(milliseconds: 350),
          buttonBackgroundColor: themeController.isDarkMode.value ? const Color.fromARGB(255, 49, 50, 58) : Colors.black,
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(248, 36, 38, 43)
              : const Color.fromARGB(255, 0, 0, 0),
          height: 60.0,
          backgroundColor: themeController.isDarkMode.value
              ? const Color.fromARGB(255, 28, 29, 34)
              : const Color.fromARGB(255, 255, 255, 255),
          items: <Widget>[
            SvgPicture.asset(
              'assets/icons/home2.svg',
              color: _getIconColor(0),
            ),
            SvgPicture.asset(
              'assets/icons/bookmark.svg',
              color: _getIconColor(1),
            ),
            SvgPicture.asset(
              'assets/icons/analytic.svg',
              color: _getIconColor(2),
              height: 35,
              width: 35,
            ),
            SvgPicture.asset(
              'assets/icons/messagel.svg',
              color: _getIconColor(3),
            ),
            SvgPicture.asset(
              'assets/icons/person.svg',
              color: _getIconColor(4),
              height: 24,
              width: 24,
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            controller.selectedIndex.value = index;
          },
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex;
  final String token;

  NavigationController({required this.token, required int initialIndex})
      : selectedIndex = initialIndex.obs;

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
