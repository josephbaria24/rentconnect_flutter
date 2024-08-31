import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'MongoDBModel.dart';// Adjust import based on your model location
import 'package:rentcon/dbHelper/mongodb.dart';

class MongoDbDisplayListing extends StatefulWidget {
  const MongoDbDisplayListing({super.key});

  @override
  State<MongoDbDisplayListing> createState() => _MongoDbDisplayListingState();
}

class _MongoDbDisplayListingState extends State<MongoDbDisplayListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 252, 242, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: MongoDatabase.getPropertiesData(), // Adjust this method name if needed
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text("No Data Available"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var boardingHouse = BoardingHouse.fromJson(snapshot.data![index]);
                    return displayCard(boardingHouse);
                  },
                );
              } else {
                return Center(child: Text("No Data Available"));
              }
            },
          ),
        ),
      ),
    );
  }

Widget displayCard(BoardingHouse data) {
  return Card(
    color: Color.fromRGBO(255, 252, 242, 1),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for profile icon and creator's name
          Row(
            children: [
              // Circle avatar for the profile icon
              CircleAvatar(
                backgroundImage: NetworkImage(
                  // Replace with the URL to the creator's profile image
                  //data.creatoPhoto ?? 
                  'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600',
                ),
                radius: 20, // Adjust the size as needed
              ),
              SizedBox(width: 10), // Spacing between avatar and text
              // Creator's name
              Text(
                "${data.creator}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Adjust font size as needed
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Display the image from the URL
          if (data.photo.isNotEmpty) // Check if photo URL is not empty
            Image.network(
              data.photo,
              width: double.infinity, // Adjust width as needed
              height: 200, // Adjust height as needed
              fit: BoxFit.cover, // Adjust fit as needed
            ),
          SizedBox(height: 10),
          Text("${data.description}"),
          Row(
            children: [
          SizedBox(height: 5),
          Icon(Icons.location_on, color: const Color.fromARGB(255, 3, 182, 99),),
          SizedBox(width: 6,),
          Expanded(child:
            Text(
            "${data.address}"),
           )
          
            ]
            
          )
          
        ],
      ),
    ),
  );
}

}