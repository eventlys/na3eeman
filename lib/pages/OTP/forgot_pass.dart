import 'package:flutter/material.dart';


class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      height: 956,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFFEDEAE8)),
      child: Stack(
        children: [
          Positioned(
            left: 301,
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
          Positioned(
            left: 24,
            top: 156,
            child: SizedBox(
              width: 338,
              child: Text(
                'We will send a verification code to your registered phone number.',
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
                'forget password',
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
            left: 18,
            top: 503,
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
            left: 195,
            top: 521,
            child: Text(
              'Send',
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
            left: 20,
            top: 334,
            child: Container(
              width: 400,
              height: 65,
              decoration: ShapeDecoration(
                color: const Color(0xE5FFFAF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 15,
                    offset: Offset(2, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 39,
                    top: 18,
                    child: Text(
                      'default property',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
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
