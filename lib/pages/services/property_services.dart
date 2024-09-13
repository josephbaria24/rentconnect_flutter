import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rentcon/models/property.dart';

class PropertyService {
  final String token;

  PropertyService({required this.token});

  Future<List<Property>> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.16:3000/getAllProperties'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['success'];

        return data
            .map((json) => Property.fromJson(json as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (error) {
      throw Exception('Failed to load properties: $error');
    }
  }

  Future<List<dynamic>> fetchRooms(String propertyId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.16:3000/rooms/properties/$propertyId/rooms'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          return data['rooms'];
        }
      }
    } catch (e) {
      print('Failed to load rooms for property $propertyId');
    }
    return [];
  }

  Future<List<Property>> filterProperties(
  List<Property> properties,
  String searchQuery,
  TextEditingController minPriceController,
  TextEditingController maxPriceController
) async {
  double? minPrice = double.tryParse(minPriceController.text);
  double? maxPrice = double.tryParse(maxPriceController.text);

  List<Property> filtered = [];

  for (Property property in properties) {
    bool matchesDescription = property.description
            .toLowerCase()
            .contains(searchQuery) ||
        property.address.toLowerCase().contains(searchQuery);

    print('Property Description: ${property.description}');
    print('Property Address: ${property.address}');
    print('Matches Description: $matchesDescription');

    if (!matchesDescription) continue;

    bool matchesPrice = true;

    if (minPrice != null || maxPrice != null) {
      List<dynamic> rooms = await fetchRooms(property.id);

      if (rooms.isNotEmpty) {
        double minRoomPrice = rooms.map((r) {
          final price = r['price'];
          return price is int ? price.toDouble() : price as double;
        }).reduce((a, b) => a < b ? a : b);

        double maxRoomPrice = rooms.map((r) {
          final price = r['price'];
          return price is int ? price.toDouble() : price as double;
        }).reduce((a, b) => a > b ? a : b);

        print('Min Room Price: $minRoomPrice');
        print('Max Room Price: $maxRoomPrice');

        if (minPrice != null && maxRoomPrice < minPrice) {
          matchesPrice = false;
        }
        if (maxPrice != null && minRoomPrice > maxPrice) {
          matchesPrice = false;
        }
      } else {
        matchesPrice = false;
      }
    }

    if (matchesPrice) {
      filtered.add(property);
    }
  }

  print('Filtered Properties Count: ${filtered.length}');

  return filtered;
}


  Future<void> fetchUserBookmarks(Function(List<String>) updateBookmarks) async {
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.16:3000/getUserBookmarks/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        List<String> bookmarkedIds = List<String>.from(
            jsonMap['properties'].map((property) => property['_id']));
        updateBookmarks(bookmarkedIds);
      } else {
        throw Exception('Failed to fetch bookmarks');
      }
    } catch (error) {
      print('Error loading user bookmarks: $error');
    }
  }

  Future<String> fetchUserEmail(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.16:3000/getUserEmail/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['email'];
      } else {
        throw Exception('Failed to load user email');
      }
    } catch (error) {
      throw Exception('Failed to load user email: $error');
    }
  }

  Future<void> bookmarkProperty(String propertyId, List<String> bookmarkedPropertyIds, Function updateProperties) async {
    final Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

    try {
      if (bookmarkedPropertyIds.contains(propertyId)) {
        final removeUrl = Uri.parse('http://192.168.1.16:3000/removeBookmark');
        await http.post(removeUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        bookmarkedPropertyIds.remove(propertyId);
        updateProperties(bookmarkedPropertyIds);
      } else {
        final url = Uri.parse('http://192.168.1.16:3000/addBookmark');
        await http.post(url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'propertyId': propertyId,
            }));

        bookmarkedPropertyIds.add(propertyId);
        updateProperties(bookmarkedPropertyIds);
      }
    } catch (error) {
      print('Error toggling bookmark: $error');
    }
  }
}


  //Fetch properties from the API
//   Future<List<Property>> fetchProperties() async {
//     try {
//       final response = await http.get(Uri.parse(getAllProperties));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         final List<dynamic> data = json['success'];

//         // Convert JSON data to Property objects
//         final properties = data
//             .map((json) => Property.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Reverse the list to show newest properties first
//         return properties.reversed.toList();
//       } else {
//         throw Exception('Failed to load properties');
//       }
//     } catch (error) {
//       throw Exception('Failed to load properties: $error');
//     }
//   }

//   Future<List<dynamic>> fetchRooms(String propertyId) async {
//     try {
//       final response = await http.get(Uri.parse(
//           'http://192.168.1.16:3000/rooms/properties/$propertyId/rooms'));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status']) {
//           return data['rooms']; // Return the rooms data as List<dynamic>
//         }
//       }
//     } catch (e) {
//       print('Failed to load rooms for property $propertyId');
//     }
//     return []; // Return an empty list if an error occurs or no rooms are found
//   }

