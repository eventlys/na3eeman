import 'package:flutter/material.dart';
// You'll need to create this file next
import 'payment_options.dart'; // Adjust this path

const Duration _kOverlayAnimationDuration = Duration(milliseconds: 300);

/// A custom overlay widget displaying a receipt,
/// sliding up from the bottom center.
class ReceiptOverlayContent extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const ReceiptOverlayContent({super.key, this.onAnimationComplete});

  @override
  State<ReceiptOverlayContent> createState() => _ReceiptOverlayContentState();
}

class _ReceiptOverlayContentState extends State<ReceiptOverlayContent>
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

  // Helper to show the Payment Options overlay
  void _showPaymentOptionsOverlay() {
    Navigator.pop(context); // Close the current Receipt overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensure background is transparent
      builder: (BuildContext context) {
        return const PaymentOptionsOverlayContent(); // Your new payment options overlay
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
            width: 400, // Original width from your snippet
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              shadows: [
                BoxShadow(
                  color: const Color(0x6699806C),
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25), // Equivalent to original spacing: 25
                SizedBox(
                  width: 370,
                  child: Text(
                    'E-Receipt',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF99806C),
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25), // Equivalent to original spacing: 25
                Container(
                  width: double.infinity,
                  height: 240,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Barber',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Address',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, // Changed from w400 to w700 for consistency
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, // Changed from w400 to w700 for consistency
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Booking Date',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, // Changed from w400 to w700 for consistency
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Booking Time',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, // Changed from w400 to w700 for consistency
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 114,
                            child: Text(
                              'Staff', // Corrected from 'staff' to 'Staff' for consistency
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700, // Changed from w400 to w700 for consistency
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 50), // Spacing between columns
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              'Captain Barbershop',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              '123, main street, cairo',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              'Mohammed',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              '0100000000000',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              '13 Feb 2025',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              '18:00 AM',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15), // Equivalent to original spacing: 15
                          SizedBox(
                            width: 176,
                            child: Text(
                              'Ahmed',
                              style: TextStyle(
                                color: const Color(0xFF99806C),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.20,
                                shadows: [
                                  Shadow(offset: const Offset(1, 1), blurRadius: 2, color: const Color(0xFF000000).withValues(alpha: 0.25))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25), // Equivalent to original spacing: 25
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF99806C),
                          fontSize: 24,
                          fontFamily: 'Montserrat Alternates',
                          fontWeight: FontWeight.w400,
                          height: 1.17,
                          shadows: [
                            Shadow(offset: const Offset(1, 1), blurRadius: 2, color: Color(0xFF000000).withValues(alpha: 0.25))
                          ],
                        ),
                      ),
                      const SizedBox(width: 200), // Spacing between Total and amount
                      Text(
                        '50 \$',
                        style: TextStyle(
                          color: const Color(0xFF99806C),
                          fontSize: 24,
                          fontFamily: 'Montserrat Alternates',
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(offset: const Offset(1, 1), blurRadius: 2, color: Color(0xFF000000).withValues(alpha: 0.25))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25), // Spacing before the "Go to payment" button
                GestureDetector(
                  onTap: () {
                    _showPaymentOptionsOverlay(); // Call the function to open payment options
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                          image: NetworkImage("https://placehold.co/25x25?text=Pay"), // Placeholder icon
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10), // Spacing between icon and text
                          SizedBox(
                            width: 125,
                            child: Text(
                              'Go to payment',
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
}

// Helper function to show this Receipt overlay
OverlayEntry showReceiptOverlay(BuildContext context) {
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
        const ReceiptOverlayContent(),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}
