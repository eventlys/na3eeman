import 'package:flutter/material.dart';

// You can define a constant for the animation duration.
const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying a help form,
/// sliding up from the bottom center.
class HelpFormOverlay extends StatefulWidget {
  // An optional callback for when the entrance animation finishes.
  final VoidCallback? onAnimationComplete;

  const HelpFormOverlay({super.key, this.onAnimationComplete});

  @override
  State<HelpFormOverlay> createState() => _HelpFormOverlayState();
}

class _HelpFormOverlayState extends State<HelpFormOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _kOverlayAnimationDuration,
    );

    // Animation: starts from below the screen (0.0, 1.0) and moves to its final position (0.0, 0.0).
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // A smooth easing curve
    ));

    // Start the animation to make the overlay appear.
    _animationController.forward().whenComplete(() {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.bottomCenter, // Positions the overlay at the bottom center
        child: Material(
          color: Colors.transparent, // Ensures the Material widget itself is transparent
          child: Container(
            width: 440,
            height: 525,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.40), // Use withOpacity for better clarity
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x6699806C), // Hex color with alpha 0x66
                  blurRadius: 5,
                  offset: Offset(3, 3),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 64,
                  child: SizedBox( // Using SizedBox as a wrapper for layout instead of Container
                    width: 400,
                    // No fixed height here, let children determine it
                    child: Column( // Use Column to lay out the subject, message, and send button vertically
                      children: [
                        // --- Subject Container ---
                        Container(
                          width: double.infinity,
                          height: 66,
                          decoration: ShapeDecoration(
                            color: const Color(0xE5FFFAF5), // Hex color with alpha 0xE5
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000), // Hex color with alpha 0x3F
                                blurRadius: 15,
                                offset: Offset(2, -2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: const Stack(
                            children: [
                              Positioned(
                                left: 39,
                                top: 18,
                                child: Text(
                                  'Subject',
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
                        const SizedBox(height: 20), // Spacer between subject and message box

                        // --- Message/Help Text Area Container ---
                        Container(
                          width: double.infinity,
                          height: 237,
                          decoration: ShapeDecoration(
                            color: const Color(0xE5FFFAF5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 15,
                                offset: Offset(2, -2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: const Stack(
                            children: [
                              Positioned(
                                left: 39,
                                top: 18,
                                child: Text(
                                  'How can we help you?',
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
                        const SizedBox(height: 20), // Spacer between message box and send button

                        // --- Send Button Container ---
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 50),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.70),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              shadows: const [
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
                              children: [ // Removed 'spacing' from Row, use SizedBox for gaps
                                const SizedBox(
                                  width: 42,
                                  child: Text(
                                    'Send',
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
                                const SizedBox(width: 10), // Explicit spacing for the row
                                SizedBox( // Replaced Container with SizedBox for fixed size icon placeholder
                                  width: 25,
                                  height: 26.60,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 25,
                                          height: 26.60,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/25x27"), // Placeholder image
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
                // --- Top Image Container ---
                Positioned(
                  left: 150,
                  top: -120, // Positioned relative to the main overlay container
                  child: SizedBox( // Replaced Container with SizedBox
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage("https://placehold.co/100x100"), // Placeholder image
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
      ),
    );
  }
}

// ---
// Helper function to show the overlay and handle dismissal via background tap.
// ---
OverlayEntry showHelpFormOverlay(BuildContext context) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // The GestureDetector here captures taps on the transparent background
        // and removes the overlay.
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.3), // Semi-transparent black background
            ),
          ),
        ),
        // Your actual overlay content
        const HelpFormOverlay(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  return overlayEntry; // Returns the OverlayEntry for external control (if needed)
}