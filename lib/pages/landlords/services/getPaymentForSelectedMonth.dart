import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService with ChangeNotifier {
  String? _proofOfPayment;
  bool _isLoading = false;
  String _errorMessage = '';

  String? get proofOfPayment => _proofOfPayment;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> getProofOfPaymentForSelectedMonth(String roomId, String token, String selectedMonth) async {
    final String apiUrl = 'http://192.168.1.5:3000/payment/room/6705b542970c37b7bf29c6d7/monthlyPayments';

    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['monthlyPayments'].isNotEmpty) {
          final List<dynamic> monthlyPayments = data['monthlyPayments'];

          // Find the payment for the selected month
          final paymentForMonth = monthlyPayments.firstWhere(
            (payment) => payment['January'] == selectedMonth,
            orElse: () => null,
          );

          if (paymentForMonth != null) {
            _proofOfPayment = paymentForMonth['proofOfPayment'];
          } else {
            _proofOfPayment = null;
            _errorMessage = 'No proof of payment found for $selectedMonth.';
          }
        } else {
          _errorMessage = 'No payments found or empty monthlyPayments.';
          _proofOfPayment = null;
        }
      } else {
        _errorMessage = 'Failed to fetch proof of payment: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching proof of payment: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }
}
