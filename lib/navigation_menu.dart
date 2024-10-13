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
            ? const Color.fromRGBO(255, 255, 255, 1)
            :  Color.fromARGB(255, 255, 7, 90)
        : themeController.isDarkMode.value
            ? Colors.grey
            : const Color.fromARGB(176, 136, 136, 136);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(token: widget.token, initialIndex: _selectedIndex));

    return Scaffold(
      backgroundColor: themeController.isDarkMode.value
          ? const Color.fromARGB(255, 255, 255, 255)
          : const Color.fromARGB(255, 255, 255, 255),
      bottomNavigationBar: Container(
          constraints: BoxConstraints(minHeight: 60), // Use minimum height constraint
          color: themeController.isDarkMode.value
              ? const Color.fromARGB(255, 28, 29, 34)
              : const Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GNav(
            tabBorderRadius: 15,
            color: themeController.isDarkMode.value ?  Colors.white : Colors.black,
            backgroundColor: themeController.isDarkMode.value ? const Color.fromARGB(255, 28, 29, 34) : const Color.fromARGB(255, 255, 255, 255),
            rippleColor: Color.fromARGB(255, 255, 7, 90),
            hoverColor: Color.fromARGB(255, 255, 7, 90),
            iconSize: 24,
            haptic: true,
            activeColor: themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255): Color.fromARGB(255, 255, 255, 255),
            tabBackgroundColor: themeController.isDarkMode.value ? const Color.fromARGB(195, 255, 7, 90) : const Color.fromARGB(255, 42, 36, 59),
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                leading: SvgPicture.asset(
                  'assets/icons/home2.svg',
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
                leading: SvgPicture.asset(
                  'assets/icons/messagel.svg',
                  color: _getIconColor(3),
                ),
              ),
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
