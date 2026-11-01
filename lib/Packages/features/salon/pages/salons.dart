import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/salon_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../widgets/expert_salon_card.dart';

class SalonListPage extends StatefulWidget {
  const SalonListPage({super.key});

  @override
  State<SalonListPage> createState() => _SalonListPageState();
}

class _SalonListPageState extends State<SalonListPage> {
  List<Map<String, dynamic>> _salons = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSalons = [];

  final List<String> _servicesFilters = [
    "All",
    "Haircut",
    "Beard Grooming",
    "Shave",
    "Massage",
    "Nails",
    "Coloring",
  ];
  final List<String> _selectedServices = [];
  String? _selectedDistance;
  String? _selectedRating;
  String? _selectedPrice;

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await context.read<SalonProvider>().getSalonsRaw(
        page: 1,
        limit: 20,
      );
      final List<dynamic> data = response is List
          ? response
          : (response['results'] ??
                response['data'] ??
                response['salons'] ??
                []);
      final salonsList = data.map((e) => Map<String, dynamic>.from(e)).toList();

      if (mounted) {
        setState(() {
          _salons = salonsList;
          _filteredSalons = List.from(_salons);
          _isLoading = false;
          if (_salons.isEmpty) {
            _error = "no_salons_found_nearby".tr();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load salons. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "discover_salons".tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButtonStyled(
            icon: Icons.filter_list_rounded,
            onPressed: _showFilterDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "search_by_name_or_location".tr(),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                filled: true,
                fillColor: isDark ? AppColors.almostBlack600 : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),

          _buildServicesSlider(),
          const SizedBox(height: 16),

          // Content
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SecondaryButton(
              text: "retry".tr(),
              onPressed: _loadSalons,
              width: 120,
            ),
          ],
        ),
      );
    }

    if (_filteredSalons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.almostBlack200,
            ),
            const SizedBox(height: 16),
            Text(
              "no_salons_found_nearby".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredSalons.length,
      itemBuilder: (context, index) {
        final salon = _filteredSalons[index];
        return FadeSlideIn(
          index: index,
          interval: const Duration(milliseconds: 70),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ExpertSalonCard(
              title: salon['salonName'] ?? salon['title'] ?? 'Unknown',
              workingHours: salon['workingHours'] ?? '9:00 AM - 00:00 AM',
              profilePicture:
                  salon['images'] != null &&
                      (salon['images'] as List).isNotEmpty
                  ? salon['images'][0].toString()
                  : (salon['salon_logo'] != null
                        ? 'assets/salons/${salon['salon_logo'].toString().split('/').last}'
                        : 'assets/logos/salon10.png'),
              isClickable: true,
              salonLocation:
                  salon['salonLocation'] ?? salon['location'] ?? 'Downtown',
              salonRating: (salon['salonRating'] as num?)?.toDouble() ?? 4.5,
              onCardTap: () => Navigator.pushNamed(
                context,
                '/salon_details',
                arguments: {'salonData': salon},
              ),
              onFavoriteChanged: (isFav) {
                // Handle favorite
              },
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredSalons = _salons.where((salon) {
        bool match = true;

        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          final name = (salon['salonName'] ?? salon['title'] ?? '')
              .toString()
              .toLowerCase();
          final location = (salon['salonLocation'] ?? salon['location'] ?? '')
              .toString()
              .toLowerCase();
          if (!name.contains(query) && !location.contains(query)) {
            match = false;
          }
        }

        // New AND logic for multiple services
        if (_selectedServices.isNotEmpty) {
          final salonServices = salon['services'] as List<dynamic>? ?? [];
          final hasAllServices = _selectedServices.every((selectedService) {
            final selectedServiceLower = selectedService.toLowerCase();
            return salonServices.any((s) {
                  final serviceName =
                      (s['name'] ?? s['serviceName'] ?? s['title'] ?? '')
                          .toString()
                          .toLowerCase();
                  return serviceName.contains(selectedServiceLower);
                }) ||
                (salon['salonName'] ?? salon['title'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(selectedServiceLower);
          });
          if (!hasAllServices) {
            match = false;
          }
        }

        if (_selectedRating != null) {
          final rating =
              double.tryParse(salon['salonRating']?.toString() ?? '4.5') ?? 4.5;
          final filterRating = double.tryParse(_selectedRating!) ?? 0;
          if (rating < filterRating) {
            match = false;
          }
        }

        return match;
      }).toList();
    });
  }

  Widget _buildServicesSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _servicesFilters.length,
        itemBuilder: (context, index) {
          final service = _servicesFilters[index];

          if (service == "All") {
            final isSelected = _selectedServices.isEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text("all_services".tr()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedServices.clear();
                      _applyFilters();
                    }
                  });
                },
                backgroundColor: isDark
                    ? AppColors.almostBlack600
                    : AppColors.almostBlack50,
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          final isSelected = _selectedServices.contains(service);
          final key = 'service_${service.toLowerCase().replaceAll(' ', '_')}';
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(key.tr()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                  _applyFilters();
                });
              },
              backgroundColor: isDark
                  ? AppColors.almostBlack600
                  : AppColors.almostBlack50,
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("filter_options".tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "distance".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["1km", "2km", "5km", "10km"].map((dist) {
                        return ChoiceChip(
                          label: Text(dist),
                          selected: _selectedDistance == dist,
                          onSelected: (val) {
                            setDialogState(
                              () => _selectedDistance = val ? dist : null,
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "rating".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["5", "4", "3", "2", "1", "0"].map((rating) {
                        return ChoiceChip(
                          label: Text("$rating \u2605"),
                          selected: _selectedRating == rating,
                          onSelected: (val) {
                            setDialogState(
                              () => _selectedRating = val ? rating : null,
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "price_level".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["\$", "\$\$", "\$\$\$"].map((price) {
                        return ChoiceChip(
                          label: Text(price),
                          selected: _selectedPrice == price,
                          onSelected: (val) {
                            setDialogState(
                              () => _selectedPrice = val ? price : null,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedDistance = null;
                      _selectedRating = null;
                      _selectedPrice = null;
                    });
                    setState(() {});
                    _applyFilters();
                  },
                  child: Text("reset_filters".tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text("apply_filters".tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
