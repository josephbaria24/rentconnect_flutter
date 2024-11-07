// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:flutter/material.dart';
// import 'package:faker/faker.dart';
// import 'package:mongo_dart/mongo_dart.dart' as M;
// import 'package:rentcon/MongoDBModel.dart';
// import 'package:rentcon/dbHelper/mongodb.dart';

// class MongoDbInsert extends StatefulWidget {
//   const MongoDbInsert({super.key});

//   @override
//   State<MongoDbInsert> createState() => _MongoDbInsertState();
// }

// class _MongoDbInsertState extends State<MongoDbInsert> {

//   var fnameController = new TextEditingController();
//   var lnameController = new TextEditingController();
//   var addressController = new TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//           children: [
//             Text(
//               "Insert Data",
//               style: TextStyle(fontSize: 22),
//             )
//             ,SizedBox(height: 50,),
//             TextField(
//               controller: fnameController,
//               decoration: InputDecoration(labelText: "First Name"),
//             ),
//             TextField(
//               controller: lnameController,
//               decoration: InputDecoration(
//                 labelText: "Last Name"
//               ),
//             ),
//             TextField(
//               controller: addressController,
//               minLines: 2,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 labelText: "Address"
//               ),
//             ),
//             SizedBox(height: 50,),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//               OutlinedButton(onPressed: () {
//                 _fakeData();
//               }, child: Text("Generate Data"))
//               ,ElevatedButton(onPressed: () {
//                 _insertData(fnameController.text,lnameController.text,addressController.text);
//               }, child: Text("Insert Data"))
//             ],)
//           ],
//                 ),
//         )),
//     );
//   }

// Future<void> _insertData(String fName, String lName, String address) async {
//   var _id = M.ObjectId();
//   final data = MongoDb(id: _id, firstName: fName, lastName: lName, address: address);
//   var result = await MongoDatabase.insertUser(data);
//   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserted ID" + _id.oid)));
//   _clearAll();
// }

// void _clearAll() {
//   fnameController.text="";
//   lnameController.text="";
//   addressController.text="";
// }
//   void _fakeData() {
//     setState(() {
//       fnameController.text = faker.person.firstName();
//       lnameController.text = faker.person.lastName();
//       addressController.text = faker.address.streetName() + "\n" + faker.address.streetAddress();
//     });
//   }
// }