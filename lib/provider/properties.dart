import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentcon/models/property.dart';
import 'dart:convert';
import 'package:rentcon/models/property.dart';
class PropertiesProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> get properties => _properties;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProperties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://rentconnect.vercel.app/getAllProperties'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['success'];

        _properties = data
            .map((json) => Property.fromJson(json as Map<String, dynamic>))
            .toList()
            .where((property) => property.status.toLowerCase() == 'approved')
            .toList();

        _properties = _properties.reversed.toList();
      } else {
        _errorMessage = 'Failed to load properties';
      }
    } catch (error) {
      _errorMessage = 'Failed to load properties: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
