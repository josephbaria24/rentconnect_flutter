import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentcon/pages/landlords/services/getPaymentForSelectedMonth.dart';

class Try extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paymentService = Provider.of<PaymentService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Proof of Payment')),
      body: Center(
        child: paymentService.isLoading
            ? CircularProgressIndicator()
            : paymentService.errorMessage.isNotEmpty
                ? Text(paymentService.errorMessage)
                : paymentService.proofOfPayment != null
                    ? Text('Proof of Payment: ${paymentService.proofOfPayment}')
                    : Text('No proof of payment found.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call the function with your parameters
          paymentService.getProofOfPaymentForSelectedMonth('roomId', 'token', 'January');
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
