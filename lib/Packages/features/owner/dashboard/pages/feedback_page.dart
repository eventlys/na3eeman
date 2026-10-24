import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Providers/features/owner_provider.dart';
import '../../../../../Models/salon/review_model.dart';
import '../../../../../core/theme/colors.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _isLoading = true;
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final salonId = context.read<OwnerProvider>().activeSalonId;
      if (salonId != null) {
        final reviews = await context.read<OwnerProvider>().getSalonReviews(
          salonId,
        );
        double total = 0;
        for (var r in reviews) {
          total += r.rating;
        }
        setState(() {
          _reviews = reviews;
          _averageRating = reviews.isNotEmpty ? total / reviews.length : 0.0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No active salon selected.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load reviews: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "feedback".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadReviews, child: Text("retry".tr())),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.almostBlack200,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet.',
              style: TextStyle(color: AppColors.almostBlack300),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.almostBlack600
                  : AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _averageRating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _reviews.length.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('total_reviews'.tr()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(review.createdAt),
                style: TextStyle(color: AppColors.almostBlack300, fontSize: 12),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
