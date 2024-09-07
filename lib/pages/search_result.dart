import 'package:flutter/material.dart';
import 'package:rentcon/pages/fullscreenImage.dart'; // Assuming you have this for property images
import '../models/property.dart';



class SearchResultPage extends StatelessWidget {
  final String query;
  final List<Property> properties;

  const SearchResultPage({required this.query, required this.properties, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
      ),
      body: properties.isEmpty
          ? Center(child: Text('No results found for "$query".'))
          : ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                final imageUrl = property.photo.startsWith('http')
                    ? property.photo
                    : 'http://192.168.1.13:3000/${property.photo}';

                return Card(
                  color: Color.fromRGBO(255, 252, 242, 1),
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenImage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Hero(
                          tag: imageUrl,
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          property.description,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(property.address),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '₱${property.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}