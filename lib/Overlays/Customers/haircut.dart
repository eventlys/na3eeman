import 'package:flutter/material.dart';

// Your current overlay content
class HairStyleOverlayContent extends StatefulWidget {
  const HairStyleOverlayContent({super.key});

  @override
  State<HairStyleOverlayContent> createState() => _HairStyleOverlayContentState();
}

class _HairStyleOverlayContentState extends State<HairStyleOverlayContent> {
  // You might want to manage selected image state here
  int? _selectedImageIndex; // Example for selecting an image

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xB24B8077),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Using SizedBox for spacing as 'spacing' is not a direct Column property
          const SizedBox(height: 50), // Adjust as needed for top spacing

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
                      // Action for Beard Style button
                      Navigator.pop(context); // Close current overlay
                      _showBeardStyleOverlay(context); // Open beard style overlay
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 50),
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(horizontal: 62, vertical: 20),
                        decoration: ShapeDecoration(
                          color: Colors.white.withValues(alpha: 0.70),
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
                      // Action for Hair Style button
                      // No need to close and reopen if already on hair style
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

          // Image selection section
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
                  imageUrl: "https://placehold.co/90x128",
                  isOval: false,
                ),
                _buildSelectableImage(
                  index: 1,
                  left: 102,
                  top: 17,
                  width: 196,
                  height: 196,
                  imageUrl: "https://placehold.co/196x196",
                  isOval: true, // This one has the gradient and oval shape
                ),
                _buildSelectableImage(
                  index: 2,
                  left: 309.86,
                  top: 51,
                  width: 90.14,
                  height: 128,
                  imageUrl: "https://placehold.co/90x128",
                  isOval: false,
                ),
                // This is the camera button, currently just an image, would need to implement camera logic
                Positioned(
                  left: 151,
                  top: 10,
                  child: GestureDetector(
                    onTap: () {
                      // Implement camera opening logic here
                      // e.g., using image_picker package
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://placehold.co/45x45"), // Replace with camera icon
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50), // Spacing before the "I like it" button

          // "I like it" button
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close current overlay
              // You might want to pass the selected image/style to the next overlay or parent widget
              // For example: Navigator.pop(context, _selectedImageIndex);
              _showBeardStyleOverlay(context); // Open the next overlay
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
                      width: 54,
                      child: Text(
                        'I like it',
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
                                    image: NetworkImage("https://placehold.co/25x25"), // Replace with actual icon
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
    );
  }

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

// Placeholder for your Beard Style Overlay Content
class BeardStyleOverlayContent extends StatelessWidget {
  const BeardStyleOverlayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xB24B8077), // Same style or different
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Your Beard Style',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Add your beard style selection widgets here
          // For example, a GridView of beard style images
          const Text('Beard style options go here...'),
          // Button to close this overlay
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Function to show the first overlay
void showHairStyleOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to take full height if needed
    builder: (BuildContext context) {
      return const HairStyleOverlayContent();
    },
  );
}

// Function to show the beard style overlay
void _showBeardStyleOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const BeardStyleOverlayContent();
    },
  );
}

// To trigger the initial overlay (e.g., from a button on your main screen)
// ElevatedButton(
//   onPressed: () => showHairStyleOverlay(context),
//   child: const Text('Open Hair/Beard Style Selector'),
// ),