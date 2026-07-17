// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import 'subscription_item_widget.dart';
import '../../../../Helpers/subscription_helper.dart';
import '../../../shared/overlays/subscription_details_dialog.dart';
import '../../constants/app_color.dart';
// import 'package:easy_localization/easy_localization.dart';

class SubscriptionListWidget extends StatefulWidget {
  final VoidCallback onSubscriptionSuccess;
  final UserGender? gender;

  const SubscriptionListWidget({
    super.key,
    required this.onSubscriptionSuccess,
    this.gender,
  });

  @override
  State<SubscriptionListWidget> createState() => _SubscriptionListWidgetState();
}

class _SubscriptionListWidgetState extends State<SubscriptionListWidget> {
  List<Map<String, dynamic>> _allSubscriptions = [];
  int _visibleCount = 3;
  final int _loadMoreCount = 3;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subscriptions = await SubscriptionHelper.getSubscriptions();
      setState(() {
        _allSubscriptions = subscriptions.map((sub) {
          return {
            'id': sub.id,
            'name': sub.name,
            'description': sub.description,
            'price': sub.price,
            'duration': sub.duration,
            'features': sub.features,
            'isPopular': sub.isPopular,
            'salonId': sub.salonId,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSubscriptionDetails(Map<String, dynamic> subscription) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => SubscriptionDetailsDialog(
        subscription: subscription,
        onSubscribe: () {
          _handleSubscription(subscription);
        },
        gender: appState.userGender,
        isDarkMode: appState.isDarkMode,
      ),
    );
  }

  void _handleSubscription(Map<String, dynamic> subscription) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully subscribed to ${subscription['name']}!'),
        backgroundColor: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
      ),
    );
    widget.onSubscriptionSuccess();
  }

  void _loadMoreSubscriptions() {
    setState(() {
      _visibleCount += _loadMoreCount;
      if (_visibleCount > _allSubscriptions.length) {
        _visibleCount = _allSubscriptions.length;
      }
    });
  }

  List<Map<String, dynamic>> get _visibleSubscriptions =>
      _allSubscriptions.take(_visibleCount).toList();

  bool get _canLoadMore => _visibleCount < _allSubscriptions.length;

  Widget _buildLoadingState() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          SubscriptionItemWidget(
            subscription: {
              'id': 'loading_$i',
              'name': 'Loading...',
              'description': 'Loading description...',
              'price': 0.0,
              'duration': 'MONTHLY',
              'features': [],
              'isPopular': false,
            },
            onTap: () {},
            isLoading: true,
            gender: widget.gender,
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.darkError
                : AppColor.lightError,
          ),
          SizedBox(height: 16),
          Text(
            "failed_to_load_subscriptions".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkText
                  : AppColor.lightText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _error ?? 'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSubscriptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkPrimary
                  : AppColor.lightPrimary,
              foregroundColor: AppColor.light,
            ),
            child: Text("try_again".tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColor.darkTextHint
                : AppColor.lightTextHint,
          ),
          SizedBox(height: 16),
          Text(
            "no_subscriptions_available".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkText
                  : AppColor.lightText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "there_are_no_subscription_plans_available_at_the_m".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_allSubscriptions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            "subscribe_to_the_salon".tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.darkText : AppColor.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Subscription List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _visibleSubscriptions.length,
          itemBuilder: (context, index) {
            final subscription = _visibleSubscriptions[index];
            return SubscriptionItemWidget(
              subscription: subscription,
              onTap: () => _showSubscriptionDetails(subscription),
              gender: widget.gender,
            );
          },
        ),

        // Load More Button
        if (_canLoadMore)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: _loadMoreSubscriptions,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? AppColor.darkPrimary
                    : AppColor.lightPrimary,
                side: BorderSide(
                  color: isDark
                      ? AppColor.darkPrimary.withValues(alpha: 0.5)
                      : AppColor.lightPrimary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              child: Text("show_more".tr()),
            ),
          ),

        // Showing X of Y text
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Showing ${_visibleSubscriptions.length} of ${_allSubscriptions.length} plans',
            style: TextStyle(
              color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
