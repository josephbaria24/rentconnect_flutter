import 'package:flutter/material.dart';

class FilterDialog {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback applyFilters;

  FilterDialog({
    required this.minPriceController,
    required this.maxPriceController,
    required this.applyFilters,
  });

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Properties'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minPriceController,
                decoration: InputDecoration(labelText: 'Min Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxPriceController,
                decoration: InputDecoration(labelText: 'Max Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                applyFilters(); // Apply the filters
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without applying filters
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

// void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Filter Properties'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: _minPriceController,
  //               decoration: InputDecoration(labelText: 'Min Price'),
  //               keyboardType: TextInputType.number,
  //             ),
  //             TextField(
  //               controller: _maxPriceController,
  //               decoration: InputDecoration(labelText: 'Max Price'),
  //               keyboardType: TextInputType.number,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //               _applyFilters(); // Apply the filters
  //             },
  //             child: Text('Apply'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context)
  //                   .pop(); // Close the dialog without applying filters
  //             },
  //             child: Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }