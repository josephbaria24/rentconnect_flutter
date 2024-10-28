// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SelectMonthButton extends StatelessWidget {
  final VoidCallback onSelectMonth;

  const SelectMonthButton({Key? key, required this.onSelectMonth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
        ShadButton.secondary(
          onPressed: onSelectMonth,
          child: const Text('Select Month'),
          backgroundColor: const Color.fromARGB(255, 201, 200, 200),
        ),
      ],
    );
  }
}
