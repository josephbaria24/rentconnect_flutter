// lib/components/payment_details.dart

// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentcon/pages/fullscreenImage.dart';

class PaymentDetails extends StatefulWidget {
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

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
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
          'Due Date: ${widget.selectedDueDate != null ? DateFormat('MMMM dd, yyyy').format(widget.selectedDueDate!) : 'N/A'}',
        ),
        Text('Total Amount: ₱${widget.room?['price'] ?? 'N/A'}'),
        const SizedBox(height: 10),

        // Expanded Month Button
        widget.buildMonthButtons(widget.room),
        const SizedBox(height: 10),

        Text(
          'Proof of Payment:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        FutureBuilder<String?>(
          future: widget.proofFuture,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenImage(imageUrl: snapshot.data!)));
                },
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Text(
                            '${widget.selectedMonth}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.5, 1.5),
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                height: 100,
                alignment: Alignment.center,
                child: Text('No proof uploaded for ${widget.selectedMonth}'),
              );
            }
          },
        ),
      ],
    );
  }
}
