// tutorial_targets.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> createTutorialTargets(
  GlobalKey showRoomImageKey,
  GlobalKey roomDetailsKey,
  GlobalKey durationKey,
  GlobalKey billsKey,
  GlobalKey paymentSectionKey,
  GlobalKey roomMatesSectionKey,
  GlobalKey ratingsKey,
  
) {
  return [
    // Show Room Image Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: showRoomImageKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This is the room image section. Tap here to view the room images.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ito ang bahagi ng larawan ng silid. Pindutin ito upang tingnan ang mga larawan ng silid.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to next',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    // Room Details Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: roomDetailsKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Here are the details of the room. Check for amenities and other specifications.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Narito ang mga detalye ng silid. Suriin ang mga amenities at iba pang mga detalye.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to next',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),

    TargetFocus(
  radius: 10,
  shape: ShapeLightFocus.RRect,
  keyTarget: durationKey,
  contents: [
    TargetContent(
      align: ContentAlign.bottom,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(204, 30, 33, 41),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              SizedBox(height: 20),
              Text(
                'You can see here the days left to occupy the reserved room. Failure to occupy within this duration might forfeit your reservation fee. Please occupy the room before the duration runs out.',
                style: TextStyle(
                  color: const Color.fromARGB(199, 255, 255, 255),
                  fontFamily: 'geistsans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Makikita mo rito ang natitirang araw upang i-occupy ang nakareserve na room. Ang hindi pag-okupa sa loob ng takdang oras ay maaaring magresulta sa pagkawala ng iyong reservation fee. Mangyaring okupahan ang silid bago matapos ang takdang panahon.',
                style: TextStyle(
                  color: const Color.fromARGB(199, 255, 255, 255),
                  fontFamily: 'geistsans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Tap to finish',
                style: TextStyle(
                  color: const Color.fromARGB(199, 255, 255, 255),
                  fontFamily: 'geistsans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),
    // Bills Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: billsKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This section lists all bills associated with the property. Review them regularly.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ang seksyon na ito ay naglalaman ng lahat ng mga bill na kaugnay ng ari-arian. Suriin ang mga ito nang regular.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to next',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    // Payment Section Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: paymentSectionKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This is where you can manage payment information. Press the month box and you can upload the receipt or any proof of your payment in every month.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Dito mo maaring i-manage ang impormasyon ng pagbabayad.Pindutin ang box na may buwan at maaari kang mag-upload kada buwan ng patunay ng iyong bayad.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to next',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    // Roommates Section Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: roomMatesSectionKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Here you can see all the roommates in the property. You can manage their details here.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Dito mo makikita ang lahat ng mga kasama sa bahay. Maaari mong pamahalaan ang kanilang mga detalye dito.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to next',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    // Ratings Section Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: ratingsKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Here, you can view and add ratings for the property. Your feedback matters!',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Dito, maaari mong tingnan at idagdag ang mga rating para sa ari-arian. Mahalaga ang iyong feedback!',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap to finish',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'geistsans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    

  ];
}
