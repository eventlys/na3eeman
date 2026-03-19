import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class OffersCard extends StatelessWidget {
  const OffersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final offers = [
      {'title': 'Summer Special', 'discount': '20%', 'expiry': '5 days left'},
      {'title': 'New Customer', 'discount': '15%', 'expiry': 'Ongoing'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: AppColors.pink),
                  SizedBox(width: 8),
                  Text(
                    'Active Offers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).primaryColor),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...offers.map((offer) => _buildOfferRow(offer, isDark)),
        ],
      ),
    );
  }

  Widget _buildOfferRow(Map<String, dynamic> offer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pink.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                offer['expiry'] as String,
                style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              offer['discount'] as String,
              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
