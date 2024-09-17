import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Filter"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Price Range"),
          RangeSlider(
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
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.applyFilters(); // Apply the filters
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text("Apply"),
        ),
        TextButton(
          onPressed: () {
            widget.clearFilters(); // Clear the filters
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text("Clear"),
        ),
      ],
    );
  }
}
