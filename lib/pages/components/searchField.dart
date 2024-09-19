import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDarkMode;
  final Function(String) handleSearch;
  final VoidCallback performSearch;
  final VoidCallback showFilterDialog;
  final bool isFilterApplied; // Add this property to track if a filter is applied
  final ThemeController _themeController = Get.find<ThemeController>();

  SearchFieldWidget({
    required this.searchController,
    required this.isDarkMode,
    required this.handleSearch,
    required this.performSearch,
    required this.showFilterDialog,
    required this.isFilterApplied, // Initialize it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 20, right: 10),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _themeController.isDarkMode.value
                        ? Colors.grey[900]!
                        : Color(0xff101617).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  handleSearch(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _themeController.isDarkMode.value
                      ? Color.fromARGB(255, 36, 38, 43)
                      : Colors.white,
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: _themeController.isDarkMode.value
                        ? Colors.grey
                        : Color(0xffDDDADA),
                    fontSize: 14,
                  ),
                  prefixIcon: GestureDetector(
                    onTap: performSearch,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/icons/search.png',
                        color: _themeController.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        width: 16.0,
                        height: 16.0,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10), // Add some spacing between the search bar and the filter icon

          // Filter Icon
          GestureDetector(
            onTap: showFilterDialog,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isFilterApplied
                    ? const Color.fromARGB(255, 255, 193, 7)
                    : _themeController.isDarkMode.value? Color.fromARGB(139, 75, 76, 97): Color.fromARGB(255, 56, 56, 56),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/icons/filter.png',
                  
                  color: isFilterApplied
                      ? const Color.fromARGB(255, 0, 0, 0) // Active filter color
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


 //SearchFieldWidget()
  // Container _searchField() {
  //   return Container(
  //     margin: EdgeInsets.only(top: 20, left: 20, right: 20),
  //     decoration: BoxDecoration(
  //       boxShadow: [
  //         BoxShadow(
  //           color: _themeController.isDarkMode.value
  //               ? Colors.grey[900]!
  //               : Color(0xff101617).withOpacity(0.1),
  //           blurRadius: 10,
  //           spreadRadius: 1,
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       controller: _searchController,
  //       onChanged: (value) {
  //         _handleSearch(value);
  //       },
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: _themeController.isDarkMode.value
  //             ? Colors.grey[850]
  //             : Colors.white,
  //         contentPadding: EdgeInsets.all(15),
  //         hintText: 'Search',
  //         hintStyle: TextStyle(
  //           color: _themeController.isDarkMode.value
  //               ? Colors.grey
  //               : Color(0xffDDDADA),
  //           fontSize: 14,
  //         ),
  //         prefixIcon: GestureDetector(
  //           onTap: () {
  //             // Trigger search action
  //             _performSearch();
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(12),
  //             child: Image.asset(
  //               'assets/icons/search.png',
  //               color: _themeController.isDarkMode.value
  //                   ? Colors.white
  //                   : Colors.black,
  //               width: 16.0,
  //               height: 16.0,
  //             ),
  //           ),
  //         ),
  //         suffixIcon: GestureDetector(
  //           onTap: () {
  //             // Trigger filter action
  //             _showFilterDialog();
  //           },
  //           child: Container(
  //             width: 100,
  //             child: IntrinsicHeight(
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   VerticalDivider(
  //                     indent: 10,
  //                     endIndent: 10,
  //                     color: Colors.black,
  //                     thickness: 0.1,
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(12),
  //                     child: Image.asset(
  //                       'assets/icons/filter.png',
  //                       color: _themeController.isDarkMode.value
  //                           ? Colors.white
  //                           : Colors.black,
  //                       width: 20.0,
  //                       height: 20.0,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide.none,
  //         ),
  //       ),
  //     ),
  //   );
  // }