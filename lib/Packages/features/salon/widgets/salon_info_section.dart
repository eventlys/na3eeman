import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SalonInfoSection extends StatelessWidget {
  final Map<String, dynamic> salonData;

  const SalonInfoSection({super.key, required this.salonData});

  @override
  Widget build(BuildContext context) {
    final rating = (salonData['salonRating'] as num?)?.toDouble() ?? 4.5;
    final location =
        salonData['salonLocation'] ?? salonData['location'] ?? 'Jordan';
    final workingHours = salonData['workingHours'] ?? '9:00 AM - 9:00 PM';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.almostBlack50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
              Text(
                "salon_details".tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
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
            title: "location".tr(),
            subTitle: location,
            iconColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context: context,
            icon: Icons.access_time_filled_rounded,
            title: "working_hours".tr(),
            subTitle: workingHours,
            iconColor: AppColors.pink,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          _buildInfoRow(
            context: context,
            icon: Icons.phone_rounded,
            title: "phone".tr(),
            subTitle:
                salonData['salonPhoneNumber'] ??
                salonData['phoneNumber'] ??
                'Click for info',
            iconColor: AppColors.success,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openMap(location),
              icon: const Icon(Icons.map_outlined),
              label: Text("show_on_map".tr()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(String location) async {
    final query = Uri.encodeComponent(location);
    final googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    final iosUrl = "http://maps.apple.com/?q=$query";

    try {
      if (Platform.isIOS) {
        final iosUri = Uri.parse(iosUrl);
        // Try apple maps first
        if (await canLaunchUrl(iosUri)) {
          await launchUrl(iosUri);
        } else {
          await launchUrl(
            Uri.parse(googleUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        await launchUrl(
          Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not launch map: $e');
    }
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
            color: iconColor.withValues(alpha: 0.1),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
