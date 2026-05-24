import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String link;
  final String text;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final bool underline;

  const TextLink({
    super.key,
    required this.link,
    required this.text,
    required this.color,
    required this.fontWeight,
    this.fontSize = 16,
    this.fontFamily = 'Jost',
    this.underline = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, link);
      },
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          decoration: underline
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
      ),
    );
  }
}
