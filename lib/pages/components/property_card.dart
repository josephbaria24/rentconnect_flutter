import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rentcon/models/property.dart';
import 'package:rentcon/theme_controller.dart';
import '../propertyDetailPage.dart';
import '../fullscreenImage.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final String userEmail;
  final String imageUrl;
  final List<String> bookmarkedPropertyIds;
  final Function(String) bookmarkProperty;
  final String priceRange;
  final bool isDarkMode;
  final ThemeController _themeController = Get.find<ThemeController>();

  PropertyCard({
    required this.property,
    required this.userEmail,
    required this.imageUrl,
    required this.bookmarkedPropertyIds,
    required this.bookmarkProperty,
    required this.priceRange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _themeController.isDarkMode.value
          ? const Color.fromARGB(255, 53, 53, 53)
          : const Color.fromARGB(255, 255, 255, 255),
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailPage(
                property: property,
                userEmail: userEmail,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                property.typeOfProperty ?? 'Unknown Property Type',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenImage(
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imageUrl,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Image.asset('assets/images/empty.png'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: Icon(
                      bookmarkedPropertyIds.contains(property.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: () {
                      bookmarkProperty(property.id);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                property.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(property.address),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Price: $priceRange',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// return Card(
                                        //   color:
                                        //       _themeController.isDarkMode.value
                                        //           ? const Color.fromARGB(
                                        //               255, 53, 53, 53)
                                        //           : const Color.fromARGB(
                                        //               255, 255, 255, 255),
                                        //   elevation: 5.0,
                                        //   margin: EdgeInsets.symmetric(
                                        //       vertical: 10.0, horizontal: 10.0),
                                        //   child: InkWell(
                                        //     onTap: () {
                                        //       Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               PropertyDetailPage(
                                        //             property: property,
                                        //             userEmail: userEmail,
                                        //           ),
                                        //         ),
                                        //       );
                                        //     },
                                        //     child: Column(
                                        //       crossAxisAlignment:
                                        //           CrossAxisAlignment.start,
                                        //       children: [
                                        //         Padding(
                                        //           padding:
                                        //               const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             property.typeOfProperty ??
                                        //                 'Unknown Property Type',
                                        //             style: TextStyle(
                                        //                 fontWeight:
                                        //                     FontWeight.bold,
                                        //                 fontSize: 17),
                                        //           ),
                                        //         ),
                                        //         Stack(
                                        //           children: [
                                        //             GestureDetector(
                                        //               onTap: () {
                                        //                 Navigator.push(
                                        //                   context,
                                        //                   MaterialPageRoute(
                                        //                     builder: (context) =>
                                        //                         FullscreenImage(
                                        //                       imageUrl:
                                        //                           imageUrl,
                                        //                     ),
                                        //                   ),
                                        //                 );
                                        //               },
                                        //               child: Hero(
                                        //                 tag: imageUrl,
                                        //                 child: SizedBox(
                                        //                   width:
                                        //                       double.infinity,
                                        //                   height: 200,
                                        //                   child: ClipRRect(
                                        //                     borderRadius:
                                        //                         BorderRadius
                                        //                             .circular(
                                        //                                 10),
                                        //                     child: Image
                                        //                             .network(
                                        //                           imageUrl,
                                        //                           fit: BoxFit
                                        //                               .cover,
                                        //                         ) ??
                                        //                         Image.asset(
                                        //                             'assets/images/empty.png'),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //             Positioned(
                                        //               right: 10,
                                        //               top: 10,
                                        //               child: IconButton(
                                        //                 icon: Icon(
                                        //                   bookmarkedPropertyIds
                                        //                           .contains(
                                        //                               property
                                        //                                   .id)
                                        //                       ? Icons.bookmark
                                        //                       : Icons
                                        //                           .bookmark_border,
                                        //                   color: const Color
                                        //                       .fromARGB(
                                        //                       255, 0, 0, 0),
                                        //                 ),
                                        //                 onPressed: () {
                                        //                   bookmarkProperty(
                                        //                       property.id);
                                        //                 },
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //         Padding(
                                        //           padding:
                                        //               const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             property.description,
                                        //             style: TextStyle(
                                        //                 fontWeight:
                                        //                     FontWeight.bold),
                                        //           ),
                                        //         ),
                                        //         Padding(
                                        //           padding: const EdgeInsets
                                        //               .symmetric(
                                        //               horizontal: 8.0),
                                        //           child: Text(property.address),
                                        //         ),
                                        //         Padding(
                                        //           padding:
                                        //               const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             'Price: $priceRange',
                                        //             style: TextStyle(
                                        //               fontFamily: 'Roboto',
                                        //               fontWeight:
                                        //                   FontWeight.bold,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // );