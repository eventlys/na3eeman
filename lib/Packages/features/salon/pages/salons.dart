import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/expert_salon_card.dart';

class SalonListPage extends StatefulWidget {
  const SalonListPage({super.key});

  @override
  State<SalonListPage> createState() => _SalonListPageState();
}

class _SalonListPageState extends State<SalonListPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _salons = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSalons = [];

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

      final response = await _apiService.getSalons(page: 1, limit: 20);
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
            onPressed: () {}, // Filter dialog
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
              onChanged: (value) {
                setState(() {
                  _filteredSalons = _salons.where((salon) {
                    final name = (salon['salonName'] ?? salon['title'] ?? '')
                        .toString()
                        .toLowerCase();
                    final location =
                        (salon['salonLocation'] ?? salon['location'] ?? '')
                            .toString()
                            .toLowerCase();
                    final query = value.toLowerCase();
                    return name.contains(query) || location.contains(query);
                  }).toList();
                });
              },
            ),
          ),

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
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ExpertSalonCard(
            title: salon['salonName'] ?? salon['title'] ?? 'Unknown',
            workingHours: salon['workingHours'] ?? '9:00 AM - 9:00 PM',
            profilePicture: 'assets/images/salon_placeholder.png',
            isClickable: true,
            salonLocation:
                salon['salonLocation'] ?? salon['location'] ?? 'Downtown',
            salonRating: (salon['salonRating'] as num?)?.toDouble() ?? 4.5,
            onCardTap: () => Navigator.pushNamed(
              context,
              '/salon_details',
              arguments: salon,
            ),
            onFavoriteChanged: (isFav) {
              // Handle favorite
            },
          ),
        );
      },
    );
  }
}
