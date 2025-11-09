import 'package:flutter/material.dart';

class ShopInfoSection extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ShopInfoSection({
    super.key,
    required this.shopData,
  });

  @override
  Widget build(BuildContext context) {
    final rating = shopData['shopRating'] ?? 0.0;
    final location = shopData['shopLocation'] ?? '';
    final workingHours = shopData['workingHours'] ?? '';

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.star,
            title: 'Rating',
            value: '$rating/5.0',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Location',
            value: location,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.access_time,
            title: 'Working Hours',
            value: workingHours,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFFFFFF), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

