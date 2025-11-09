import 'package:flutter/material.dart';

class SidebarBackground extends StatelessWidget {
  const SidebarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main background
        Container(
          color: Colors.transparent,
        ),

        // Bubbles
        ..._generateBubbles(),
      ],
    );
  }

  List<Widget> _generateBubbles() {
    final bubbles = <Widget>[];
    final positions = [
      const Alignment(-0.8, -0.9),
      const Alignment(-0.2, -0.7),
      const Alignment(0.9, -0.4),
      const Alignment(0.7, 0.1),
      const Alignment(-0.3, 0.3),
      const Alignment(0.4, 0.8),
      const Alignment(-0.7, 0.9),
    ];

    final colors = [
      Colors.blue.withOpacity(0.2),
      Colors.purple.withOpacity(0.2),
      Colors.orange.withOpacity(0.2),
      Colors.green.withOpacity(0.2),
    ];

    for (int i = 0; i < positions.length; i++) {
      bubbles.add(
        Align(
          alignment: positions[i],
          child: Container(
            width: 80 + (i * 10),
            height: 80 + (i * 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[i % colors.length],
            ),
          ),
        ),
      );
    }

    return bubbles;
  }
}

