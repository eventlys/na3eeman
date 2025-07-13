import 'package:flutter/material.dart';

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying payment options,
/// sliding up from the bottom center.
class PaymentOptionsOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const PaymentOptionsOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<PaymentOptionsOverlayContent> createState() => _PaymentOptionsOverlayContentState();
}

class _PaymentOptionsOverlayContentState extends State<PaymentOptionsOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  int? _selectedPaymentOptionIndex; // State to manage selected payment option

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

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400, // Original width from your snippet
            padding: const EdgeInsets.all(30),
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.70), // Use withOpacity
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0x3F000000),
                  blurRadius: 15,
                  offset: const Offset(2, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Visa option
                _buildPaymentOptionItem(
                  index: 0,
                  text: 'Visa',
                  iconUrl: "https://placehold.co/25x25?text=Visa", // Placeholder for Visa icon
                ),
                const SizedBox(height: 30), // Spacing between options

                // Cash option
                _buildPaymentOptionItem(
                  index: 1,
                  text: 'Cash',
                  iconUrl: "https://placehold.co/25x25?text=Cash", // Placeholder for Cash icon
                ),
                const SizedBox(height: 30), // Spacing between options

                // CliQ option
                _buildPaymentOptionItem(
                  index: 2,
                  text: 'CliQ',
                  iconUrl: "https://placehold.co/25x25?text=CliQ", // Placeholder for CliQ icon
                ),
                const SizedBox(height: 30), // Spacing before the Cancel button

                // Cancel button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close this payment options overlay
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
                          // Icon placeholder (rotated in original, but simple for now)
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
                                        image: NetworkImage("https://placehold.co/25x25?text=X"), // Placeholder for cancel icon
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10), // Spacing between icon and text
                          SizedBox(
                            width: 60, // Adjusted width for "Cancel" text
                            child: Text(
                              'Cancel',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build each selectable payment option row
  Widget _buildPaymentOptionItem({
    required int index,
    required String text,
    required String iconUrl,
  }) {
    final bool isSelected = _selectedPaymentOptionIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentOptionIndex = index;
          // In a real app, you would trigger the payment process here
          // based on the selected option.
        });
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 50),
        child: Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: isSelected
                ? const Color(0xFFB6B4B3).withValues(alpha: 0.9) // Highlight selected
                : Colors.white.withValues(alpha: 0.70), // Use withOpacity
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            shadows: [
              BoxShadow(
                color: isSelected ? Colors.blueAccent : const Color(0x3F000000),
                blurRadius: isSelected ? 15 : 15,
                offset: isSelected ? const Offset(2, 2) : const Offset(2, -2),
                spreadRadius: isSelected ? 2 : 0,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left icon
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
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(iconUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10), // Spacing between icon and text
              SizedBox(
                width: 250, // Fixed width for the text
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: 0.20,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Spacing before the right icon/checkmark
              // Right icon/checkmark
              SizedBox(
                width: 25,
                height: 25,
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.green, size: 20)
                    : const SizedBox.shrink(), // Empty stack replaced with empty SizedBox
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show this Payment Options overlay
OverlayEntry showPaymentOptionsOverlay(BuildContext context) {
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
        const PaymentOptionsOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}