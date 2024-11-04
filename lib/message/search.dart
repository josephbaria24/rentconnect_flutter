import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDarkMode;
  final Function(String) handleSearch;
  final Function(String) performSearch;  // Adjusted to accept a String parameter

  final ThemeController _themeController = Get.find<ThemeController>();

  SearchWidget({
    required this.searchController,
    required this.isDarkMode,
    required this.handleSearch,
    required this.performSearch,  // Initialized
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 43,
              child: Container(
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
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => performSearch(value),  // Pass value here
                  onChanged: handleSearch,
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
                      onTap: () => performSearch(searchController.text),  // Use searchController.text here
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/icons/search.png',
                              color: _themeController.isDarkMode.value
                                  ? Colors.black
                                  : Colors.black,
                              width: 15.0,
                              height: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
