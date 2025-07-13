import 'package:flutter/material.dart';
// import 'dart:ui'; // Required for Matrix4

// Define your StatefulWidget
class SignupPage extends StatefulWidget {
  const SignupPage({super.key}); // Added super.key for best practice

  @override
  State<SignupPage> createState() => _SignupPageState();
}

// Define the State class for your StatefulWidget
class _SignupPageState extends State<SignupPage> {
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
            left: -69.90,
            top: 0,
            child: Container(
              width: 579.80,
              height: 956.48,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 10,
                    offset: Offset(4, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 31.76,
                    top: 316.75,
                    child: Container(
                      width: 85.18,
                      height: 87.34,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A4),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 425.64,
                    top: 459.59,
                    child: Container(
                      width: 135.71,
                      height: 138.60,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A4),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 412.33,
                    top: 0,
                    child: Container(
                      width: 167.47,
                      height: 171.80,
                      decoration: ShapeDecoration(
                        color: const Color(0x7F4B8077),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 776.27,
                    child: Container(
                      width: 176.13,
                      height: 180.21,
                      decoration: ShapeDecoration(
                        color: const Color(0x7F4B8077),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 75.35,
                    top: 711.71,
                    child: Container(
                      width: 142.93,
                      height: 147.26,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A3),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 221,
            child: SizedBox(
              height: 1371,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 60,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 40,
                      children: [
                        Container(
                          width: 380,
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
                                  'First name',
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
                        Container(
                          width: 380,
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
                                  'Second name',
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
                        Container(
                          width: 380,
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
                                  'Email',
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
                        Container(
                          width: 380,
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
                                  'Phone Number',
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
                        Container(
                          width: 380,
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
                                  'Gender',
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
                        Container(
                          width: 380,
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
                                  'Current location',
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
                        Container(
                          width: 380,
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
                                  'Password',
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
                        Container(
                          width: 380,
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
                                  'Confirm password',
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
                        Container(
                          width: 380,
                          height: 200,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: -210,
                                top: -200,
                                child: Container(
                                  width: 800,
                                  height: 600,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://placehold.co/800x600",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 50),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 10,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xB299806C),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          SizedBox(
                            width: 59,
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: 0.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account !',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Josefin Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: ' Login',
                          style: TextStyle(
                            color: const Color(0xFF99806C),
                            fontSize: 18,
                            fontFamily: 'Josefin Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 159.08,
            child: SizedBox(
              width: 338,
              height: 21.78,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome To',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: 0.20,
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.08,
                      ),
                    ),
                    TextSpan(
                      text: 'NA3EEMAN',
                      style: TextStyle(
                        color: const Color(0xFF99806C),
                        fontSize: 24,
                        fontFamily: 'Montserrat Alternates',
                        fontWeight: FontWeight.w400,
                        height: 1.17,
                      ),
                    ),
                    TextSpan(
                      text: ' . ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 86.32,
            child: Text(
              'Register',
              style: TextStyle(
                color: Colors.black,
                fontSize: 60,
                fontFamily: 'Montserrat Alternates',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 440,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 80,
                children: [
                  Container(
                    width: 130,
                    height: 37,
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(51),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 15,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 5,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 14,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 1,
                                top: 9.50,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: ShapeDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 5.50,
                                top: 9.50,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: ShapeDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                top: 9.50,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: ShapeDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14.50,
                                top: 9.50,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: ShapeDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16, height: 14, child: Stack()),
                        SizedBox(
                          width: 25,
                          height: 14,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 2,
                                top: 3,
                                child: Container(
                                  width: 19,
                                  height: 8,
                                  decoration: ShapeDecoration(
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -10,
            top: 916,
            child: SizedBox(
              width: 440,
              height: 37,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 440,
                      height: 37,
                      decoration: ShapeDecoration(
                        color: Colors.black.withValues(alpha: 0.10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 120,
                    top: 23,
                    child: Container(
                      width: 200,
                      height: 5,
                      decoration: ShapeDecoration(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
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
    );
  }
}
