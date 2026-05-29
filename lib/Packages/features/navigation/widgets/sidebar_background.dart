import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class SidebarBackground extends StatelessWidget {
  const SidebarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 40,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: Stack(
        children: const [
          // Background circles removed to match cleaner design
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(Alignment alignment, Color color, double size) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
