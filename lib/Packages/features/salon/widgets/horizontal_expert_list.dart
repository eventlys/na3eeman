import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';
import '../../profile/widgets/custom_profile_avatar.dart';
import '../../profile/widgets/profile_avatar_style.dart';

class ExpertData {
  final String image;
  final bool available;
  final String name;

  const ExpertData({
    required this.image,
    required this.available,
    required this.name,
  });
}

class HorizontalExpertScroll extends StatelessWidget {
  final List<ExpertData> experts;
  final double avatarSize;
  final double spacing;

  const HorizontalExpertScroll({
    super.key,
    required this.experts,
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
            child: Text("our_experts".tr(),
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
              children: experts.asMap().entries.map((entry) {
                final index = entry.key;
                final profile = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 15.0 : 0,
                    right: index < experts.length - 1 ? spacing : 15.0,
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

  Widget _buildProfileItem(ExpertData expert, bool isDarkTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            MyProfileAvatar(
              imagePath: expert.image,
              size: avatarSize,
              style: MyProfileAvatarStyle(
                border: Border.all(
                  color: expert.available
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
          expert.name,
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
