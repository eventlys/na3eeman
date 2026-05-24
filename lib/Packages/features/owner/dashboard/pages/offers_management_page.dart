import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// Offer & Package Management page — WAJ + Fresha parity
/// Owner can create, view, and manage promotional offers and service packages.
class OffersManagementPage extends StatefulWidget {
  const OffersManagementPage({super.key});

  @override
  State<OffersManagementPage> createState() => _OffersManagementPageState();
}

class _OffersManagementPageState extends State<OffersManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _packages = [];
  bool _loadingOffers = true;
  bool _loadingPackages = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOffers();
    _loadPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => _loadingOffers = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final salonId = auth.user?.salonId ?? 1;
      final api = ApiService();
      final res = await api.get('/salons/$salonId/offers/');
      if (res is List) {
        setState(() {
          _offers = List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      } else if (res is Map && res['results'] is List) {
        setState(() {
          _offers = List<Map<String, dynamic>>.from(
            (res['results'] as List).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          );
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingOffers = false);
    }
  }

  Future<void> _loadPackages() async {
    setState(() => _loadingPackages = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final salonId = auth.user?.salonId ?? 1;
      final api = ApiService();
      final res = await api.get('/salons/$salonId/packages/');
      if (res is List) {
        setState(() {
          _packages = List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      } else if (res is Map && res['results'] is List) {
        setState(() {
          _packages = List<Map<String, dynamic>>.from(
            (res['results'] as List).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          );
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPackages = false);
    }
  }

  void _showAddOfferDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final originalCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Offer',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Offer Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Offer Price (JOD)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: originalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Original Price (JOD)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final salonId = auth.user?.salonId ?? 1;
                      final api = ApiService();
                      await api.post(
                        '/salons/$salonId/offers/',
                        data: {
                          'title': titleCtrl.text,
                          'description': descCtrl.text,
                          'price': double.tryParse(priceCtrl.text) ?? 0,
                          'original_price': double.tryParse(originalCtrl.text),
                        },
                      );
                      if (mounted)
                        AppSnackBar.success(context, 'Offer created!');
                      _loadOffers();
                    } catch (e) {
                      if (mounted) AppSnackBar.error(context, 'Error: $e');
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create Offer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offers & Packages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_offer_rounded), text: 'Offers'),
            Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Packages'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOfferDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Offer'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOffersList(theme), _buildPackagesList(theme)],
      ),
    );
  }

  Widget _buildOffersList(ThemeData theme) {
    if (_loadingOffers) return const Center(child: CircularProgressIndicator());
    if (_offers.isEmpty) {
      return _buildEmpty(
        theme,
        'No offers yet',
        'Create promotional offers to attract more customers',
        Icons.local_offer_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadOffers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _offers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _OfferCard(offer: _offers[i]),
      ),
    );
  }

  Widget _buildPackagesList(ThemeData theme) {
    if (_loadingPackages)
      return const Center(child: CircularProgressIndicator());
    if (_packages.isEmpty) {
      return _buildEmpty(
        theme,
        'No packages yet',
        'Create service bundles to increase your average order value',
        Icons.inventory_2_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPackages,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _packages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _PackageCard(package: _packages[i]),
      ),
    );
  }

  Widget _buildEmpty(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = offer['title'] as String? ?? '';
    final desc = offer['description'] as String? ?? '';
    final price = (offer['price'] as num?)?.toDouble() ?? 0.0;
    final original = (offer['original_price'] as num?)?.toDouble();
    final discount = original != null && original > 0
        ? ((1 - price / original) * 100).round()
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} JOD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    if (original != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${original.toStringAsFixed(2)} JOD',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = package['package_name'] as String? ?? '';
    final desc = package['package_description'] as String? ?? '';
    final price = (package['package_price'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${price.toStringAsFixed(2)} JOD',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
