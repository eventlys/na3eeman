import 'package:flutter/material.dart';

class Animated3DIcon extends StatefulWidget {
  final double size;
  final IconData icon;
  final dynamic  unselectedColor;
  final dynamic  selectedColor;
  final Duration duration;
  final double rotation;
  final double scale;
  final bool enableShadows;
  final bool enableHighlights;

  const Animated3DIcon({
    Key? key,
    required this.size,
    required this.icon,
    this.unselectedColor = Colors.grey,
    this.selectedColor = Colors.red,
    this.duration = const Duration(milliseconds: 800),
    this.rotation = 2 * 3.14159, // Full rotation in radians
    this.scale = 1.3,
    this.enableShadows = true,
    this.enableHighlights = true,
  }) : super(key: key);



Color _parseColor(dynamic color) {
  if (color is Color) {
    return color;
  } else if (color is String) {
    return _hexToColor(color);
  } else {
    return Colors.grey; // Fallback color
  }
}

Color _hexToColor(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');

  // Handle different hex formats
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor'; // Add full opacity if not provided
  } else if (hexColor.length == 8) {
    // Already has alpha channel
  } else {
    throw FormatException('Invalid hex color format: $hexColor');
  }

  return Color(int.parse(hexColor, radix: 16));
}

  @override
  Animated3DIconState createState() => Animated3DIconState();
}

class Animated3DIconState extends State<Animated3DIcon> {
  bool _isSelected = false;
  bool _isAnimating = false;

  Color get _unselectedColor => widget._parseColor(widget.unselectedColor);
  Color get _selectedColor => widget._parseColor(widget.selectedColor);

  void _toggleIcon() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isSelected = !_isSelected;
    });

    await Future.delayed(widget.duration);

    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleIcon,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.elasticOut,
        transform: _isAnimating
            ? _createCoinFlipTransform()
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: _build3DIcon(),
      ),
    );
  }

  Matrix4 _createCoinFlipTransform() {
    final double progress = _isAnimating ? 1.0 : 0.0;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(progress * 3.14159); // 180 degrees around Y axis
  }

  Widget _build3DIcon() {
    final currentColor = _isSelected ? _selectedColor : _unselectedColor;
    final shadowOffset = widget.size * 0.04;
    final highlightOffset = widget.size * -0.025;

    return SizedBox(
      width: widget.size + (shadowOffset * 2),
      height: widget.size + (shadowOffset * 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow layers
          if (widget.enableShadows) ...[
            _buildShadowLayer(offset: Offset(shadowOffset, shadowOffset), opacity: 0.25),
            _buildShadowLayer(offset: Offset(shadowOffset * 0.6, shadowOffset * 0.6), opacity: 0.15),
          ],

          // Main icon
          Icon(
            widget.icon,
            color: currentColor,
            size: widget.size,
          ),

          // Highlight layer
          if (widget.enableHighlights)
            _buildHighlightLayer(offset: Offset(highlightOffset, highlightOffset)),
        ],
      ),
    );
  }

  Widget _buildShadowLayer({required Offset offset, required double opacity}) {
    return Transform.translate(
      offset: offset,
      child: Icon(
        widget.icon,
        color: Colors.black.withValues(alpha: opacity),
        size: widget.size,
      ),
    );
  }

  Widget _buildHighlightLayer({required Offset offset}) {
    return Transform.translate(
      offset: offset,
      child: Icon(
        widget.icon,
        color: Colors.white.withValues(alpha: 0.25),
        size: widget.size,
      ),
    );
  }
}
