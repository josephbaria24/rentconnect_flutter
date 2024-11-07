// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
// import 'package:faker/faker.dart';
// import 'package:mongo_dart/mongo_dart.dart' as M;
// import 'package:rentcon/MongoDBModel.dart';
// import 'package:rentcon/dbHelper/mongodb.dart';

// class BoardingHouseInsert extends StatefulWidget {
//   const BoardingHouseInsert({super.key});

//   @override
//   State<BoardingHouseInsert> createState() => _BoardingHouseInsertState();
// }

// class _BoardingHouseInsertState extends State<BoardingHouseInsert> {
//   var descriptionController = TextEditingController();
//   var photoController = TextEditingController();
//   var addressController = TextEditingController();
//   var creatorController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             children: [
//               Text(
//                 "Insert Boarding House Data",
//                 style: TextStyle(fontSize: 22),
//               ),
//               SizedBox(height: 50),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(labelText: "Description"),
//               ),
//               TextField(
//                 controller: photoController,
//                 decoration: InputDecoration(labelText: "Photo URL"),
//               ),
//               TextField(
//                 controller: addressController,
//                 minLines: 2,
//                 maxLines: 5,
//                 decoration: InputDecoration(labelText: "Address"),
//               ),
//               TextField(
//                 controller: creatorController,
//                 decoration: InputDecoration(labelText: "Creator"),
//               ),
//               SizedBox(height: 50),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   OutlinedButton(
//                     onPressed: () {
//                       _fakeData();
//                     },
//                     child: Text("Generate Data"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       _insertBoardingHouseData(
//                         descriptionController.text,
//                         photoController.text,
//                         addressController.text,
//                         creatorController.text,
//                       );
//                     },
//                     child: Text("Insert Data"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// Future<void> _insertBoardingHouseData(String description, String photo, String address, String creator) async {
//   var _id = M.ObjectId();
//   final data = BoardingHouse(
//     id: _id,
//     description: description,
//     photo: photo,
//     address: address,
//     creator: creator,
//   );
  
//   var result = await MongoDatabase.insertProperty(data);
//   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserted ID: " + _id.oid)));
//   _clearAll();
// }

//   void _clearAll() {
//     descriptionController.text = "";
//     photoController.text = "";
//     addressController.text = "";
//     creatorController.text = "";
//   }

//   void _fakeData() {
//     setState(() {
//       descriptionController.text = faker.lorem.sentence();
//       photoController.text = faker.image.loremPicsum(); // Random image URL from faker
//       addressController.text = faker.address.streetName() + "\n" + faker.address.streetAddress();
//       creatorController.text = faker.person.name();
//     });
//   }
// }
