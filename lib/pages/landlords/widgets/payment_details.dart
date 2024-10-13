// lib/components/payment_details.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentDetails extends StatelessWidget {
  final Map<String, dynamic>? room;
  final DateTime? selectedDueDate;
  final String? selectedMonth;
  final Future<String?>? proofFuture;
  final Widget Function(Map<String, dynamic>?) buildMonthButtons;

  PaymentDetails({
    this.room,
    this.selectedDueDate,
    this.selectedMonth,
    this.proofFuture,
    required this.buildMonthButtons,
  });

  void showFullscreenImage(BuildContext context, String imageUrl) {
    // Your logic to show a fullscreen image
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          'Due Date: ${selectedDueDate != null ? DateFormat('MMMM dd, yyyy').format(selectedDueDate!) : 'N/A'}',
        ),
        Text('Total Amount: ₱${room?['price'] ?? 'N/A'}'),
        const SizedBox(height: 10),

        // Expanded Month Button
        buildMonthButtons(room),
        const SizedBox(height: 10),

        Text(
          'Proof of Payment:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        FutureBuilder<String?>(
          future: proofFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: CupertinoActivityIndicator(),
              );
            } else if (snapshot.hasError) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('Error loading image'),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              return GestureDetector(
                onTap: () {
                  showFullscreenImage(context, snapshot.data!);
                },
                child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('No proof uploaded for $selectedMonth'),
              );
            }
          },
        ),
      ],
    );
  }
}
