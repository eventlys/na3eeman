import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../Providers/main_providers.dart';
import '../../Core/constants/app_color.dart';
import '../../Core/constants/app_images.dart';
import '../../Core/themes/app_scaffold.dart';
import '../../Core/themes/loading_indicator.dart';
import '../../Core/utils/helpers/refresh_widgets.dart';
import '../../Core/widgets/shared/error_widget.dart';
import '../salon/widgets/expert_card.dart';
// import 'package:easy_localization/easy_localization.dart';

class ExpertsListPage extends StatefulWidget {
  const ExpertsListPage({super.key});

  @override
  State<ExpertsListPage> createState() => _ExpertsListPageState();
}

class _ExpertsListPageState extends State<ExpertsListPage> {
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
    final provider = Provider.of<ExpertProvider>(context, listen: false);
    provider.refreshExperts();
  }

  void _scrollListener() {
    final provider = Provider.of<ExpertProvider>(context, listen: false);

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && provider.hasMore && !provider.isLoading) {
        _loadMoreData();
      }
    }
  }

  void _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    final provider = Provider.of<ExpertProvider>(context, listen: false);
    await provider.loadExperts();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<ExpertProvider>(context, listen: false);
    await provider.refreshExperts();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StandardPage(
      title: 'Experts',
      showBackButton: true,
      showAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewExpert,
        backgroundColor: AppColor.primary,
        child: ImageIcon(AssetImage(AppImages.plus), color: AppColor.light),
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
      user: null, // Add your user object here if needed
      child: Consumer<ExpertProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.experts.isEmpty) {
            return const Center(
              child: LoadingIndicator(message: 'Loading experts...', size: 50),
            );
          }

          if (provider.error != null && provider.experts.isEmpty) {
            return AppErrorWidget(
              message: 'Failed to load experts: ${provider.error}',
              onRetry: _refreshData,
              showRetryButton: true,
            );
          }

          final List<dynamic> experts = provider.experts;

          if (experts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage(AppImages.avatar_male),
                    size: 64,
                    color:
                        (isDark
                                ? AppColor.darkTextSecondary
                                : AppColor.lightTextSecondary)
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No experts found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          (isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary)
                              .withValues(alpha: 0.7),
                    ),
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
              itemCount: experts.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, int index) {
                if (index == experts.length) {
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

                final dynamic expert = experts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpertCard(
                    expertId: expert.id,
                    onTap: () => _showExpertDetails(expert),
                    onEdit: () => _editExpert(expert),
                    onDelete: () => _deleteExpert(expert),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showExpertDetails(dynamic expert) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expertName = expert.name;
    final email = expert.email;
    final phone = expert.phone;
    final rating = expert.rating;
    final totalAppointments = expert.totalAppointments;
    final specialties = expert.specialties;
    final hourlyRate = expert.hourlyRate;
    final lastActive = expert.lastActive;
    final profileImage = expert.profileImage;

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
                if (profileImage != null) ...[
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    expertName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColor.darkText : AppColor.lightText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(AppImages.mail, 'Email', email, isDark),
            const SizedBox(height: 12),
            _buildDetailRow(AppImages.phone, 'Phone', phone, isDark),
            const SizedBox(height: 12),
            _buildDetailRow(
              AppImages.star,
              'Rating',
              rating.toStringAsFixed(1),
              isDark,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              AppImages.calender,
              'Total Appointments',
              totalAppointments.toString(),
              isDark,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              AppImages.scissors,
              'Specialties',
              specialties.join(', '),
              isDark,
            ),
            if (hourlyRate != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                AppImages.money,
                'Hourly Rate',
                '\$${hourlyRate.toStringAsFixed(2)}',
                isDark,
              ),
            ],
            if (lastActive != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                AppImages.clock,
                'Last Active',
                _formatDate(lastActive),
                isDark,
              ),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "close".tr(),
                  style: TextStyle(color: AppColor.primary),
                ),
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _addNewExpert() {
    // Implement add new expert functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add new expert functionality',
          style: TextStyle(color: AppColor.light),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  void _editExpert(dynamic expert) {
    final expertName = expert.name;
    // Implement edit expert functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit $expertName',
          style: TextStyle(color: AppColor.light),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  void _deleteExpert(dynamic expert) {
    final provider = Provider.of<ExpertProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expertName = expert.name;
    final expertId = expert.id;

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
              'Delete Expert',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppColor.darkText : AppColor.lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete $expertName?',
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
                      await provider.deleteExpert(expertId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully deleted $expertName',
                            style: TextStyle(color: AppColor.light),
                          ),
                          backgroundColor: AppColor.primary,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete $expertName: $e',
                            style: TextStyle(color: AppColor.light),
                          ),
                          backgroundColor: AppColor.secondary,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "delete".tr(),
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
}
