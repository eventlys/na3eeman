import 'package:easy_localization/easy_localization.dart';
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
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../Core/constants/app_constants.dart';
import 'package:share_plus/share_plus.dart';

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
    final expertProvider = context.read<ExpertProvider>();
    final salonId = widget.salonData['id'] ?? widget.salonData['_id'];
    if (salonId != null) {
      final id = int.tryParse(salonId.toString());
      if (id != null) expertProvider.loadExperts(salonId: id);
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    final authProvider = context.read<AuthProvider>();
    if (!RolePermissionManager.canBookAppointments(
      authProvider.user?.userRole ?? UserRole.customer,
    )) {
      AppSnackBar.error(context, 'Staff members cannot book appointments');
      return;
    }

    setState(() {
      final name = service['name'] ?? service['serviceName'] ?? 'Service';
      if (_selectedServiceNames.contains(name)) {
        _selectedServiceNames.remove(name);
        _selectedServices.removeWhere(
          (s) => (s['name'] ?? s['serviceName'] ?? 'Service') == name,
        );
      } else {
        _selectedServiceNames.add(name);
        _selectedServices.add(service);
      }
    });
  }

  double _calculateTotalCost() {
    return _selectedServices.fold(0.0, (sum, service) {
      final priceStr = (service['price'] ?? '0').toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  int _calculateTotalDuration() {
    return _selectedServices.fold(0, (sum, service) {
      final durationStr = (service['duration'] ?? '30').toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      return sum + (int.tryParse(durationStr) ?? 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final salonName =
        widget.salonData['salonName'] ??
        widget.salonData['title'] ??
        'Salon Details';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Simple Header
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              salonName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.white),
            leading: const BackButton(color: AppColors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.white),
                onPressed: () {
                  AppSnackBar.success(context, "added_to_favorites".tr());
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.white),
                onPressed: () {
                  final link =
                      "${AppConstants.webAppUrl}/salon/${widget.salonData['id']}";
                  Share.share(
                    "check_out_this_salon".tr(args: [salonName, link]),
                  );
                },
              ),
              if (RolePermissionManager.canEditSalonInfo(
                context.read<AuthProvider>().user?.userRole ??
                    UserRole.customer,
              ))
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_salon',
                      arguments: {'salonData': widget.salonData},
                    );
                  },
                  tooltip: "edit_salon".tr(),
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
                    Text(
                      "catigories".tr(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ServicesSection(
                      selectedServiceNames: _selectedServiceNames,
                      onToggleService: _toggleService,
                      services: widget.salonData['services'] != null
                          ? List<Map<String, dynamic>>.from(
                              widget.salonData['services'],
                            )
                          : [],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Packages Section
              if (widget.salonData['packages'] != null &&
                  (widget.salonData['packages'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "packages".tr(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ServicesSection(
                        selectedServiceNames: _selectedServiceNames,
                        onToggleService: _toggleService,
                        services: List<Map<String, dynamic>>.from(
                          widget.salonData['packages'],
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.salonData['packages'] != null &&
                  (widget.salonData['packages'] as List).isNotEmpty)
                const SizedBox(height: 24),

              // Products Section
              if (widget.salonData['products'] != null &&
                  (widget.salonData['products'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "products".tr(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ServicesSection(
                        selectedServiceNames: _selectedServiceNames,
                        onToggleService: _toggleService,
                        services: List<Map<String, dynamic>>.from(
                          widget.salonData['products'],
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.salonData['products'] != null &&
                  (widget.salonData['products'] as List).isNotEmpty)
                const SizedBox(height: 24),

              // Offers and Groups Section
              if (widget.salonData['offers'] != null &&
                  (widget.salonData['offers'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "offers_and_groups".tr(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ServicesSection(
                        selectedServiceNames: _selectedServiceNames,
                        onToggleService: _toggleService,
                        services: List<Map<String, dynamic>>.from(
                          widget.salonData['offers'],
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.salonData['offers'] != null &&
                  (widget.salonData['offers'] as List).isNotEmpty)
                const SizedBox(height: 32),

              // Removed Feedback/Reviews section as requested
              const SizedBox(height: 16),

              const SizedBox(height: 48),
            ]),
          ),
        ],
      ),
      bottomNavigationBar:
          _selectedServices.isNotEmpty &&
              RolePermissionManager.canBookAppointments(
                context.watch<AuthProvider>().user?.userRole ??
                    UserRole.customer,
              )
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: "book_appointment".tr(),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/book_appointment',
                          arguments: {
                            'salonData': widget.salonData,
                            'selectedServices': _selectedServices,
                            'giftMode': widget.giftMode,
                            'giftGender': widget.giftGender,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
