import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';

class FilterChips extends StatefulWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onSelected;

  const FilterChips({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
      child: Wrap(
        spacing: 5.0,
        children: widget.filters.map((filter) {
          final isSelected = widget.selectedFilter == filter;
          return ChoiceChip(
            checkmarkColor: _themeController.isDarkMode.value ? Colors.black : Colors.white,
            iconTheme: IconThemeData(color: _themeController.isDarkMode.value ? Colors.black : Colors.white),
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected 
                    ? _themeController.isDarkMode.value
                        ? const Color.fromARGB(255, 1, 23, 36)
                        : Colors.white
                    : _themeController.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                widget.onSelected(filter);
              }
            },
            selectedColor: _themeController.isDarkMode.value
                ? Colors.white
                : const Color.fromARGB(255, 1, 23, 36),
            backgroundColor: _themeController.isDarkMode.value
                ? const Color.fromARGB(255, 48, 51, 58)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : const Color.fromARGB(255, 0, 16, 29),
                width: 0.4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
