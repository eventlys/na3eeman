import 'package:flutter/material.dart';


class CHomePage extends StatefulWidget {
  const CHomePage({super.key});

  @override
  State<CHomePage> createState() => _CHomePageState();
}

class _CHomePageState extends State<CHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      height: 956,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 440,
              height: 956,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Stack(
                children: [
                  Positioned(
                    left: 69,
                    top: -200,
                    child: Container(
                      width: 475.18,
                      height: 487.26,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A4),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 94,
                    top: 512,
                    child: Container(
                      width: 532.93,
                      height: 549.08,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDFA8A3),
                        shape: OvalBorder(),
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
                    ),
                  ),
                  Positioned(
                    left: 232,
                    top: 245,
                    child: Container(
                      width: 304,
                      height: 535,
                      decoration: ShapeDecoration(
                        color: const Color(0x4C806C99),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -607,
                    top: 646,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        SizedBox(
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
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: const Color(0xFFCF4A45),
                            fontSize: 24,
                            fontFamily: 'Montserrat Alternates',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -531,
                    top: 571,
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 20,
                        children: [
                          SizedBox(
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
                          Text(
                            'Security',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Montserrat Alternates',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: -450,
                    top: 496,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        SizedBox(
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
                        Text(
                          'Privacy policy',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Montserrat Alternates',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -333,
                    top: 421,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        SizedBox(
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
                        Text(
                          'Contact us',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Montserrat Alternates',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -213,
                    top: 346,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        SizedBox(
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
                        Text(
                          'Orders',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Montserrat Alternates',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -153,
                    top: 271,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        SizedBox(
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
                        Text(
                          'Favorites',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Montserrat Alternates',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 440,
                      height: 956,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: const Color(0xFFEDEAE8)),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 14,
                            top: 443,
                            child: SizedBox(
                              width: 161,
                              height: 24,
                              child: Text(
                                'Near by location',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.10,
                                  shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Color(0xFF000000).withValues(alpha: 0x40))],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 357,
                            top: 443,
                            child: SizedBox(
                              width: 68,
                              height: 24,
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  color: const Color(0xFF99806C),
                                  fontSize: 18,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.09,
                                  shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Color(0xFF000000).withValues(alpha: 0x40))],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 90,
                            top: 635,
                            child: Container(
                              width: 330,
                              height: 115,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.70),
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
                                    left: 55,
                                    top: 10,
                                    child: Text(
                                      'barbershop  name',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: 'Montserrat Alternates',
                                        fontWeight: FontWeight.w400,
                                        height: 1.17,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 55,
                                    top: 38,
                                    child: Text(
                                      '9:00 - 22:00',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 285,
                                    top: 45,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: 55,
                                    top: 79,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: 175,
                                    top: 79,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: -70,
                                    top: 0,
                                    child: SizedBox(
                                      width: 115,
                                      height: 115,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                              width: 115,
                                              height: 115,
                                              decoration: ShapeDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage("https://placehold.co/115x115"),
                                                  fit: BoxFit.cover,
                                                ),
                                                shape: OvalBorder(),
                                                shadows: [
                                                  BoxShadow(
                                                    color: Color(0x6699806C),
                                                    blurRadius: 5,
                                                    offset: Offset(3, 3),
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
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 90,
                            top: 502,
                            child: Container(
                              width: 330,
                              height: 115,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.70),
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
                                    left: 55,
                                    top: 10,
                                    child: Text(
                                      'barbershop  name',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: 'Montserrat Alternates',
                                        fontWeight: FontWeight.w400,
                                        height: 1.17,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 55,
                                    top: 38,
                                    child: Text(
                                      '9:00 - 22:00',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 285,
                                    top: 45,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: 55,
                                    top: 79,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: 175,
                                    top: 79,
                                    child: SizedBox(
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
                                  ),
                                  Positioned(
                                    left: -70,
                                    top: 0,
                                    child: SizedBox(
                                      width: 115,
                                      height: 115,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                              width: 115,
                                              height: 115,
                                              decoration: ShapeDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage("https://placehold.co/115x115"),
                                                  fit: BoxFit.cover,
                                                ),
                                                shape: OvalBorder(),
                                                shadows: [
                                                  BoxShadow(
                                                    color: Color(0x6699806C),
                                                    blurRadius: 5,
                                                    offset: Offset(3, 3),
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
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 178,
                            child: Container(
                              width: 400,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 25,
                                children: [
                                  Container(
                                    width: 330,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 156,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/330x156"),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
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
                                        Container(
                                          width: 106,
                                          height: 138,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/106x138"),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(50),
                                                topRight: Radius.circular(50),
                                                bottomRight: Radius.circular(50),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 30,
                                          top: 106,
                                          child: SizedBox(
                                            width: 101,
                                            child: Text(
                                              'Enjoy & relax in a luxury\nBarber shop environment',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontFamily: 'Segoe UI',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 16,
                                          top: 31,
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Your hair\n',
                                                  style: TextStyle(
                                                    color: const Color(0xFF99806C),
                                                    fontSize: 24,
                                                    fontFamily: 'Montserrat Alternates',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'deserves the best.',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontFamily: 'Montserrat Alternates',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 330,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 156,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/330x156"),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
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
                                        Container(
                                          width: 106,
                                          height: 138,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/106x138"),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(50),
                                                topRight: Radius.circular(50),
                                                bottomRight: Radius.circular(50),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 30,
                                          top: 106,
                                          child: SizedBox(
                                            width: 101,
                                            child: Text(
                                              'Enjoy & relax in a luxury\nBarber shop environment',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontFamily: 'Segoe UI',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 16,
                                          top: 31,
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Your hair\n',
                                                  style: TextStyle(
                                                    color: const Color(0xFF99806C),
                                                    fontSize: 24,
                                                    fontFamily: 'Montserrat Alternates',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'deserves the best.',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontFamily: 'Montserrat Alternates',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ],
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
                                    left: 18,
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
                                    left: 23,
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
                                                  image: AssetImage("assets/home_front.png"),
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
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 54,
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 30,
                        children: [
                          SizedBox(
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
                                        image: AssetImage("assets/home_view.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                color: const Color(0xFFE0CBBB),
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