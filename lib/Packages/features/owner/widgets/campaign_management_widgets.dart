import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/offers_provider.dart';
import '../../../../Providers/features/owner_provider.dart';
import '../../../../Models/salon/offer_model.dart';
import '../../../../Models/salon/ad_campaign_model.dart';
import '../../../../Models/salon/package_model.dart';
import '../../../../core/theme/colors.dart';

class CampaignManagement {
  static void showCampaignModal(
    BuildContext context, {
    VoidCallback? onRefresh,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "create_promotion".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildModalActionButton(
              context,
              Icons.local_offer_rounded,
              'create_offer'.tr(),
              AppColors.blue,
              () {
                Navigator.pop(context);
                showCreateOfferDialog(context, onRefresh: onRefresh);
              },
            ),
            const SizedBox(height: 12),
            _buildModalActionButton(
              context,
              Icons.ads_click_rounded,
              'create_ads'.tr(),
              AppColors.pink,
              () {
                Navigator.pop(context);
                showCreateAdDialog(context, onRefresh: onRefresh);
              },
            ),
            const SizedBox(height: 12),
            _buildModalActionButton(
              context,
              Icons.inventory_2_rounded,
              'create_package'.tr(),
              AppColors.success,
              () {
                Navigator.pop(context);
                showCreatePackageDialog(context, onRefresh: onRefresh);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static void showCreateOfferDialog(
    BuildContext context, {
    VoidCallback? onRefresh,
  }) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    DateTimeRange? selectedRange;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "create_offer".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogField(
                  'offer_title_name'.tr(),
                  controller: titleController,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  'price_usd'.tr(),
                  keyboard: TextInputType.number,
                  controller: priceController,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  'description'.tr(),
                  controller: descController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  "validity_period".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (range != null) {
                      setDialogState(() => selectedRange = range);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.almostBlack300.withValues(alpha:0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedRange != null
                                ? '${selectedRange!.start.toString().split(' ')[0]} ${"to".tr()} ${selectedRange!.end.toString().split(' ')[0]}'
                                : 'select_date_range'.tr(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("cancel".tr()),
            ),
            Consumer<OffersProvider>(
              builder: (context, provider, _) => ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final salonId = context
                            .read<OwnerProvider>()
                            .activeSalonId;
                        if (salonId != null) {
                          final offer = OfferModel(
                            id: 0,
                            title: titleController.text,
                            description: descController.text,
                            price: priceController.text,
                            validityPeriod: selectedRange != null
                                ? '${selectedRange!.start.toIso8601String().split('T')[0]} ${"to".tr()} ${selectedRange!.end.toIso8601String().split('T')[0]}'
                                : 'limited_time'.tr(),
                            salonId: salonId,
                            salonName: '',
                          );
                          provider.clearError();
                          await provider.createOffer(salonId, offer);

                          if (context.mounted) {
                            if (provider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('offer_created_success'.tr()),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              if (onRefresh != null) onRefresh();
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(100, 40),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("create".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showCreateAdDialog(
    BuildContext context, {
    VoidCallback? onRefresh,
  }) {
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final detailsController = TextEditingController();
    final pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "create_ad".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(
                'campaign_name'.tr(),
                controller: nameController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'duration_days_label'.tr(),
                keyboard: TextInputType.number,
                controller: durationController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'reward_points'.tr(),
                keyboard: TextInputType.number,
                controller: pointsController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'details_text'.tr(),
                maxLines: 2,
                controller: detailsController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          Consumer<OffersProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final salonId = context
                          .read<OwnerProvider>()
                          .activeSalonId;
                      if (salonId != null) {
                        final ad = AdCampaignModel(
                          id: 0,
                          name: nameController.text,
                          details: detailsController.text,
                          durationDays:
                              int.tryParse(durationController.text) ?? 7,
                          rewardPoints:
                              int.tryParse(pointsController.text) ?? 100,
                          salonId: salonId,
                        );
                        provider.clearError();
                        await provider.createAdCampaign(salonId, ad);

                        if (context.mounted) {
                          if (provider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('campaign_launched_success'.tr()),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (onRefresh != null) onRefresh();
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(100, 40),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text("launch".tr()),
            ),
          ),
        ],
      ),
    );
  }

  static void showCreatePackageDialog(
    BuildContext context, {
    VoidCallback? onRefresh,
  }) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final servicesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "create_package".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(
                'package_name'.tr(),
                controller: nameController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'package_price_usd'.tr(),
                keyboard: TextInputType.number,
                controller: priceController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'package_description'.tr(),
                maxLines: 2,
                controller: descController,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                'services_comma_separated'.tr(),
                maxLines: 2,
                controller: servicesController,
              ),
              const SizedBox(height: 8),
              Text(
                'note_enter_services'.tr(),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          Consumer<OffersProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          descController.text.trim().isEmpty ||
                          priceController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final salonId = context
                          .read<OwnerProvider>()
                          .activeSalonId;
                      if (salonId != null) {
                        final package = PackageModel(
                          id: 0,
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          price: priceController.text.trim(),
                          salonId: salonId,
                          includedServices: servicesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        );
                        provider.clearError();
                        await provider.createPackage(salonId, package);

                        if (context.mounted) {
                          if (provider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('package_created_success'.tr()),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (onRefresh != null) onRefresh();
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(100, 40),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text("create".tr()),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModalActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  static Widget _buildDialogField(
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
