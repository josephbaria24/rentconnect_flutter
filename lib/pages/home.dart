import 'package:flutter/material.dart';
import 'package:rentcon/display.dart';
import 'package:rentcon/displayListings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        backgroundColor: Color.fromRGBO(255, 252, 242, 1),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
         
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height:50.0,),
            Text(
              "welcome Joseph!",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          SizedBox(height: 10),
            _searchField(),
          SizedBox(height: 10),
            Expanded(
              child: MongoDbDisplayListing(), // Integrating MongoDbDisplay
            ),
      
          ],
        ),
        ),
        
        
     
    );
  }




  Container _searchField() {
    return Container(
          margin: EdgeInsets.only(top: 20, left:20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xff101617).withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 0.0,
              )
            ]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/icons/search.png',
                width: 16.0,
                height: 16.0,),
              ),
              suffixIcon: Container(
                width: 100,
                child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VerticalDivider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.black,
                      thickness: 0.1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/icons/filter.png',
                      width: 20.0,
                      height: 20.0,),
                    ),
                  ],
                ),
              ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              )
            ),
          )
        );
  }
}

AppBar appBar() {
  return AppBar(
    backgroundColor: Color.fromRGBO(255, 252, 242, 1),
    leading: GestureDetector(
      child: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Image.asset('assets/icons/arrowback.png',
        width: 20.0,
        height: 20.0,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

  );
}