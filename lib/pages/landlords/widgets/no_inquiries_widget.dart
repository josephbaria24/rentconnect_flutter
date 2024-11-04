import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoInquiriesWidget extends StatelessWidget {
  const NoInquiriesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Container(
          width: double.infinity,
          height: 150,
          child: SvgPicture.asset('assets/images/empty.svg'),
        ),
        const SizedBox(height: 5), // Add some space between the image and the text
        const Text(
          'This room has no occupant right now, Stay tuned!',
          textAlign: TextAlign.center, // Center the text
          style: TextStyle(
            fontFamily: 'manrope',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
