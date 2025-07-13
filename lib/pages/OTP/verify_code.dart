import 'package:flutter/material.dart';
// import 'dart:ui'; // Required for Matrix4

// Define your StatefulWidget
class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key}); // Added super.key for best practice

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

// Define the State class for your StatefulWidget
class _VerifyCodePageState extends State<VerifyCodePage> {
  @override
  Widget build(BuildContext context) {
    // Your entire UI code goes here, returned by the build method
    return Container(
      width: 440,
      height: 956,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFFEDEAE8)),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 90,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 160,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 170,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 230,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 240,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 300,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 310,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 370,
            top: 325,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 50,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x59000000),
                      blurRadius: 9,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 380,
            top: 339,
            child: SizedBox(
              width: 29,
              height: 22,
              child: Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 156,
            child: SizedBox(
              width: 338,
              child: Text(
                'enter the verification code sent to your email.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 103,
            child: SizedBox(
              width: 316,
              child: Text(
                'Verification code',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 506,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 403,
                height: 65,
                decoration: ShapeDecoration(
                  color: const Color(0xB299806C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 20,
                      offset: Offset(9, 10),
                      spreadRadius: -5,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 198,
            top: 524,
            child: Text(
              'Next',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.10,
              ),
            ),
          ),
          Positioned(
            left: 296,
            top: 13,
            child: SizedBox(
              width: 105,
              height: 26,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: SizedBox(
                      width: 105,
                      height: 26.25,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(width: 105, height: 26.25),
                          ),
                          Positioned(
                            left: 63,
                            top: 5.91,
                            child: Container(
                              width: 31.50,
                              height: 15.09,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1.31),
                                  borderRadius: BorderRadius.circular(3.28),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 25.59,
                            top: 6.56,
                            child: Container(
                              width: 3.94,
                              height: 13.12,
                              decoration: ShapeDecoration(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.31),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 19.69,
                            top: 9.19,
                            child: Container(
                              width: 3.94,
                              height: 10.50,
                              decoration: ShapeDecoration(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.31),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 13.78,
                            top: 11.81,
                            child: Container(
                              width: 3.94,
                              height: 7.88,
                              decoration: ShapeDecoration(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.31),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 7.88,
                            top: 13.78,
                            child: Container(
                              width: 3.94,
                              height: 5.91,
                              decoration: ShapeDecoration(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1.31),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
