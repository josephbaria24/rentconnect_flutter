import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:rentcon/MongoDBModel.dart';
import 'package:rentcon/dbHelper/constant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection users;
  static late DbCollection properties;

  static Future<void> connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    log("Connected to database: ${db.databaseName}");
    log("Using user collection: $USER_COLLECTION");
    log("Using properties collection: $PROPERTIES_COLLECTION");

    users = db.collection(USER_COLLECTION);
    properties = db.collection(PROPERTIES_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getUserData() async {
    final arrData = await users.find().toList();
    return arrData;
  }

  static Future<List<Map<String, dynamic>>> getPropertiesData() async {
    final arrData = await properties.find().toList();
    return arrData;
  }

  static Future<String> insertUser(MongoDb data) async {
    try {
      var result = await users.insertOne(data.toJson());
      if (result.isSuccess) {
        return "User Data Inserted";
      } else {
        return "Something went wrong while inserting user data.";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  static Future<String> insertProperty(BoardingHouse data) async {
    try {
      var result = await properties.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Property Data Inserted";
      } else {
        return "Something went wrong while inserting property data.";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}