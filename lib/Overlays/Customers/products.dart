import 'package:flutter/material.dart';
// Import the next overlay in the sequence
import 'receipt.dart'; // Adjust this path

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying a list of products,
/// sliding up from the bottom center.
class ProductsOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const ProductsOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<ProductsOverlayContent> createState() => _ProductsOverlayContentState();
}

class _ProductsOverlayContentState extends State<ProductsOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int? _selectedProductIndex; // State to manage selected product

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

  // Helper to show the Receipt overlay after closing this one
  void _showReceiptOverlay() {
    Navigator.pop(context); // Close the current Products overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensure background is transparent
      builder: (BuildContext context) {
        return const ReceiptOverlayContent(); // Your receipt overlay
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
            height: 581,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xB2DFA8A4), // Original color from your snippet
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              shadows: [
                const BoxShadow(
                  color: Color(0x4C000000),
                  blurRadius: 20,
                  offset: Offset(5, 5),
                  spreadRadius: 0,
                ),
                const BoxShadow(
                  color: Color(0xFFFFFFFF),
                  blurRadius: 35,
                  offset: Offset(-10, -10),
                  spreadRadius: -10,
                )
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 87,
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center, // Changed to center for title
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Our Products',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontFamily: 'Montserrat Alternates',
                                  fontWeight: FontWeight.w400,
                                  height: 1.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26), // Spacing from original snippet
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 60, bottom: 50),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 30,
                            runSpacing: 100,
                            children: [
                              // Product Item 1
                              _buildProductItem(
                                index: 0,
                                itemName: 'Shampoo',
                                stock: 10,
                                price: 10,
                                imageUrl: "https://placehold.co/92x108?text=Shampoo", // Placeholder
                              ),
                              // Product Item 2
                              _buildProductItem(
                                index: 1,
                                itemName: 'Conditioner',
                                stock: 5,
                                price: 12,
                                imageUrl: "https://placehold.co/92x108?text=Cond", // Placeholder
                              ),
                              // Product Item 3
                              _buildProductItem(
                                index: 2,
                                itemName: 'Hair Gel',
                                stock: 15,
                                price: 8,
                                imageUrl: "https://placehold.co/92x108?text=Gel", // Placeholder
                              ),
                              // Product Item 4
                              _buildProductItem(
                                index: 3,
                                itemName: 'Hair Spray',
                                stock: 7,
                                price: 9,
                                imageUrl: "https://placehold.co/92x108?text=Spray", // Placeholder
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26), // Spacing before the button
                        // Add to Receipt Button
                        GestureDetector(
                          onTap: () {
                            _showReceiptOverlay(); // Proceed to receipt
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(10),
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.70),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 15,
                                    offset: const Offset(2, -2),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 122,
                                    child: Text(
                                      'Add to Receipt',
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
                                  const SizedBox(width: 10), // Spacing between text and icon
                                  SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage("https://placehold.co/25x25?text=Add"), // Placeholder icon
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

  // Helper widget to build each selectable product item
  Widget _buildProductItem({
    required int index,
    required String itemName,
    required int stock,
    required double price,
    required String imageUrl,
  }) {
    final bool isSelected = _selectedProductIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductIndex = index;
        });
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.only(
          top: 60,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFDFA8A4).withValues(alpha: 0.8) // Highlight selected
              : Colors.white.withValues(alpha: 0.40), // Use withOpacity
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.blueAccent : const Color(0x6699806C),
              blurRadius: isSelected ? 8 : 5,
              offset: const Offset(3, 3),
              spreadRadius: isSelected ? 2 : 0,
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Name
                Text(
                  itemName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    letterSpacing: 0.20,
                  ),
                ),
                const SizedBox(height: 10), // Spacing between name and details
                // Stock and Price
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Stock: $stock',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: 0.20,
                      ),
                    ),
                    const SizedBox(width: 65), // Spacing between Stock and Price
                    Text(
                      '$price JD',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: 0.20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Spacing before the gradient bar
                // Gradient Bar
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.00, 0.50),
                      end: Alignment(1.00, 0.50),
                      colors: [Color(0xFF036495), Color(0xFF269686), Color(0xFFC8DBC2)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
            // Image positioned at the top
            Positioned(
              left: 44, // Adjusted to be relative to the item container
              top: -60, // Adjusted to be relative to the item container
              child: Container(
                width: 92,
                height: 108,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Checkmark for selected item
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show this Products overlay
OverlayEntry showProductsOverlay(BuildContext context) {
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
        const ProductsOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}