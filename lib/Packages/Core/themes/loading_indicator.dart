import 'package:flutter/material.dart';
import '../constants/app_color.dart';
import '../utils/helpers/themes_helpers.dart';
import 'app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool useSkeleton;
  final UserGender? gender;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.message,
    this.useSkeleton = false,
    this.gender,
  });

  const LoadingIndicator.small({
    super.key,
    this.size = 20,
    this.color,
    this.message,
    this.useSkeleton = false,
    this.gender,
  });

  const LoadingIndicator.skeleton({
    super.key,
    this.size = 40,
    this.color,
    this.message,
    this.useSkeleton = true,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    if (useSkeleton) {
      return _buildSkeletonLoader(context, isDark, gender);
    }

    return _buildTraditionalLoader(context, isDark, gender, color);
  }

  Widget _buildTraditionalLoader(BuildContext context, bool isDark, UserGender? gender, Color? customColor) {
    Color loaderColor = customColor ?? _getLoaderColor(context, isDark, gender);
    
    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 30 ? 3 : 2,
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size > 30 ? 3 : 2,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, bool isDark, UserGender? gender) {
    final Color baseColor = _getSkeletonBaseColor(isDark, gender);
    final Color highlightColor = _getSkeletonHighlightColor(isDark, gender);
    
    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSkeletonCircle(size, baseColor, highlightColor, isDark),
          const SizedBox(height: 8),
          _buildSkeletonText(message!, baseColor, highlightColor, context, isDark),
        ],
      );
    }

    return _buildSkeletonCircle(size, baseColor, highlightColor, isDark);
  }

  Widget _buildSkeletonCircle(double size, Color baseColor, Color highlightColor, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
                tileMode: TileMode.mirror,
                transform: const GradientRotation(0.78),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              color: isDark ? AppColor.darkCard : AppColor.lightCard,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonText(String text, Color baseColor, Color highlightColor, BuildContext context, bool isDark) {
    final textWidth = _calculateTextWidth(text, context);
    
    return Container(
      width: textWidth,
      height: 16,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.0, 0.5, 1.0],
            tileMode: TileMode.mirror,
            transform: const GradientRotation(0.78),
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          color: isDark ? AppColor.darkCard : AppColor.lightCard,
        ),
      ),
    );
  }

  Color _getLoaderColor(BuildContext context, bool isDark, UserGender? gender) {
    if (gender != null) {
      return _getGenderPrimaryColor(gender, isDark);
    }
    
    // Default colors based on theme
    return isDark ? AppColor.loadingPrimaryDark : AppColor.loadingPrimaryLight;
  }

  Color _getGenderPrimaryColor(UserGender gender, bool isDark) {
    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
      case UserGender.female:
        return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
      case UserGender.nonBinary:
        return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
    }
  }

  Color _getSkeletonBaseColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      return _getGenderSkeletonBaseColor(gender, isDark);
    }
    
    return isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight;
  }

  Color _getSkeletonHighlightColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      return _getGenderSkeletonHighlightColor(gender, isDark);
    }
    
    return isDark ? AppColor.skeletonHighlightDark : AppColor.skeletonHighlightLight;
  }

  Color _getGenderSkeletonBaseColor(UserGender gender, bool isDark) {
    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBackground : AppColor.maleBackground;
      case UserGender.female:
        return isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground;
      case UserGender.nonBinary:
        return isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground;
    }
  }

  Color _getGenderSkeletonHighlightColor(UserGender gender, bool isDark) {
    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
      case UserGender.female:
        return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
      case UserGender.nonBinary:
        return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
    }
  }

  double _calculateTextWidth(String text, BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    return textPainter.width;
  }
}

// Skeleton loading widget for list items with gender support
class SkeletonListLoader extends StatelessWidget {
  final int itemCount;
  final bool isDark;
  final UserGender? gender;

  const SkeletonListLoader({
    super.key,
    this.itemCount = 3,
    required this.isDark,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = _getSkeletonBaseColor(isDark, gender);
    final Color highlightColor = _getSkeletonHighlightColor(isDark, gender);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? null : Border.all(color: AppColor.lightTextHint.withValues(alpha: 0.1)),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
                tileMode: TileMode.mirror,
                transform: const GradientRotation(0.78),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.darkCard : AppColor.lightCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle skeleton
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.darkCard : AppColor.lightCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Tags skeleton
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark ? AppColor.darkCard : AppColor.lightCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark ? AppColor.darkCard : AppColor.lightCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSkeletonBaseColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return isDark ? AppColor.darkMaleBackground : AppColor.maleBackground;
        case UserGender.female:
          return isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground;
        case UserGender.nonBinary:
          return isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground;
      }
    }
    
    return isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight;
  }

  Color _getSkeletonHighlightColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
        case UserGender.female:
          return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
        case UserGender.nonBinary:
          return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
      }
    }
    
    return isDark ? AppColor.skeletonHighlightDark : AppColor.skeletonHighlightLight;
  }
}

// Skeleton loading widget for cards with gender support
class SkeletonCardLoader extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;
  final UserGender? gender;
  final BorderRadiusGeometry borderRadius;

  const SkeletonCardLoader({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    required this.isDark,
    this.gender,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = _getSkeletonBaseColor(isDark, gender);
    final Color highlightColor = _getSkeletonHighlightColor(isDark, gender);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius,
        border: isDark ? null : Border.all(color: AppColor.lightTextHint.withValues(alpha: 0.1)),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.0, 0.5, 1.0],
            tileMode: TileMode.mirror,
            transform: const GradientRotation(0.78),
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          color: isDark ? AppColor.darkCard : AppColor.lightCard,
        ),
      ),
    );
  }

  Color _getSkeletonBaseColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return isDark ? AppColor.darkMaleBackground : AppColor.maleBackground;
        case UserGender.female:
          return isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground;
        case UserGender.nonBinary:
          return isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground;
      }
    }
    
    return isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight;
  }

  Color _getSkeletonHighlightColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
        case UserGender.female:
          return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
        case UserGender.nonBinary:
          return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
      }
    }
    
    return isDark ? AppColor.skeletonHighlightDark : AppColor.skeletonHighlightLight;
  }
}