//   Future<List<Property>> filterProperties(List<Property> properties) async {
//     double? minPrice = double.tryParse(_minPriceController.text);
//     double? maxPrice = double.tryParse(_maxPriceController.text);

//     List<Property> filtered = [];

//     for (Property property in properties) {
//       bool matchesDescription = property.description
//               .toLowerCase()
//               .contains(searchQuery.toLowerCase()) ||
//           property.address.toLowerCase().contains(searchQuery.toLowerCase());

//       if (!matchesDescription)
//         continue; // Skip property if it doesn't match description

//       bool matchesPrice = true;

//       if (minPrice != null || maxPrice != null) {
//         List<dynamic> rooms = await fetchRooms(property.id);

//         if (rooms.isNotEmpty) {
//           // Ensure all prices are treated as doubles
//           double minRoomPrice = rooms.map((r) {
//             final price = r['price'];
//             return price is int ? price.toDouble() : price as double;
//           }).reduce((a, b) => a < b ? a : b);

//           double maxRoomPrice = rooms.map((r) {
//             final price = r['price'];
//             return price is int ? price.toDouble() : price as double;
//           }).reduce((a, b) => a > b ? a : b);

//           if (minPrice != null && maxRoomPrice < minPrice) {
//             matchesPrice = false;
//           }
//           if (maxPrice != null && minRoomPrice > maxPrice) {
//             matchesPrice = false;
//           }
//         } else {
//           matchesPrice = false; // No rooms means no price information
//         }
//       }

//       if (matchesPrice) {
//         filtered
//             .add(property); // Only add properties that match the price range
//       }
//     }

//     return filtered;
//   }

//   Future<void> fetchUserBookmarks() async {
//     final Map<String, dynamic> jwtDecodedToken =
//         JwtDecoder.decode(widget.token);
//     String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'http://192.168.1.16:3000/getUserBookmarks/$userId'), // Adjust endpoint if necessary
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonMap = jsonDecode(response.body);
//         // Populate the bookmarkedPropertyIds list
//         bookmarkedPropertyIds = List<String>.from(
//             jsonMap['properties'].map((property) => property['_id']));
//       } else {
//         throw Exception('Failed to fetch bookmarks');
//       }
//     } catch (error) {
//       print('Error loading user bookmarks: $error');
//     }
//   }

//   // Fetch user email from API
//   Future<String> fetchUserEmail(String userId) async {
//     try {
//       final response = await http
//           .get(Uri.parse('http://192.168.1.16:3000/getUserEmail/$userId'));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         return json['email'];
//       } else {
//         throw Exception('Failed to load user email');
//       }
//     } catch (error) {
//       throw Exception('Failed to load user email: $error');
//     }
//   }

//   // Refresh function to reload the properties
//   Future<void> _refreshProperties() async {
//     setState(() {
//       propertiesFuture = fetchProperties(); // Re-fetch properties on refresh
//     });
//   }

// // Function to bookmark a property
//   Future<void> bookmarkProperty(String propertyId) async {
//     final url = Uri.parse('http://192.168.1.16:3000/addBookmark');
//     final Map<String, dynamic> jwtDecodedToken =
//         JwtDecoder.decode(widget.token);
//     String userId = jwtDecodedToken['_id']?.toString() ?? 'Unknown user ID';

//     try {
//       if (bookmarkedPropertyIds.contains(propertyId)) {
//         // If already bookmarked, remove it
//         final removeUrl = Uri.parse('http://192.168.1.16:3000/removeBookmark');
//         await http.post(removeUrl,
//             headers: {
//               'Authorization': 'Bearer ${widget.token}',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({
//               'userId': userId,
//               'propertyId': propertyId,
//             }));

//         setState(() {
//           bookmarkedPropertyIds.remove(propertyId); // Update local state
//           filteredProperties = filteredProperties
//               .where((property) => property.id != propertyId)
//               .toList();
//         });

//         // Show custom toast for removal
//         toast.warn('Property removed from bookmarks!');
//       } else {
//         // If not bookmarked, add it
//         await http.post(url,
//             headers: {
//               'Authorization': 'Bearer ${widget.token}',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode({
//               'userId': userId,
//               'propertyId': propertyId,
//             }));

//         setState(() {
//           bookmarkedPropertyIds.add(propertyId); // Update local state
//         });

//         // Show custom toast for addition
//         toast.success('Property added to bookmarks!');
//       }

//       // Refresh properties to reflect changes immediately
//       await _refreshProperties();
//     } catch (error) {
//       print('Error toggling bookmark: $error');
//       // Show error message with a custom toast
//       toast.error('Failed to toggle bookmark');
//     }
//   }