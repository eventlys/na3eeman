import 'package:flutter/material.dart';

// Reusable Faded Background Widget
class FadedBackground extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget? child;

  const FadedBackground({
    super.key,
    required this.startColor,
    required this.endColor,
    this.begin = const Alignment(0.50, -0.40),
    this.end = const Alignment(0.50, 0.50),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [startColor, endColor],
        ),
      ),
      child: child,
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadedBackground(
        startColor: const Color(0xffffffff),
        endColor: const Color(0xB3DFA8A4),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Third Page",
                style: TextStyle(fontSize: 28, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text("Button"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

