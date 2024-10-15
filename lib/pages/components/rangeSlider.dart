import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FilterDialog extends StatefulWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback applyFilters;
  final RangeValues initialRange;
  final VoidCallback clearFilters;

  FilterDialog({
    required this.minPriceController,
    required this.maxPriceController,
    required this.applyFilters,
    required this.initialRange,
    required this.clearFilters,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late RangeValues _selectedRange;

  @override
  void initState() {
    super.initState();
    // Initialize the selected range with the initial range passed to the dialog
    _selectedRange = widget.initialRange;
  }
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(240, 28, 29, 34): const Color.fromARGB(237, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      title: Center(
        child: Text("Filter", style: TextStyle(
          fontFamily: 'geistsans',
          fontWeight: FontWeight.bold,
          
        ),),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Price Range", style: TextStyle(
            fontFamily: 'geistsans',
          ),),
          RangeSlider(
            inactiveColor: Colors.black,
            activeColor: const Color.fromARGB(255, 255, 0, 85),
            values: _selectedRange,
            min: 0.0,
            max: 10000.0,
            divisions: 100,
            labels: RangeLabels(
              _selectedRange.start.round().toString(),
              _selectedRange.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _selectedRange = values;
                widget.minPriceController.text = values.start.round().toString();
                widget.maxPriceController.text = values.end.round().toString();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Min: ${_selectedRange.start.round()}"),
              Text("Max: ${_selectedRange.end.round()}"),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text("Cancel", style: TextStyle(
            fontFamily: 'geistsans',
            color: _themeController.isDarkMode.value? Colors.white :Colors.black
          ),),
        ),
        ShadButton(
          backgroundColor: _themeController.isDarkMode.value? const Color.fromARGB(255, 255, 255, 255):Colors.black,
          onPressed: () {
            widget.applyFilters(); // Apply the filters
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text("Apply", style: TextStyle(
            color: _themeController.isDarkMode.value? Colors.black:Colors.white
          ),),
        ),
        TextButton(
          onPressed: () {
            widget.clearFilters(); // Clear the filters
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text("Clear", style: TextStyle(
            fontFamily: 'geistsans',
            color: _themeController.isDarkMode.value? Colors.white :Colors.black
          ),),
        ),
      ],
    );
  }
}
