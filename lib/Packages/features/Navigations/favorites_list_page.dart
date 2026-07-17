// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../Helpers/favorites_helper.dart';
import '../../../Providers/main_providers.dart';
import '../../Core/constants/app_color.dart';
import '../../Core/constants/app_images.dart';
import '../../Core/themes/app_scaffold.dart';
import '../../Core/themes/loading_indicator.dart';
import '../../Core/utils/helpers/refresh_widgets.dart';
import '../../Core/widgets/shared/error_widget.dart';
import '../salon/widgets/expert_salon_card.dart';
// import 'package:easy_localization/easy_localization.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    provider.loadFavorites(forceRefresh: true);
  }

  void _scrollListener() {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && !provider.isLoading) {
        _loadMoreData();
      }
    }
  }

  void _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    // Note: You might need to implement pagination in your provider
    // For now, we'll just refresh the data
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    await provider.loadFavorites(forceRefresh: true);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    await provider.loadFavorites(forceRefresh: true);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StandardPage(
      title: 'Favorite Salons',
      showBackButton: true,
      showAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllFavorites,
        backgroundColor: AppColor.secondary,
        child: ImageIcon(AssetImage(AppImages.trash), color: AppColor.light),
      ),
      actions: [
        IconButton(
          icon: ImageIcon(
            AssetImage(AppImages.refresh),
            color: isDark ? AppColor.darkText : AppColor.lightText,
          ),
          onPressed: _refreshData,
        ),
      ],
      user: null,
      child: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favoriteSalons.isEmpty) {
            return const Center(
              child: LoadingIndicator(
                message: 'Loading favorite salons...',
                size: 50,
              ),
            );
          }

          if (provider.error != null && provider.favoriteSalons.isEmpty) {
            return AppErrorWidget(
              message: 'Failed to load favorites: ${provider.error}',
              onRetry: _refreshData,
              showRetryButton: true,
            );
          }

          final List<Map<String, dynamic>> favoriteSalons =
              provider.favoriteSalons;

          if (favoriteSalons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage(AppImages.heart),
                    size: 64,
                    color:
                        (isDark
                                ? AppColor.darkTextSecondary
                                : AppColor.lightTextSecondary)
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite salons yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          (isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding salons to see them here!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          (isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to home/search
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.light,
                    ),
                    child: Text("explore_salons".tr()),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicatorWrapper(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSalons.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, int index) {
                if (index == favoriteSalons.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: LoadingIndicator(
                        size: 30,
                        color: AppColor.primary,
                      ),
                    ),
                  );
                }

                final Map<String, dynamic> salon = favoriteSalons[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpertSalonCard(
                    title: salon['salonName'] ?? 'Unknown Salon',
                    workingHours: salon['businessHours'] ?? '9:00 AM - 6:00 PM',
                    bottomLeftIconPath:
                        AppImages.location, // Use your location icon
                    bottomRightIconPath: AppImages.star, // Use your star icon
                    middleRightIconPath:
                        AppImages.heart, // Use your heart outline icon
                    middleRightActiveIconPath:
                        AppImages.heart, // Use your heart filled icon
                    profilePicture:
                        salon['image'] ??
                        AppImages.salon1, // Use your default salon image
                    size: const Size(350, 115), // Adjust size as needed
                    isClickable: true,
                    salonLocation: salon['address'] ?? '',
                    salonRating: FavoritesHelper.parseRating(salon['rating']),
                    onCardTap: () => _showSalonDetails(salon),
                    onFavoriteChanged: (isFavorite) {
                      if (!isFavorite) {
                        _removeFromFavorites(salon);
                      }
                      // Note: Since this is the favorites page, we only handle removal
                      // If isFavorite becomes true again, it means user toggled back
                      // but we should prevent that in the UI logic
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSalonDetails(Map<String, dynamic> salon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => DialogScaffold(
        backgroundColor: isDark ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (salon['image'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      salon['image']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    salon['salonName'] ?? 'Unknown Salon',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColor.darkText : AppColor.lightText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              AppImages.location,
              'Address',
              salon['address'] ?? 'Not available',
              isDark,
            ),
            const SizedBox(height: 12),
            if (salon['phone'] != null) ...[
              _buildDetailRow(
                AppImages.phone,
                'Phone',
                salon['phone']!,
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (salon['rating'] != null) ...[
              _buildDetailRow(
                AppImages.star,
                'Rating',
                salon['rating'].toStringAsFixed(1),
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (salon['totalReviews'] != null) ...[
              _buildDetailRow(
                AppImages.X_view,
                'Reviews',
                salon['totalReviews'].toString(),
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (salon['services'] != null && salon['services'] is List) ...[
              _buildDetailRow(
                AppImages.scissors,
                'Services',
                (salon['services'] as List).join(', '),
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (salon['businessHours'] != null) ...[
              _buildDetailRow(
                AppImages.clock,
                'Hours',
                salon['businessHours']!,
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            if (salon['description'] != null) ...[
              _buildDetailRow(
                AppImages.info,
                'Description',
                salon['description']!,
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _bookAppointment(salon),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.light,
                    ),
                    child: Text("book_appointment".tr()),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "close".tr(),
                    style: TextStyle(
                      color:
                          (isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String iconPath,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageIcon(AssetImage(iconPath), size: 20, color: AppColor.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      (isDark
                              ? AppColor.darkTextSecondary
                              : AppColor.lightTextSecondary)
                          .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColor.darkText : AppColor.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _removeFromFavorites(Map<String, dynamic> salon) async {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final salonId = salon['id'].toString();
    final salonName = salon['salonName'] ?? 'this salon';

    try {
      final success = await provider.removeFromFavorites(salonId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Removed $salonName from favorites',
              style: const TextStyle(color: AppColor.light),
            ),
            backgroundColor: AppColor.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove from favorites: $e',
              style: const TextStyle(color: AppColor.light),
            ),
            backgroundColor: AppColor.secondary,
          ),
        );
      }
    }
  }

  void _clearAllFavorites() {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.favoriteSalons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No favorites to clear',
            style: TextStyle(color: AppColor.light),
          ),
          backgroundColor: AppColor.primary,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => DialogScaffold(
        backgroundColor: isDark ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: 16,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clear All Favorites',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppColor.darkText : AppColor.lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to remove all ${provider.favoritesCount} salons from your favorites?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    (isDark
                            ? AppColor.darkTextSecondary
                            : AppColor.lightTextSecondary)
                        .withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "cancel".tr(),
                    style: TextStyle(
                      color:
                          (isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await provider.clearFavorites();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cleared all favorites',
                              style: TextStyle(color: AppColor.light),
                            ),
                            backgroundColor: AppColor.primary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to clear favorites: $e',
                              style: TextStyle(color: AppColor.light),
                            ),
                            backgroundColor: AppColor.secondary,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _bookAppointment(Map<String, dynamic> salon) {
    Navigator.of(context).pop(); // Close the details dialog
    // Navigate to booking page or show booking dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Book appointment at ${salon['salonName'] ?? 'salon'}',
          style: TextStyle(color: AppColor.light),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }
}
