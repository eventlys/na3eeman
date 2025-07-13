import 'package:flutter/material.dart';

// You can define a constant for the animation duration.
const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying privacy and policy information,
/// sliding up from the bottom center.
class PrivacyPolicyOverlay extends StatefulWidget {
  // An optional callback for when the entrance animation finishes.
  final VoidCallback? onAnimationComplete;

  const PrivacyPolicyOverlay({super.key, this.onAnimationComplete});

  @override
  State<PrivacyPolicyOverlay> createState() => _PrivacyPolicyOverlayState();
}

class _PrivacyPolicyOverlayState extends State<PrivacyPolicyOverlay>
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
                  left: 30,
                  top: 67,
                  child: Column( // Using Column to vertically stack the "Privacy" and "Policy" containers
                    mainAxisSize: MainAxisSize.min, // Takes minimum vertical space
                    children: [
                      // --- Privacy Container ---
                      Container(
                        width: 380,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000), // Hex color with alpha 0x3F
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
                                children: [ // Removed 'spacing' from Row, use SizedBox for gaps
                                  const Text(
                                    'Privacy',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontFamily: 'Montserrat Alternates',
                                      fontWeight: FontWeight.w400,
                                      height: 1.13,
                                    ),
                                  ),
                                  SizedBox( // Replaced Container with SizedBox for fixed size icon placeholder
                                    width: 25,
                                    height: 25,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 25, // This positions the network image within the 25x25 SizedBox
                                          top: 0,
                                          child: Container(
                                            transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                                            height: 25,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/0x25"), // Placeholder image
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
                      const SizedBox(height: 20), // Spacer between the two main content boxes

                      // --- Policy Container ---
                      Container(
                        width: 380,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: Colors.white,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                children: [
                                  const Text(
                                    'Policy',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontFamily: 'Montserrat Alternates',
                                      fontWeight: FontWeight.w400,
                                      height: 1.13,
                                    ),
                                  ),
                                  SizedBox( // Replaced Container with SizedBox
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
                                            decoration: const BoxDecoration(
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
                // --- Top Left Image Container ---
                Positioned(
                  left: 140,
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
OverlayEntry showPrivacyPolicyOverlay(BuildContext context) {
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
              color: Colors.black.withValues(alpha: 0.30), // Semi-transparent black background
            ),
          ),
        ),
        // Your actual overlay content
        const PrivacyPolicyOverlay(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  return overlayEntry; // Returns the OverlayEntry for external control (if needed)
}