// tutorial_targets.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
List<TargetFocus> createTutorialTargets(
    GlobalKey dueDateKey,
    GlobalKey paymentStatusKey,
    GlobalKey proofOfPaymentKey,
    GlobalKey monthlyPaymentKey,
) {
  return [
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: dueDateKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(204, 30, 33, 41), // Background color
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255), // Outline color
                width: 2.0, // Outline width
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This is the due date section. Tap here to select a due date for rental payment.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ito ang bahagi ng petsa ng pagbabayad. Pindutin ito upang pumili ng petsa ng pagbabayad ng renta.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'manrope',
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
                      fontFamily: 'manrope',
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
    // Add other TargetFocus objects similarly
    // Monthly Payment Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: monthlyPaymentKey,
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
                    'These months show proof of rental payments from occupants. Press to check for any uploaded payment proof.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ipinapakita ng mga buwang ito ang katibayan ng mga pagbabayad ng renta mula sa mga umuupa. I-tap upang suriin ang anumang na-upload na katibayan ng pagbabayad.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'manrope',
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
                      fontFamily: 'manrope',
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
    // Proof of Payment Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: proofOfPaymentKey,
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
                    'This section shows the proof of payment uploaded by occupants of your room. You can view fullscreen by tapping.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ipinapakita ng seksyon na ito ang katibayan ng pagbabayad na na-upload ng mga umuupa ng iyong silid. Maaari mong tingnan ito sa fullscreen sa pamamagitan ng pag-tap.',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'manrope',
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
                      fontFamily: 'manrope',
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
    // Payment Status Target
    TargetFocus(
      radius: 10,
      shape: ShapeLightFocus.RRect,
      keyTarget: paymentStatusKey,
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
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: 'Check and update the payment status here. '),
                        TextSpan(
                          text: "'Complete'",
                          style: TextStyle(color: Colors.green), // Green for 'Complete'
                        ),
                        TextSpan(text: ' if payment is done, or '),
                        TextSpan(
                          text: "'Reject'",
                          style: TextStyle(color: Colors.red), // Red for 'Reject'
                        ),
                        TextSpan(text: ' if the occupant uploaded a photo but payment is not yet received.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: const Color.fromARGB(199, 255, 255, 255),
                        fontFamily: 'manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: 'Suriin at i-update ang istatus ng pagbabayad dito. Markahan ang '),
                        TextSpan(
                          text: "'Complete'",
                          style: TextStyle(color: Colors.green), // Green for 'Complete'
                        ),
                        TextSpan(text: ' kung ang pagbabayad ay tapos na, o '),
                        TextSpan(
                          text: "'Reject'",
                          style: TextStyle(color: Colors.red), // Red for 'Reject'
                        ),
                        TextSpan(text: ' kung ang umuupa ay nag-upload ng larawan ngunit hindi pa natanggap ang pagbabayad.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                   SizedBox(height: 20),
                  Text(
                    'Done',
                    style: TextStyle(
                      color: const Color.fromARGB(199, 255, 255, 255),
                      fontFamily: 'manrope',
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
