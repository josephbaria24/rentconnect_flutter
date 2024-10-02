import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rentcon/models/login_response_model.dart';

class ApiService {
  static var client = http.Client();

  static Future<LoginResponseModel> otpLogin(String email) async {
    var url = Uri.http("127.0.0.1:3000", "/otp-login");

    var response = await client.post(
      url,
      headers: {'Content-type' : "application/json"},
      body: jsonEncode({
        "email": email
      })
      );
    
    return loginResponseModel(response.body);
  }
  static Future<LoginResponseModel> verfyOTP(String email, String otpHash, String otpCode ) async {
    var url = Uri.http("127.0.0.1:3000", "/otp-verify");

    var response = await client.post(
      url,
      headers: {'Content-type' : "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otpCode,
        "otpHash": otpHash,

      })
      );
    
    return loginResponseModel(response.body);
  }
}