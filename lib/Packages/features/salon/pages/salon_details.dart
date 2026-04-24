import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/role_permission_manager.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../Core/constants/app_roles.dart';
import '../widgets/salon_gallary.dart';
import '../widgets/salon_info_section.dart';
import '../widgets/services_section.dart';
import 'package:easy_localization/easy_localization.dart';

class SalonDetailsPage extends StatefulWidget {
  final Map<String, dynamic> salonData;
  final bool giftMode;
  final String? giftGender;

  const SalonDetailsPage({
    super.key,
    required this.salonData,
    this.giftMode = false,
    this.giftGender,
  });

  @override
  State<SalonDetailsPage> createState() => _SalonDetailsPageState();
}

class _SalonDetailsPageState extends State<SalonDetailsPage> {
  final Set<String> _selectedServiceNames = {};
  final List<Map<String, dynamic>> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _loadData() {
    final barberProvider = context.read<BarberProvider>();
    final salonId = widget.salonData['id'] ?? widget.salonData['_id'];
    if (salonId != null) {
      final id = int.tryParse(salonId.toString());
      if (id != null) barberProvider.loadBarbers(salonId: id);
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    final authProvider = context.read<AuthProvider>();
    if (!RolePermissionManager.canBookAppointments(authProvider.user?.role ?? UserRole.customer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff members cannot book appointments')),
      );
      return;
    }
    
    setState(() {
      final name = service['name'] ?? service['serviceName'] ?? 'Service';
      if (_selectedServiceNames.contains(name)) {
        _selectedServiceNames.remove(name);
        _selectedServices.removeWhere((s) => (s['name'] ?? s['serviceName'] ?? 'Service') == name);
      } else {
        _selectedServiceNames.add(name);
        _selectedServices.add(service);
      }
    });
  }

  double _calculateTotalCost() {
    return _selectedServices.fold(0.0, (sum, service) {
      final priceStr = (service['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  int _calculateTotalDuration() {
    return _selectedServices.fold(0, (sum, service) {
      final durationStr = (service['duration'] ?? '30').toString().replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(durationStr) ?? 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final salonName = widget.salonData['salonName'] ?? widget.salonData['title'] ?? 'Salon Details';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsing Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                salonName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/salon_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            leading: const BackButton(color: AppColors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addedToFavorites)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.shareDialogOpened)));
                },
              ),
              if (RolePermissionManager.canEditSalonInfo(context.read<AuthProvider>().user?.role ?? UserRole.customer))
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: AppColors.white),
                  onPressed: () {
                     Navigator.pushNamed(context, '/edit_salon', arguments: {'salonData': widget.salonData});
                  },
                  tooltip: AppLocalizations.of(context)!.editSalon,
                ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              
              // Salon Gallery
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ModernSalonGallery(
                  imageCount: 4,
                  salonId: (widget.salonData['id'] ?? '').toString(),
                  imageUrls: widget.salonData['images'] != null
                      ? List<String>.from(widget.salonData['images'])
                      : null,
                ),
              ),

              const SizedBox(height: 32),

              // Info Section
              SalonInfoSection(salonData: widget.salonData),

              const SizedBox(height: 32),

              // Services Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.catigories,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ServicesSection(
                      selectedServiceNames: _selectedServiceNames,
                      onToggleService: _toggleService,
                      services: widget.salonData['services'] != null
                          ? List<Map<String, dynamic>>.from(widget.salonData['services'])
                          : [
                              {'name': 'Classic Haircut', 'price': '15.00', 'duration': '30 min'},
                              {'name': 'Beard Grooming', 'price': '10.00', 'duration': '20 min'},
                              {'name': 'Premium Shave', 'price': '20.00', 'duration': '40 min'},
                            ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Packages Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.packages,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text(AppLocalizations.of(context)!.packagesAndBundlesComingSoon),
                      leading: Icon(Icons.card_giftcard),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Products Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.products,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text(AppLocalizations.of(context)!.salonProductsCatalogComingSoon),
                      leading: Icon(Icons.shopping_bag_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Offers and Groups Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.offersGroups,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text(AppLocalizations.of(context)!.exclusiveOffersComingSoon),
                      leading: Icon(Icons.local_offer_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Feedback/Reviews Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.salonFeedback,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 30),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.key485, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.key120Reviews, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.almostBlack600 : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.almostBlack50),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.ahmedM, style: TextStyle(fontWeight: FontWeight.bold)),
                              Spacer(),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.greatServiceCompletelyTransformedMyLookHighl),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.feedbackEntryDialog)));
                      },
                      icon: const Icon(Icons.rate_review),
                      label: Text(AppLocalizations.of(context)!.addYourFeedback),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 48),

            ]),
          ),
        ],
      ),
      bottomNavigationBar: _selectedServices.isNotEmpty && RolePermissionManager.canBookAppointments(context.watch<AuthProvider>().user?.role ?? UserRole.customer) ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedServices.length} Services Selected',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Total: \$${_calculateTotalCost().toStringAsFixed(2)} | ${_calculateTotalDuration()} min',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: AppLocalizations.of(context)!.bookAppointment,
                onPressed: () {
                  Navigator.pushNamed(context, '/book_appointment', arguments: {
                    'salonData': widget.salonData,
                    'selectedServices': _selectedServices,
                    'giftMode': widget.giftMode,
                    'giftGender': widget.giftGender,
                  });
                },
              ),
            ],
          ),
        ),
      ) : const SizedBox.shrink(),
    );
  }
}
