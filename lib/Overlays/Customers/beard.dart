import 'package:flutter/material.dart';
// You'll need to create this file next
import 'options.dart'; // Adjust this path

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying beard style options,
/// sliding up from the bottom center.
class BeardStyleOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const BeardStyleOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<BeardStyleOverlayContent> createState() => _BeardStyleOverlayContentState();
}

class _BeardStyleOverlayContentState extends State<BeardStyleOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int? _selectedImageIndex; // State to manage selected beard image

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _kOverlayAnimationDuration,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Starts fully off-screen at the bottom
      end: Offset.zero, // Ends at its natural position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward().whenComplete(() {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to show the Options overlay
  void _showOptionsOverlay() {
    Navigator.pop(context); // Close the current Beard Style overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensure background is transparent
      builder: (BuildContext context) {
        return const OptionsOverlayContent(); // Your new options overlay
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(bottom: 40),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xB24B8077), // Semi-transparent greenish color
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0x4CE0C7C9), // Adjusted to be a const Color
                  blurRadius: 8,
                  offset: const Offset(5, 5),
                  spreadRadius: 0,
                ),
                BoxShadow( // Second BoxShadow was missing a comma in original code
                  color: const Color(0x33BFA6A8), // Adjusted to be a const Color
                  blurRadius: 7,
                  offset: const Offset(-5, -5),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50), // Spacing from top, equivalent to original spacing: 50

                // Top buttons: Hair Style / Beard Style
                SizedBox(
                  width: 440,
                  height: 60,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 220,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            // No action needed if already on this tab
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Container(
                              width: 220,
                              height: 60, // Added height for consistency
                              padding: const EdgeInsets.symmetric(horizontal: 62, vertical: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.70), // Use withOpacity
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x6699806C),
                                    blurRadius: 5,
                                    offset: Offset(3, 3),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 96,
                                    child: Text(
                                      'Beard Style',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close current overlay
                            // Assuming you have a _showHairStyleOverlay function
                            // _showHairStyleOverlay(context);
                            // For now, just close. You'd need to pass a callback or use a global state for true switching.
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Container(
                              width: 220,
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 63, vertical: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.70),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x4CE0C7C9),
                                    blurRadius: 8,
                                    offset: Offset(5, 5),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color(0x33BFA6A8),
                                    blurRadius: 7,
                                    offset: Offset(-5, -5),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 94,
                                    child: Text(
                                      'Hair style', // Corrected typo
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50), // Spacing below the top buttons

                // Image selection section for beard styles
                SizedBox(
                  width: 400,
                  height: 230,
                  child: Stack(
                    children: [
                      _buildSelectableImage(
                        index: 0,
                        left: 0,
                        top: 51,
                        width: 90.14,
                        height: 128,
                        imageUrl: "https://placehold.co/90x128?text=Beard1",
                        isOval: false,
                      ),
                      _buildSelectableImage(
                        index: 1,
                        left: 102,
                        top: 17,
                        width: 196,
                        height: 196,
                        imageUrl: "https://placehold.co/196x196?text=Beard2",
                        isOval: true, // This one has the gradient and oval shape
                      ),
                      _buildSelectableImage(
                        index: 2,
                        left: 309.86,
                        top: 51,
                        width: 90.14,
                        height: 128,
                        imageUrl: "https://placehold.co/90x128?text=Beard3",
                        isOval: false,
                      ),
                      // This is the camera button placeholder
                      Positioned(
                        left: 151,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            // Implement camera opening logic here (e.g., using image_picker package)
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage("https://placehold.co/45x45?text=Cam"), // Replace with camera icon
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50), // Spacing before the "Confirm" button

                // "Confirm" button
                GestureDetector(
                  onTap: () {
                    _showOptionsOverlay(); // Call the function to switch overlays
                  },
                  child: ConstrainedBox(
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 69,
                            child: Text(
                              'Confirm',
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
                          SizedBox(width: 10), // Spacing between text and icon
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage("https://placehold.co/25x25?text=OK"), // Replace with actual icon
                                          fit: BoxFit.cover,
                                        ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for selectable images
  Widget _buildSelectableImage({
    required int index,
    required double left,
    required double top,
    required double width,
    required double height,
    required String imageUrl,
    required bool isOval,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedImageIndex = index;
          });
        },
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            shape: isOval
                ? const OvalBorder()
                : RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            shadows: [
              if (_selectedImageIndex == index) // Highlight selected image
                const BoxShadow(
                  color: Colors.blueAccent, // Highlight color
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              if (isOval) // Apply specific shadow for the oval image
                const BoxShadow(
                  color: Color(0x6699806C),
                  blurRadius: 5,
                  offset: Offset(3, 3),
                  spreadRadius: 0,
                ),
            ],
            gradient: isOval
                ? const LinearGradient(
              begin: Alignment(0.17, 0.08),
              end: Alignment(0.93, 0.93),
              colors: [Color(0xFFDFA8A3), Color(0x7FFAFBFC)],
            )
                : null,
          ),
        ),
      ),
    );
  }
}

// Helper function to show this Beard Style overlay
OverlayEntry showBeardStyleOverlay(BuildContext context) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),
        const BeardStyleOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}