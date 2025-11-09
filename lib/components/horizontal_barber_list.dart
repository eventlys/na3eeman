import 'package:flutter/material.dart';
import '../Packages/Widgets/custom_profile_avatar.dart';
import '../Theme/profile_avatar_style.dart';


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
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
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
                    right: index < barbers.length - 1 ? spacing : 0,
                  ),
                  child: _buildProfileItem(profile),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BarberData barber) {
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
                  color: barber.available ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          barber.name,
          style: const TextStyle(
            color: Color(0xffffffff),
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


