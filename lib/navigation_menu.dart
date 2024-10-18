import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/bookmark.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/message.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/pages/trends.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 255, 255, 255)
        : themeController.isDarkMode.value
            ? const Color.fromARGB(255, 255, 255, 255)
            : const Color.fromARGB(255, 0, 9, 34);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(token: widget.token, initialIndex: _selectedIndex));

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? const Color.fromARGB(255, 28, 29, 34)
          : const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10, bottom: 20),
          child: LayoutBuilder(
            builder:  (context, constraints) {
            print('Max Width: ${constraints.maxWidth}');
                return Container(
              width: double.infinity, 
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 39, 41, 48)
                    : const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20), // Rounded corners for the nav bar
                boxShadow: [
                  BoxShadow(
                    offset: Offset(1, 5),
                    color: themeController.isDarkMode.value? Color.fromARGB(255, 28, 29, 34): Color.fromARGB(31, 31, 31, 31),
                    blurRadius: 9,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: GNav(
                tabBorderRadius: 15,
                color: themeController.isDarkMode.value ? Colors.white : Colors.black,
                backgroundColor: themeController.isDarkMode.value ? const Color.fromARGB(255, 39, 41, 48) : const Color.fromARGB(255, 255, 255, 255),
                rippleColor: const Color.fromARGB(255, 255, 255, 255),
                hoverColor: const Color.fromARGB(255, 0, 19, 37),
                iconSize: 24,
                haptic: true,
                activeColor: themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : const Color.fromARGB(255, 255, 255, 255),
                tabBackgroundColor: themeController.isDarkMode.value
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 42, 36, 59),
                gap: 8,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  controller.selectedIndex.value = index;
                },
                tabs: [
                  GButton(
                    icon: Icons.home_filled,
                    iconActiveColor: _getIconColor(0),
                    text: 'Home',
                    leading: Image.asset(
                      'assets/icons/home.png',
                      height: 24,
                      color: _getIconColor(0),
                    ),
                  ),
                  GButton(
                    icon: Icons.favorite_border,
                    iconActiveColor: _getIconColor(1),
                    text: 'Saved',
                    leading: SvgPicture.asset(
                      'assets/icons/fave.svg',
                      color: _getIconColor(1),
                    ),
                  ),
                  GButton(
                    icon: Icons.pie_chart_outline,
                    iconActiveColor: _getIconColor(2),
                    text: 'Trends',
                    leading: SvgPicture.asset(
                      'assets/icons/analytic.svg',
                      color: _getIconColor(2),
                      height: 24,
                      width: 24,
                    ),
                  ),
                  GButton(
                    icon: Icons.message_outlined,
                    iconActiveColor: _getIconColor(3),
                    text: 'Inbox',
                    leading: Transform(
                      alignment: Alignment.center, // Ensure the flip happens around the center
                      transform: Matrix4.rotationY(3.1416), // Flip horizontally by rotating 180 degrees (π radians)
                      child: Image.asset(
                        'assets/icons/typing.png',
                        color: _getIconColor(3),
                        height: 24,
                      ),
                    ),),
                  GButton(
                    icon: Icons.person_2_outlined,
                    iconActiveColor: _getIconColor(4),
                    text: 'Profile',
                    leading: SvgPicture.asset(
                      'assets/icons/person.svg',
                      color: _getIconColor(4),
                      height: 24,
                      width: 24,
                    ),
                  ),
                ],
              ),
            );
            }
          ),
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
