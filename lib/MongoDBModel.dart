
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

MongoDb mongoDbFromJson(String str) => MongoDb.fromJson(json.decode(str));

String mongoDbToJson(MongoDb data) => json.encode(data.toJson());

class MongoDb {
    ObjectId id;
    String firstName;
    String lastName;
    String address;

    MongoDb({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.address,
    });

    factory MongoDb.fromJson(Map<String, dynamic> json) => MongoDb(
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
    };
}

// Additional Model for Boarding House
BoardingHouse boardingHouseFromJson(String str) => BoardingHouse.fromJson(json.decode(str));
String boardingHouseToJson(BoardingHouse data) => json.encode(data.toJson());

class BoardingHouse {
  ObjectId id;
  String description;
  String photo;
  String address;
  String creator;

  BoardingHouse({
    required this.id,
    required this.description,
    required this.photo,
    required this.address,
    required this.creator,
  });

  factory BoardingHouse.fromJson(Map<String, dynamic> json) => BoardingHouse(
    id: json["_id"],
    description: json["description"],
    photo: json["photo"],
    address: json["address"],
    creator: json["creator"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "description": description,
    "photo": photo,
    "address": address,
    "creator": creator,
  };
}
