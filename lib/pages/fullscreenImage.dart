import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close fullscreen view on tap
          },
          child: InteractiveViewer(
            child: Hero(
              tag: imageUrl, // Unique tag for Hero animation
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
