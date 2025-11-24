import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';
import '../../profile/widgets/custom_profile_avatar.dart';
import '../../profile/widgets/profile_avatar_style.dart';

class BarberData {
  final String image;
  final bool available;
  final String name;

  const BarberData({
    required this.image,
    required this.available,
    required this.name,
  });
}

// Horizontal profile list widget
class HorizontalBarberScroll extends StatelessWidget {
  final List<BarberData> barbers;
  final double avatarSize;
  final double spacing;

  const HorizontalBarberScroll({
    super.key,
    required this.barbers,
    this.avatarSize = 90,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 15.0),
            child: Text(
              'Our Barbers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
            ),
          ),
          // Horizontal scrollable profiles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: barbers.asMap().entries.map((entry) {
                final index = entry.key;
                final profile = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 15.0 : 0,
                    right: index < barbers.length - 1 ? spacing : 15.0,
                  ),
                  child: _buildProfileItem(profile, isDarkTheme),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BarberData barber, bool isDarkTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            MyProfileAvatar(
              imagePath: barber.image,
              size: avatarSize,
              style: MyProfileAvatarStyle(
                border: Border.all(
                  color: barber.available
                    ? (isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess)
                    : (isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          barber.name,
          style: TextStyle(
            color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.normal,
            height: 1.25,
            letterSpacing: 0.20,
          ),
        )
      ],
    );
  }
}
