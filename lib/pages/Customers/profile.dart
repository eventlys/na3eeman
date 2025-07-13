import 'package:flutter/material.dart';


class CProfilePage extends StatefulWidget {
  const CProfilePage({super.key});

  @override
  State<CProfilePage> createState() => _CProfilePageState();
}

class _CProfilePageState extends State<CProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      height: 956,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0x7F4B8077)),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 440,
              height: 393,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  Positioned(
                    left: -50,
                    top: -70,
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A4),
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 319,
                    top: 78,
                    child: Container(
                      width: 330,
                      height: 322,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFAE917A),
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 222,
            child: Container(
              height: 1432,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              decoration: ShapeDecoration(
                color: const Color(0x7F806C99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
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
                        Container(
                          width: 380,
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
                        Container(
                          width: 380,
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            shadows: [
                              BoxShadow(
                                color: Color(0x6699806C),
                                blurRadius: 5,
                                offset: Offset(3, 3),
                                spreadRadius: 0,
                              )
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
                                      image: NetworkImage("https://placehold.co/800x600"),
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
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.00, -0.00),
                        end: Alignment(1.00, 1.00),
                        colors: [const Color(0xFF806C99), const Color(0xFFDFA8A3)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 15,
                          offset: Offset(2, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage("https://placehold.co/140x140"),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
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
                    left: 312,
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
                    left: 131,
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
                    left: 317,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
