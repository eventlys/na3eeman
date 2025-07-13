import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'OTP/forgot_pass.dart';
import 'customers/signup.dart';
import 'customers/home.dart';
// import 'dart:ui'; // Required for Matrix4

// Define your StatefulWidget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Added super.key for best practice

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Define the State class for your StatefulWidget
class _LoginPageState extends State<LoginPage> {
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
            left: 52,
            top: 661,
            child: Container(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/razor.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 382,
            top: 659,
            child: Container(
              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/mirror.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 49.15,
            top: 66.17,
            child: Container(
              width: 49.66,
              height: 49.66,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/chair.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 341,
            top: 857,
            child: Container(
              width: 99.32,
              height: 99.32,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/comb.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 786,
            child: Container(
              width: 99.32,
              height: 99.32,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/scissors.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 62.86,
            top: 461.27,
            child: Container(
              width: 79.46,
              height: 79.46,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/scissors-1.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 331.10,
            top: 55,
            child: Container(
              width: 99.32,
              height: 99.32,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/scissors-2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 156,
            child: SizedBox(
              width: 338,
              child: Text.rich( // Changed 'text.rich(' to 'Text.rich('
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome come Back To ',
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
                        fontSize: 20,
                        fontFamily: 'Joti One',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.10,
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
            top: 103,
            child: SizedBox(
              width: 119,
              child: Text(
                'Login',
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
            top: 547,
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
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 194,
            top: 565,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CHomePage()),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.10,
                ),
              ),
            ),
          ),
          Positioned(
            left: 290,
            top: 471,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPassPage()),
                );
              },
              child: Text(
                'Forgot Password ?',
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
            left: 162,
            top: 677,
            child: Text(
              'Or login With',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Josefin Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            left: 301,
            top: 686,
            child: Container(
              width: 101,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 686,
            child: Container(
              width: 101,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 96,
            top: 886,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'don’t have an account ? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'signup',
                    style: TextStyle(
                      color: const Color(0xFF99806C),
                      fontSize: 18,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                    // --- This is the key change for tap functionality ---
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigate to the SignupPage when 'signup' is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 240,
            top: 746,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 79,
                height: 79,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 20,
                      offset: Offset(9, 10),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 255,
            top: 761,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/scissors-2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 121,
            top: 746,
            child: Opacity(
              opacity: 0.80,
              child: Container(
                width: 79,
                height: 79,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 20,
                      offset: Offset(9, 10),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 135,
            top: 761,
            child: Opacity(
              opacity: 0.70,
              child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Stack(),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 296,
            child: Container(
              width: 400,
              height: 65,
              decoration: ShapeDecoration(
                color: const Color(0xE5FFFAF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 15,
                    offset: Offset(2, -2),
                    spreadRadius: 0,
                  )
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
          ),
          Positioned(
            left: 20,
            top: 403,
            child: Container(
              width: 400,
              height: 65,
              decoration: ShapeDecoration(
                color: const Color(0xE5FFFAF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 15,
                    offset: Offset(2, -2),
                    spreadRadius: 0,
                  )
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
          ),
        ],
      ),
    );
  }
}

