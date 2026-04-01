import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ShopInfoSection extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ShopInfoSection({
    super.key,
    required this.shopData,
  });

  @override
  Widget build(BuildContext context) {
    final rating = (shopData['shopRating'] as num?)?.toDouble() ?? 4.5;
    final location = shopData['shopLocation'] ?? shopData['location'] ?? 'Jordan';
    final workingHours = shopData['workingHours'] ?? '9:00 AM - 9:00 PM';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('shop_details'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            context: context,
            icon: Icons.location_on_rounded,
            title: 'location'.tr().tr(),
            subTitle: location,
            iconColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context: context,
            icon: Icons.access_time_filled_rounded,
            title: 'working_hours'.tr(),
            subTitle: workingHours,
            iconColor: AppColors.pink,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context: context,
            icon: Icons.phone_rounded,
            title: 'phone'.tr().tr(),
            subTitle: shopData['shopPhoneNumber'] ?? shopData['phoneNumber'] ?? 'Click for info',
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subTitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.almostBlack400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
