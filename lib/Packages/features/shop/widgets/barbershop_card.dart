import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BarbershopCard extends StatefulWidget {
  final String title;
  final String workingHours;
  final String bottomLeftIconPath;
  final String bottomRightIconPath;
  final String middleRightIconPath;
  final String middleRightActiveIconPath;
  final String profilePicture;
  final Size size;
  final bool isClickable;
  final String shopLocation; // For maps navigation
  final double shopRating; // For rating display
  final VoidCallback? onCardTap; // For navigation to shop details
  final Function(bool)? onFavoriteChanged; // Callback for favorite state change

  const BarbershopCard({
    super.key,
    required this.title,
    required this.workingHours,
    required this.bottomLeftIconPath,
    required this.bottomRightIconPath,
    required this.middleRightIconPath,
    required this.middleRightActiveIconPath,
    required this.profilePicture,
    required this.size,
    required this.isClickable,
    required this.shopLocation,
    required this.shopRating,
    this.onCardTap,
    this.onFavoriteChanged,
  });

  @override
  State<BarbershopCard> createState() => _BarbershopCardState();
}

class _BarbershopCardState extends State<BarbershopCard>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.middleRightIconPath == widget.middleRightActiveIconPath;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _launchMaps() async {
    final String mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.shopLocation)}';
    final Uri uri = Uri.parse(mapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch maps')),
      );
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double currentRating = widget.shopRating;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate this Shop'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Rating: ${currentRating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            currentRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Here you would typically send the rating to your API
                    print('Rating submitted: $currentRating');
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rated $currentRating stars')),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Trigger animation
    if (_isFavorite) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    // Notify parent widget about favorite state change
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isClickable
          ? () {
        if (widget.onCardTap != null) {
          widget.onCardTap!();
        } else {
          print('Card tapped: ${widget.title}');
          // Default navigation behavior can be added here
        }
      }
          : null,
      child: Opacity(

        opacity: widget.isClickable ? 1.0 : 0.6,
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          decoration: ShapeDecoration(
            color: Color(0x4dffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(60),
                bottomLeft: const Radius.circular(60),
                topRight: const Radius.circular(10),
                bottomRight: const Radius.circular(10),
              ),
              side:BorderSide(
                strokeAlign: 1,
                color: Color(0xccffffff)
              ),
            ),
            // shadows: [
            //   const BoxShadow(
            //     color: Color(0x6699806C),
            //     blurRadius: 10,
            //     offset: Offset(5, 5),
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              // Profile Picture
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 115,
                  height: 115,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 115,
                          height: 115,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(widget.profilePicture),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(2, 2),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title
              Positioned(
                left: widget.size.width - 200,
                top: 10,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Montserrat Alternates',
                    fontWeight: FontWeight.w400,
                    height: 1.17,
                  ),
                ),
              ),

              // Working Hours
              Positioned(
                left: widget.size.width - 200,
                top: 38,
                child: Text(
                  widget.workingHours,
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

              // Middle Right Icon - Favorite with animation
              Positioned(
                left: widget.size.width + 10,
                top: 45,
                child: GestureDetector(
                  onTap: widget.isClickable ? _toggleFavorite : null,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        _isFavorite
                            ? widget.middleRightActiveIconPath
                            : widget.middleRightIconPath,
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Left Icon - Maps
              Positioned(
                left: widget.size.width - 200,
                top: widget.size.height - 36,
                child: GestureDetector(
                  onTap: widget.isClickable ? _launchMaps : null,
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: Image.asset(
                      widget.bottomLeftIconPath,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Bottom Right Icon - Rating with text
              Positioned(
                left: widget.size.width - 100,
                top: widget.size.height - 36,
                child: GestureDetector(
                  onTap: widget.isClickable ? _showRatingDialog : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        widget.bottomRightIconPath,
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.shopRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Non-clickable overlay
              if (!widget.isClickable)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(60),
                        bottomLeft: Radius.circular(60),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

