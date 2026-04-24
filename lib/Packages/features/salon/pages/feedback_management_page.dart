import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../../Services/api/api_service.dart';
import '../../../../../Services/api/endpoints.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class FeedbackManagementPage extends StatefulWidget {
  const FeedbackManagementPage({super.key});

  @override
  State<FeedbackManagementPage> createState() => _FeedbackManagementPageState();
}

class _FeedbackManagementPageState extends State<FeedbackManagementPage> {
  String _selectedFilter = 'Most Recent';
  final List<String> _filters = ['Most Recent', 'Top 5 Best', 'Top 5 Worst'];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      // Fetch reviews. Assume Endpoints.reviews loads all linked to current salon/owner context
      final response = await apiService.get(Endpoints.reviews);
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      setState(() {
        _reviews = data.map((r) {
          final customer = r['customer'] as Map<String, dynamic>?;
          return {
            'id': r['id']?.toString() ?? '',
            'customerName': customer != null ? '${customer['first_name']} ${customer['last_name']}' : 'Anonymous',
            'rating': (r['rating'] ?? 5).toDouble(),
            'comment': r['comment'] ?? 'No comment provided.',
            'date': r['created_at'] != null ? DateTime.parse(r['created_at']) : DateTime.now(),
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredReviews() {
    List<Map<String, dynamic>> sorted = List.from(_reviews);
    if (_selectedFilter == 'Most Recent') {
      sorted.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    } else if (_selectedFilter == 'Top 5 Best') {
      sorted.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
      return sorted.take(5).toList();
    } else if (_selectedFilter == 'Top 5 Worst') {
      sorted.sort((a, b) => (a['rating'] as double).compareTo(b['rating'] as double));
      return sorted.take(5).toList();
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredReviews = _getFilteredReviews();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customerFeedback, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardSectionHeader(title: AppLocalizations.of(context)!.feedbackReviews),
                  const SizedBox(height: 12),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: filteredReviews.isEmpty 
                        ? Center(child: Text(AppLocalizations.of(context)!.noReviewsFound))
                        : ListView.builder(
                            itemCount: filteredReviews.length,
                            itemBuilder: (context, index) {
                              final review = filteredReviews[index];
                              return _buildReviewCard(review, isDark);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, bool isDark) {
    final rating = review['rating'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review['customerName'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'] as String,
            style: TextStyle(color: isDark ? AppColors.cream600 : AppColors.almostBlack400),
          ),
        ],
      ),
    );
  }
}
