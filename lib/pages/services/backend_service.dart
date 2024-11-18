// import 'dart:convert';
// import 'package:http/http.dart' as http; // Import the HTTP package
// import 'package:rentcon/dbHelper/mongodb.dart'; // Ensure you have this import
// import 'package:shared_preferences/shared_preferences.dart';

// class BackendService {
//   static final BackendService _instance = BackendService._internal();

//   factory BackendService() {
//     return _instance;
//   }

//   BackendService._internal();

//   Future<void> init() async {
//     await MongoDatabase.connect();
//     // Add any other initialization logic here
//   }

//   Future<void> fetchNotifications(String userId) async {
//     // Your logic to fetch notifications from the backend
//   }

//    Future<Map<String, dynamic>?> fetchUserProfile(String userId, String token) async {
//     final url = Uri.parse('http://192.168.1.115:3000/user/$userId'); // Adjust the endpoint if needed
//     try {
//       final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data; // Return the user profile data
//       } else {
//         print('No profile yet');
//       }
//     } catch (error) {
//       print('Error fetching profile data: $error');
//     }
//     return null; // Return null if there's an error
//   }
// }

//   // Add more methods for your backend operations here

