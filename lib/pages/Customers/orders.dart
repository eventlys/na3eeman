import 'package:flutter/material.dart';


class COrdersPage extends StatefulWidget {
  const COrdersPage({super.key});

  @override
  State<COrdersPage> createState() => _COrdersPageState();
}

class _COrdersPageState extends State<COrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      height: 956,
      decoration: BoxDecoration(color: const Color(0xFFEDEAE8)),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 93,
            child: Text(
              'orders',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontFamily: 'Montserrat Alternates',
                fontWeight: FontWeight.w400,
                height: 1.10,
              ),
            ),
          ),
          Positioned(
            left: 38,
            top: 163,
            child: Container(
              width: 365,
              height: 1701,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 30,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/70x70"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        'Order: 51',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                      Text(
                                        'status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 25,
                                      top: 0,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/0x25"),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/70x70"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        'Order: 51',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                      Text(
                                        'status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 25,
                                      top: 0,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/0x25"),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/70x70"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        'Order: 51',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                      Text(
                                        'status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 25,
                                      top: 0,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/0x25"),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/70x70"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        'Order: 51',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                      Text(
                                        'status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 25,
                                      top: 0,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/0x25"),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 45,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/70x70"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        'Order: 51',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                      Text(
                                        'status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 25,
                                      top: 0,
                                      child: Container(
                                        transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                        height: 25,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("https://placehold.co/0x25"),
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
          Positioned(
            left: 20,
            top: 829,
            child: Container(
              width: 400,
              height: 80,
              decoration: ShapeDecoration(
                color: const Color(0xB2DFA8A4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                shadows: [
                  BoxShadow(
                    color: Color(0x4CE0C7C9),
                    blurRadius: 8,
                    offset: Offset(5, 5),
                    spreadRadius: 0,
                  ),BoxShadow(
                    color: Color(0x33BFA6A8),
                    blurRadius: 7,
                    offset: Offset(-5, -5),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 116,
                    top: 5,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x4C000000),
                            blurRadius: 20,
                            offset: Offset(5, 5),
                            spreadRadius: 0,
                          ),BoxShadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 35,
                            offset: Offset(-10, -10),
                            spreadRadius: -10,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 33,
                    top: 20,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/40x40"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 121,
                    top: 10,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/60x60"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 229,
                    top: 20,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/40x40"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 327,
                    top: 20,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://placehold.co/40x40"),
                                  fit: BoxFit.cover,
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