import 'package:flutter/material.dart';

// You might want to define some constants or enums if these values are used elsewhere.
// For example, the duration of the animation.
const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget that pops up from the bottom center.
class CustomBottomOverlay extends StatefulWidget {
  const CustomBottomOverlay({super.key});

  @override
  State<CustomBottomOverlay> createState() => _CustomBottomOverlayState();
}

class _CustomBottomOverlayState extends State<CustomBottomOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _kOverlayAnimationDuration,
    );

    // The animation starts from an offset where the overlay is completely below the screen
    // and moves to Offset.zero (its original position).
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Starts fully off-screen at the bottom
      end: Offset.zero, // Ends at its natural position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // You can choose a different curve for the animation
    ));

    // Start the animation to show the overlay when it's initialized.
    _animationController.forward();
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
        alignment: Alignment.bottomCenter, // Aligns the child to the bottom center
        child: Material( // Wrap in Material to avoid rendering issues if this is directly used in an overlay
          color: Colors.transparent, // Make Material transparent
          child: Container(
            width: 440,
            height: 525,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.40), // Use withOpacity for clarity
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              shadows: const [
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
                  left: 30,
                  top: 67,
                  child: Column( // Changed to Column for the two main stacked containers
                    children: [
                      // The 'Terms' Container
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
                          children: [ // Removed spacing as it's not a direct property of Column
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
                                children: [ // Removed spacing from Row
                                  const Text(
                                    'Terms',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontFamily: 'Montserrat Alternates',
                                      fontWeight: FontWeight.w400,
                                      height: 1.13,
                                    ),
                                  ),
                                  SizedBox( // Replaced Container with SizedBox for fixed size
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
                      const SizedBox(height: 20), // Add some space between the two main containers
                      // The 'Conditions' Container
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
                          children: [ // Removed spacing from Column
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
                                children: [ // Removed spacing from Row
                                  const Text(
                                    'Conditions',
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
                Positioned(
                  left: 140,
                  top: -120, // This positions it relative to the main Container, not the stack above
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
                                image: NetworkImage("https://placehold.co/100x100"),
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

// Helper function to show the overlay
void showCustomBottomOverlay(BuildContext context) {
  OverlayEntry? overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => GestureDetector(
      onTap: () {
        // Optionally, dismiss the overlay when tapping outside it
        overlayEntry?.remove();
      },
      child: const CustomBottomOverlay(),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}