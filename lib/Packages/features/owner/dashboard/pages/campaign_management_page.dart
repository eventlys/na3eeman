import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Providers/features/offers_provider.dart';
import '../../../../../Providers/features/owner_provider.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../Models/salon/offer_model.dart';
import '../../../../../Models/salon/ad_campaign_model.dart';
import '../../widgets/campaign_management_widgets.dart';
class CampaignManagementPage extends StatefulWidget {
  const CampaignManagementPage({super.key});

  @override
  State<CampaignManagementPage> createState() => _CampaignManagementPageState();
}

class _CampaignManagementPageState extends State<CampaignManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonId = context.read<OwnerProvider>().activeSalonId;
      if (salonId != null) {
        context.read<OffersProvider>().loadCampaigns(salonId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();
    final offersProvider = context.watch<OffersProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("active_campaigns".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Active Campaigns'),
            Tab(text: 'Performance Analytics'),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveCampaignsList(offersProvider, owner),
          _buildPerformanceAnalytics(offersProvider, owner),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CampaignManagement.showCampaignModal(context, onRefresh: () {
           if (owner.activeSalonId != null) {
             offersProvider.loadCampaigns(owner.activeSalonId!);
           }
        }),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveCampaignsList(OffersProvider provider, OwnerProvider owner) {
    final allItems = [...provider.offers, ...provider.adCampaigns];
    return _buildList(
      provider: provider,
      owner: owner,
      items: allItems,
    );
  }

  Widget _buildPerformanceAnalytics(OffersProvider provider, OwnerProvider owner) {
    final allItems = [...provider.offers, ...provider.adCampaigns];
    if (allItems.isEmpty) {
       return const Center(child: Text('No active campaigns to analyze'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return _buildAnalyticsCard(item);
      },
    );
  }

  Widget _buildAnalyticsCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item is OfferModel ? item.title : item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Impressions', '1.2k'),
              _buildStat('Clicks', '420'),
              _buildStat('Conversions', '15'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _confirmDeleteItem(BuildContext context, OffersProvider provider, int salonId, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (item is OfferModel) {
                await provider.deleteOffer(salonId, item.id);
              } else if (item is AdCampaignModel) {
                await provider.deleteAdCampaign(salonId, item.id);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildList({required OffersProvider provider, required OwnerProvider owner, required List<dynamic> items}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: AppColors.almostBlack200),
            const SizedBox(height: 16),
            const Text('No active items in this category', style: TextStyle(color: AppColors.almostBlack300)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isActive = item.isActive;

        return _CampaignItem(
          title: item is OfferModel ? item.title : item.name,
          subtitle: item is OfferModel ? item.description : item.details,
          isActive: isActive,
          onToggle: (val) async {
            if (owner.activeSalonId != null) {
              if (item is OfferModel) {
                await provider.toggleOfferStatus(owner.activeSalonId!, item.id, val);
              } else if (item is AdCampaignModel) {
                await provider.toggleAdStatus(owner.activeSalonId!, item.id, val);
              }
            }
          },
          onDelete: () => _confirmDeleteItem(context, provider, owner.activeSalonId!, item),
        );
      },
    );
  }

  void _confirmDeleteOffer(BuildContext context, OffersProvider provider, int salonId, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteOffer(salonId, id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAd(BuildContext context, OffersProvider provider, int salonId, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteAdCampaign(salonId, id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CampaignItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const _CampaignItem({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                onPressed: onDelete,
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: isActive ? AppColors.success : Colors.grey, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Active' : 'Inactive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isActive ? AppColors.success : Colors.grey)),
                ],
              ),
              Switch.adaptive(
                value: isActive,
                onChanged: onToggle,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
