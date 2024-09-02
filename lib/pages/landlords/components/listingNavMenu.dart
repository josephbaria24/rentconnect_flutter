import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rentcon/pages/landlords/analytics.dart';
import 'package:rentcon/pages/landlords/current_listing.dart';
import 'package:rentcon/pages/landlords/inbox.dart';

class ListingNavigationMenu extends StatelessWidget {
  const ListingNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListingNavigationController());
    return Obx(
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
            NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/listing.png')), label: 'Listing'),
            NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/message.png')), label: 'Inbox'),
            NavigationDestination(icon: ImageIcon(AssetImage('assets/icons/trend.png')), label: 'Analytics'),
          ],
        ),
      ),
    );
  }
}

class ListingNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    //CurrentListing(),
    const Inbox(),
    const Analytics(),
  ];
}
