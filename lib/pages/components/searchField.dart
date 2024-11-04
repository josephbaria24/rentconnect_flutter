import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDarkMode;
  final Function(String) handleSearch;
  final VoidCallback performSearch;
  final VoidCallback showFilterDialog;
  final bool isFilterApplied;
  final ThemeController _themeController = Get.find<ThemeController>();

  SearchFieldWidget({
    required this.searchController,
    required this.isDarkMode,
    required this.handleSearch,
    required this.performSearch,
    required this.showFilterDialog,
    required this.isFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _themeController.isDarkMode.value
                        ? Colors.grey[900]!
                        : const Color(0xff101617).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,  // Use search icon on the keyboard
                onSubmitted: (value) {
                  performSearch();  // Trigger search when the search icon is pressed
                },
                onChanged: (value) {
                  handleSearch(value);  // Handle real-time search input
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _themeController.isDarkMode.value
                      ? const Color.fromARGB(255, 36, 38, 43)
                      : Colors.white,
                  contentPadding: const EdgeInsets.all(15),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: _themeController.isDarkMode.value
                        ? Colors.grey
                        : const Color(0xffDDDADA),
                    fontSize: 14,
                  ),
                  prefixIcon: GestureDetector(
                    onTap: performSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Image.asset(
                            'assets/icons/search.png',
                            color: _themeController.isDarkMode.value
                                ? Colors.black
                                : Colors.black,
                            width: 13.0,
                            height: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter Icon
          GestureDetector(
            onTap: showFilterDialog,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isFilterApplied
                    ? Colors.amber
                    : _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 41, 43, 49)
                        : const Color.fromARGB(255, 10, 0, 40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/icons/filter.png',
                  color: isFilterApplied
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : (_themeController.isDarkMode.value
                          ? Colors.white
                          : const Color.fromARGB(255, 255, 255, 255)),
                  width: 20.0,
                  height: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
