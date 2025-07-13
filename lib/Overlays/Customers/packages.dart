import 'package:flutter/material.dart';
// Import the new Products overlay
import 'products.dart'; // Adjust this path

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying various packages,
/// sliding up from the bottom center.
class PackagesOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const PackagesOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<PackagesOverlayContent> createState() => _PackagesOverlayContentState();
}

class _PackagesOverlayContentState extends State<PackagesOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int? _selectedPackageIndex; // State to manage selected package

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

  // Helper to show the Products overlay after closing this one
  void _showProductsOverlay() {
    // Close the current Packages overlay
    Navigator.pop(context);

    // Then open the new Products overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensure background is transparent
      builder: (BuildContext context) {
        return const ProductsOverlayContent(); // Your new products overlay
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
              color: const Color(0xFF806C99), // Purple-ish color
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
                // Package Option 1
                _buildPackageItem(index: 0, text: 'Package 1'),
                const SizedBox(height: 20), // Manual spacing
                // Package Option 2
                _buildPackageItem(index: 1, text: 'Package 2'),
                const SizedBox(height: 20), // Manual spacing
                // Package Option 3
                _buildPackageItem(index: 2, text: 'Package 3'),
                const SizedBox(height: 20), // Manual spacing
                // Package Option 4
                _buildPackageItem(index: 3, text: 'Package 4'),
                const SizedBox(height: 20), // Manual spacing
                // Package Option 5
                _buildPackageItem(index: 4, text: 'Package 5'),
                const SizedBox(height: 50), // Spacing before the "All good" button

                // "All good" button
                GestureDetector(
                  onTap: () {
                    _showProductsOverlay(); // Call the function to open products overlay
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

  // Helper widget to build each selectable package item row
  Widget _buildPackageItem({required int index, required String text}) {
    final bool isSelected = _selectedPackageIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageIndex = index;
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

// Helper function to show this Packages overlay
OverlayEntry showPackagesOverlay(BuildContext context) {
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
        const PackagesOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}