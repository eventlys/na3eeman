import 'package:flutter/material.dart';
import '../../Theme/profile_avatar_style.dart';


class MyProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final String? title;
  final MyProfileAvatarStyle? style;

  const MyProfileAvatar({
    super.key,
    this.imagePath,
    required this.size,
    this.title,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar Circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: style?.color ?? Colors.grey.shade300,
            borderRadius: BorderRadius.circular(size / 2),
            border: style?.border,
            boxShadow: [
              BoxShadow(
                color: const Color(0x6699806C),
                blurRadius: 10,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),

        // Title (if provided)
        if (title != null) ...[
          const SizedBox(height: 8),
          Text(
            title!,
            style: style?.titleStyle ?? const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (imagePath != null) {
      // Network image
      if (imagePath!.startsWith('http')) {
        return Image.network(
          imagePath!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
      // Asset image
      else {
        return Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: style?.color ?? Colors.blue,
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}
