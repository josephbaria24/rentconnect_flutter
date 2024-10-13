import 'package:flutter/material.dart';

class ReservationDurationPicker extends StatefulWidget {
  final Function(int) onDurationSelected;

  ReservationDurationPicker({required this.onDurationSelected});

  @override
  _ReservationDurationPickerState createState() => _ReservationDurationPickerState();
}

class _ReservationDurationPickerState extends State<ReservationDurationPicker> {
  int _selectedDuration = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Reservation Duration: "),
        DropdownButton<int>(
          value: _selectedDuration,
          items: List.generate(30, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text("${index + 1} days"),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedDuration = value!;
            });
            widget.onDurationSelected(_selectedDuration);
          },
        ),
      ],
    );
  }
}
