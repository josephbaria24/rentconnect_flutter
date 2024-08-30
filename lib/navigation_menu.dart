import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/pages/bookmark.dart';
import 'package:rentcon/pages/home.dart';
import 'package:rentcon/pages/message.dart';
import 'package:rentcon/pages/profile.dart';
import 'package:rentcon/pages/trends.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Color.fromRGBO(64, 61, 57, 1), // Background of the selected item
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(
                color: Color.fromRGBO(37, 36, 34, 1),
                fontWeight: FontWeight.normal,
              ),
            ),
            iconTheme: WidgetStateProperty.all(
              const IconThemeData(
                color: Color.fromRGBO(235, 94, 40, 1),
              ),
            ),
          ),
          child: NavigationBar(
              height: 80,
              backgroundColor: Color.fromRGBO(255, 252, 242, 1),
              elevation: 0,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) => controller.selectedIndex.value = index,
          
            
             
            destinations: const [
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/home.png')), label: 'Home'),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/bookmark.png')), label: 'Bookmark'),
              NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/trend.png'), size: 30,), label: ''),
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

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [ const HomePage(), const BookmarkPage(), const TrendsPage(), const MessagePage(), const ProfilePage()];
}

