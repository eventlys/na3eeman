import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';

class ExpertSalonCard extends StatefulWidget {
  final String title;
  final String workingHours;
  final String profilePicture;
  final bool isClickable;
  final String salonLocation;
  final double salonRating;
  final VoidCallback? onCardTap;
  final Function(bool)? onFavoriteChanged;
  final bool initialIsFavorite;

  const ExpertSalonCard({
    super.key,
    required this.title,
    required this.workingHours,
    required this.profilePicture,
    required this.isClickable,
    required this.salonLocation,
    required this.salonRating,
    this.onCardTap,
    this.onFavoriteChanged,
    this.initialIsFavorite = false,
    Size? size,
  });

  @override
  State<ExpertSalonCard> createState() => _ExpertSalonCardState();
}

class _ExpertSalonCardState extends State<ExpertSalonCard>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _launchMaps() async {
    final String mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.salonLocation)}';
    final Uri uri = Uri.parse(mapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        AppSnackBar.error(context, "could_not_launch_maps".tr());
      }
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    widget.onFavoriteChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.isClickable ? widget.onCardTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isClickable ? 1.0 : 0.6,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(20), // 2xl rounded
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.1)
                  : AppColors.almostBlack100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              // Salon Profile Picture
              Hero(
                tag: 'salon_image_${widget.title}_${widget.salonLocation}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.profilePicture.startsWith('http')
                      ? Image.network(
                          widget.profilePicture,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              child: Icon(
                                Icons.store_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          widget.profilePicture,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              child: Icon(
                                Icons.store_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Salon Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.workingHours,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location info
                        GestureDetector(
                          onTap: widget.isClickable ? _launchMaps : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.salonLocation.length > 15
                                      ? '${widget.salonLocation.substring(0, 12)}...'
                                      : widget.salonLocation,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            Text(
                              widget.salonRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Action
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.isClickable ? _toggleFavorite : null,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? AppColors.pink50
                          : AppColors.almostBlack50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite
                          ? AppColors.pink
                          : AppColors.almostBlack300,
                      size: 22,
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
