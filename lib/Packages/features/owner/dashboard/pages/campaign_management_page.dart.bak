import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:easy_localization/easy_localization.dart';
import '../../../../../Providers/features/offers_provider.dart';
import '../../../../../Providers/features/owner_provider.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/buttons/styled_buttons.dart';
import '../../widgets/campaign_management_widgets.dart';

class CampaignManagementPage extends StatefulWidget {
  const CampaignManagementPage({super.key});

  @override
  State<CampaignManagementPage> createState() => _CampaignManagementPageState();
}

class _CampaignManagementPageState extends State<CampaignManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonId = context.read<OwnerProvider>().activeSalonId;
      if (salonId != null) {
        context.read<OffersProvider>().loadCampaigns(salonId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();
    final offersProvider = context.watch<OffersProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activeCampaigns, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => CampaignManagement.showCampaignModal(context, onRefresh: () {
               if (owner.activeSalonId != null) {
                 offersProvider.loadCampaigns(owner.activeSalonId!);
               }
            }),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (owner.activeSalonId != null) {
            await offersProvider.loadCampaigns(owner.activeSalonId!);
          }
        },
        child: offersProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, offersProvider, owner),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OffersProvider provider, OwnerProvider owner) {
    if (provider.offers.isEmpty && provider.adCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: AppColors.almostBlack200),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noActiveCampaigns, style: TextStyle(color: AppColors.almostBlack300)),
            const SizedBox(height: 24),
            PrimaryButton(
              text: AppLocalizations.of(context)!.createPromotion,
              onPressed: () => CampaignManagement.showCampaignModal(context, onRefresh: () {
                 if (owner.activeSalonId != null) {
                   provider.loadCampaigns(owner.activeSalonId!);
                 }
              }),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (provider.offers.isNotEmpty) ...[
          _SectionHeader(title: AppLocalizations.of(context)!.offers.toUpperCase()),
          const SizedBox(height: 12),
          ...provider.offers.map((offer) => _CampaignItem(
            title: offer.title,
            subtitle: offer.description,
            status: 'Active',
            statusColor: AppColors.success,
            actionText: offer.validityPeriod,
            onDelete: () => _confirmDeleteOffer(context, provider, owner.activeSalonId!, offer.id),
          )),
          const SizedBox(height: 24),
        ],
        if (provider.adCampaigns.isNotEmpty) ...[
          _SectionHeader(title: AppLocalizations.of(context)!.ads.toUpperCase()),
          const SizedBox(height: 12),
          ...provider.adCampaigns.map((ad) => _CampaignItem(
            title: ad.name,
            subtitle: ad.details,
            status: 'Running',
            statusColor: AppColors.blue,
            actionText: '${ad.durationDays} Days Left',
            onDelete: () => _confirmDeleteAd(context, provider, owner.activeSalonId!, ad.id),
          )),
        ],
      ],
    );
  }

  void _confirmDeleteOffer(BuildContext context, OffersProvider provider, int salonId, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Offer?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteOffer(salonId, id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAd(BuildContext context, OffersProvider provider, int salonId, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Campaign?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteAdCampaign(salonId, id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.almostBlack300,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _CampaignItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String actionText;
  final VoidCallback onDelete;

  const _CampaignItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.actionText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              Text(actionText, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
