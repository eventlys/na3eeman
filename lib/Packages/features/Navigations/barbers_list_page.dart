import 'package:na3eeman/l10n/app_localizations.dart';
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
import '../salon/widgets/barber_card.dart';
// import 'package:easy_localization/easy_localization.dart';

class BarbersListPage extends StatefulWidget {
  const BarbersListPage({super.key});

  @override
  State<BarbersListPage> createState() => _BarbersListPageState();
}

class _BarbersListPageState extends State<BarbersListPage> {
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
    final provider = Provider.of<BarberProvider>(context, listen: false);
    provider.refreshBarbers();
  }

  void _scrollListener() {
    final provider = Provider.of<BarberProvider>(context, listen: false);

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

    final provider = Provider.of<BarberProvider>(context, listen: false);
    await provider.loadBarbers();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<BarberProvider>(context, listen: false);
    await provider.refreshBarbers();
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    _loadMoreData();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StandardPage(
      title: 'Barbers',
      showBackButton: true,
      showAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBarber,
        backgroundColor: AppColor.primary,
        child: ImageIcon(
          AssetImage(AppImages.plus),
          color: AppColor.light,
        ),
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
      child: Consumer<BarberProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.barbers.isEmpty) {
            return const Center(
              child: LoadingIndicator(
                message: 'Loading barbers...',
                size: 50,
              ),
            );
          }

          if (provider.error != null && provider.barbers.isEmpty) {
            return AppErrorWidget(
              message: 'Failed to load barbers: ${provider.error}',
              onRetry: _refreshData,
              showRetryButton: true,
            );
          }

          final List<dynamic> barbers = provider.barbers;

          if (barbers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage(AppImages.avatar_male),
                    size: 64,
                    color: (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No barbers found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary).withValues(alpha: 0.7),
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
              itemCount: barbers.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, int index) {
                if (index == barbers.length) {
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

                final dynamic barber = barbers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: BarberCard(
                    barberId: barber['id'] ?? barber['_id'] ?? '',
                    onTap: () => _showBarberDetails(barber),
                    onEdit: () => _editBarber(barber),
                    onDelete: () => _deleteBarber(barber),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showBarberDetails(dynamic barber) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barberName = barber['name'] ?? 'Unknown Barber';
    final email = barber['email'] ?? 'No email';
    final phone = barber['phone'] ?? 'No phone';
    final rating = (barber['rating'] ?? 0.0).toDouble();
    final totalAppointments = barber['totalAppointments'] ?? 0;
    final specialties = barber['specialties'] is List ? List<String>.from(barber['specialties'] ?? []) : ['General'];
    final hourlyRate = barber['hourlyRate']?.toDouble();
    final lastActive = barber['lastActive'] != null ? DateTime.parse(barber['lastActive']) : null;
    final profileImage = barber['profileImage'];

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
                    barberName,
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
            _buildDetailRow(AppImages.star, 'Rating', rating.toStringAsFixed(1), isDark),
            const SizedBox(height: 12),
            _buildDetailRow(AppImages.calender, 'Total Appointments', totalAppointments.toString(), isDark),
            const SizedBox(height: 12),
            _buildDetailRow(AppImages.scissors, 'Specialties', specialties.join(', '), isDark),
            if (hourlyRate != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(AppImages.money, 'Hourly Rate', '\$${hourlyRate.toStringAsFixed(2)}', isDark),
            ],
            if (lastActive != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(AppImages.clock, 'Last Active', _formatDate(lastActive), isDark),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.close,
                  style: TextStyle(
                    color: AppColor.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String iconPath, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageIcon(
          AssetImage(iconPath),
          size: 20,
          color: AppColor.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary).withValues(alpha: 0.7),
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

  void _addNewBarber() {
    // Implement add new barber functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add new barber functionality',
          style: TextStyle(color: AppColor.light),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  void _editBarber(dynamic barber) {
    final barberName = barber['name'] ?? 'Unknown Barber';
    // Implement edit barber functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit $barberName',
          style: TextStyle(color: AppColor.light),
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  void _deleteBarber(dynamic barber) {
    final provider = Provider.of<BarberProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barberName = barber['name'] ?? 'Unknown Barber';
    final barberId = barber['id'] ?? barber['_id'] ?? '';

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
              'Delete Barber',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppColor.darkText : AppColor.lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete $barberName?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      color: (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary).withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await provider.deleteBarber(barberId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully deleted $barberName',
                            style: TextStyle(color: AppColor.light),
                          ),
                          backgroundColor: AppColor.primary,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete $barberName: $e',
                            style: TextStyle(color: AppColor.light),
                          ),
                          backgroundColor: AppColor.secondary,
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.delete,
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
