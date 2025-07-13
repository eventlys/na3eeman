import 'package:flutter/material.dart';
// import 'dart:ui'; // Required for Matrix4

// Define your StatefulWidget
class SearchPage extends StatefulWidget {
  const SearchPage({super.key}); // Added super.key for best practice

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// Define the State class for your StatefulWidget
class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    // Your entire UI code goes here, returned by the build method
    return Container(
      width: 440,
      height: 956,
      decoration: BoxDecoration(color: const Color(0xFFEDEAE8)),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 57,
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 30,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 50),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.70),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
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
                                    'Search',
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
                        ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 50),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: const Color(0xB299806C),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/25x25"),
                                              fit: BoxFit.cover,
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          'Search history',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 1.57,
                            letterSpacing: 0.20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF806C99),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    Text(
                                      'Captain Barbershop',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 6.14,
                                      top: -5.18,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                                        width: 34,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/34x16"),
                                            fit: BoxFit.cover,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF806C99),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    Text(
                                      'Captain Barbershop',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 6.14,
                                      top: -5.18,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                                        width: 34,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/34x16"),
                                            fit: BoxFit.cover,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF806C99),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    Text(
                                      'Captain Barbershop',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 6.14,
                                      top: -5.18,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                                        width: 34,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/34x16"),
                                            fit: BoxFit.cover,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF806C99),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    Text(
                                      'Captain Barbershop',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 6.14,
                                      top: -5.18,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                                        width: 34,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/34x16"),
                                            fit: BoxFit.cover,
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 15,
                                  children: [
                                    Text(
                                      'Captain Barbershop',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 6.14,
                                      top: -5.18,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                                        width: 34,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/34x16"),
                                            fit: BoxFit.cover,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}