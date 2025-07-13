import 'package:flutter/material.dart';

import 'packages.dart';

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying various options,
/// sliding up from the bottom center.
class OptionsOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const OptionsOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<OptionsOverlayContent> createState() => _OptionsOverlayContentState();
}

class _OptionsOverlayContentState extends State<OptionsOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int? _selectedOptionIndex; // State to manage selected option

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

  // Helper to show the Packages overlay
  void _showPackagesOverlay() {
    Navigator.pop(context); // Close the current Options overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensure background is transparent
      builder: (BuildContext context) {
        return const PackagesOverlayContent(); // Your new packages overlay
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
            width: 440,
            height: 665,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xB2DFA8A4), // Semi-transparent reddish color
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Option 1
                _buildOptionItem(index: 0, text: 'Option 1'),
                const SizedBox(height: 20), // Manual spacing
                // Option 2
                _buildOptionItem(index: 1, text: 'Option 2'),
                const SizedBox(height: 20), // Manual spacing
                // Option 3
                _buildOptionItem(index: 2, text: 'Option 3'),
                const SizedBox(height: 20), // Manual spacing
                // Option 4
                _buildOptionItem(index: 3, text: 'Option 4'),
                const SizedBox(height: 20), // Manual spacing
                // Option 5
                _buildOptionItem(index: 4, text: 'Option 5'),
                const SizedBox(height: 50), // Spacing before the "All good" button

                // "All good" button
                GestureDetector(
                  onTap: () {
                    _showPackagesOverlay(); // Call the function to switch overlays
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 50),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: Colors.white.withValues(alpha: 0.70), // Use withOpacity
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
                              'All good',
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
                                          image: NetworkImage("https://placehold.co/25x25?text=OK"), // Placeholder icon
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

  // Helper widget to build each selectable option row
  Widget _buildOptionItem({required int index, required String text}) {
    final bool isSelected = _selectedOptionIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        decoration: ShapeDecoration(
          color: isSelected
              ? const Color(0xFFB6B4B3).withValues(alpha: 0.9) // Highlight selected
              : Colors.white.withValues(alpha: 0.70), // Use withOpacity
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          shadows: [
            BoxShadow(
              color: isSelected ? Colors.blueAccent : const Color(0x6699806C),
              blurRadius: isSelected ? 8 : 5,
              offset: const Offset(3, 3),
              spreadRadius: isSelected ? 2 : 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 162,
              height: 29,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Montserrat Alternates',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 138), // Manual spacing
            Container(
              width: 40,
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: isSelected ? Colors.green : const Color(0xFFB6B4B3), // Change color when selected
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: isSelected ? Colors.green : const Color(0xFFB6B4B3),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20) // Checkmark icon
                  : const SizedBox.shrink(), // Empty stack replaced with empty SizedBox
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show this Options overlay
OverlayEntry showOptionsOverlay(BuildContext context) {
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
        const OptionsOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}