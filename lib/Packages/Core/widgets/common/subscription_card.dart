// ignore_for_file: unused_element
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Services/enums/gender.dart';
import '../../../../Services/api/api_service.dart';
import '../../constants/app_color.dart';
import '../../themes/empty_state.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers/themes_helpers.dart';
import '../base/error_boundary.dart';

class SubscriptionCard extends StatefulWidget {
  final VoidCallback onUpgrade;
  final bool? isDarkMode;
  final Gender? userGender;
  final dynamic subscriptionService;

  const SubscriptionCard({
    super.key,
    required this.onUpgrade,
    required this.subscriptionService,
    this.isDarkMode,
    this.userGender,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  late Future<Map<String, dynamic>> _subscriptionData;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _subscriptionData = _loadSubscriptionData();
  }

  Future<Map<String, dynamic>> _loadSubscriptionData() async {
    try {
      // Fetch live data from backend
      final plansData = await _apiService.getSubscriptionPlans();

      // Try to fetch current user subscription
      dynamic currentSub;
      try {
        final subResponse = await _apiService.get(
          '/salons/subscriptions/current/',
        );
        currentSub = subResponse?['data'];
      } catch (_) {
        // Fallback or handle as no active subscription
      }

      return {'subscription': currentSub, 'plans': plansData, 'error': null};
    } catch (e) {
      return {'subscription': null, 'plans': [], 'error': e.toString()};
    }
  }

  Future<void> _refreshSubscription() async {
    setState(() {
      _subscriptionData = _loadSubscriptionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode ?? theme.brightness == Brightness.dark;
    final gender = widget.userGender ?? Gender.male;

    return ErrorBoundary(
      isDarkMode: isDark,
      userGender: _convertToUserGender(gender),
      onRetry: _refreshSubscription,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _subscriptionData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(isDark, gender);
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return _buildErrorCard(
              snapshot.data?['error'] ?? 'Failed to load subscription',
              isDark,
              gender,
            );
          }

          final subscription = snapshot.data?['subscription'];
          final plans = snapshot.data?['plans'] ?? [];

          if (subscription == null) {
            return _buildNoSubscriptionCard(plans, isDark, gender);
          }

          return _buildSubscriptionCard(
            subscription: subscription,
            plans: plans,
            isDark: isDark,
            gender: gender,
          );
        },
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark, Gender gender) {
    return Card(
      elevation: 4,
      color: isDark ? AppColor.darkCard : AppColor.lightCard,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard(String error, bool isDark, Gender gender) {
    return EmptyState.error(
      context: context,
      title: "unable_to_load_subscription".tr(),
      description: error,
      onRetry: _refreshSubscription,
      gender: _convertToUserGender(gender),
    );
  }

  Widget _buildNoSubscriptionCard(
    List<dynamic> plans,
    bool isDark,
    Gender gender,
  ) {
    return EmptyState(
      title: "no_active_subscription".tr(),
      description: plans.isNotEmpty
          ? 'Choose from ${plans.length} available plans to get started'
          : 'No subscription plans available at the moment',
      icon: Icons.subscriptions_outlined,
      actionButton: ElevatedButton.icon(
        onPressed: widget.onUpgrade,
        icon: const Icon(Icons.upgrade),
        label: Text("view_plans".tr()),
      ),
      gender: _convertToUserGender(gender),
    );
  }

  Widget _buildSubscriptionCard({
    required dynamic subscription,
    required List<dynamic> plans,
    required bool isDark,
    required Gender gender,
  }) {
    final theme = Theme.of(context);
    final cardColor =
        theme.cardTheme.color ??
        (isDark ? AppColor.darkCard : AppColor.lightCard);
    final primaryColor = theme.primaryColor;
    final textColor = isDark ? AppColor.light : AppColor.dark;
    final successColor = isDark ? AppColor.lightSuccess : AppColor.darkSuccess;
    final warningColor = isDark ? AppColor.lightWarning : AppColor.darkWarning;
    final errorColor = isDark ? AppColor.lightError : AppColor.darkError;

    // Mapping backend fields to UI
    final planName =
        subscription['plan_name'] ?? subscription['plan']?['name'] ?? 'Plan';
    final price = (subscription['price'] ?? 0.0).toDouble();
    final status = subscription['status'] ?? 'Active';
    final endDateStr = subscription['end_date'] ?? subscription['expires_at'];
    final DateTime endDate = endDateStr != null
        ? DateTime.parse(endDateStr)
        : DateTime.now().add(const Duration(days: 30));
    final daysRemaining = endDate
        .difference(DateTime.now())
        .inDays
        .clamp(0, 365);
    final features = List<String>.from(
      subscription['plan']?['features'] ?? subscription['features'] ?? [],
    );

    return Card(
      elevation: theme.cardTheme.elevation ?? 4,
      color: cardColor,
      shape:
          theme.cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "subscription".tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      status,
                      successColor,
                      warningColor,
                      isDark,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(
                        status,
                        successColor,
                        warningColor,
                        isDark,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              planName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.formatCurrency(price)}/month',
              style: TextStyle(
                fontSize: 16,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildRemainingDays(daysRemaining, errorColor, textColor),
            const SizedBox(height: 12),
            _buildFeaturesList(features, primaryColor, textColor),
            const SizedBox(height: 16),
            _buildUpgradeButton(theme, gender, isDark, status),
          ],
        ),
      ),
    );
  }

  int _calculateDaysRemaining(dynamic endDate) {
    if (endDate == null) return 0;
    final now = DateTime.now();
    final DateTime endDateTime = endDate is DateTime
        ? endDate
        : DateTime.now().add(const Duration(days: 30));
    final difference = endDateTime.difference(now);
    return difference.inDays.clamp(0, 365);
  }

  Color _getStatusColor(
    String status,
    Color successColor,
    Color warningColor,
    bool isDark,
  ) {
    switch (status.toLowerCase()) {
      case 'active':
        return successColor;
      case 'expired':
      case 'cancelled':
        return warningColor;
      case 'pending':
        return isDark ? AppColor.lightWarning : AppColor.darkWarning;
      default:
        return isDark ? AppColor.lightText : AppColor.darkText;
    }
  }

  Widget _buildRemainingDays(
    int daysRemaining,
    Color errorColor,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 16,
          color: textColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
          style: TextStyle(
            color: daysRemaining < 7
                ? errorColor
                : textColor.withValues(alpha: 0.8),
            fontWeight: daysRemaining < 7 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (daysRemaining < 7) ...[
          const SizedBox(width: 8),
          Icon(Icons.warning_amber_rounded, size: 16, color: errorColor),
        ],
      ],
    );
  }

  Widget _buildFeaturesList(
    List<String> features,
    Color primaryColor,
    Color textColor,
  ) {
    if (features.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: features
          .map(
            (feature) => Chip(
              label: Text(
                feature,
                style: TextStyle(color: primaryColor, fontSize: 12),
              ),
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpgradeButton(
    ThemeData theme,
    Gender gender,
    bool isDark,
    String status,
  ) {
    final accentColor = _getGenderAccentColor(gender, isDark);
    return ElevatedButton(
      onPressed: widget.onUpgrade,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        status.toLowerCase() == 'active'
            ? 'Upgrade Plan'
            : 'Renew Subscription',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Color _getGenderAccentColor(Gender gender, bool isDark) {
    switch (gender) {
      case Gender.male:
        return isDark ? AppColor.darkPrimary : AppColor.maleAccent;
      case Gender.female:
        return isDark ? AppColor.darkSecondary : AppColor.femaleAccent;
      default:
        return isDark ? AppColor.darkPrimary : AppColor.primary;
    }
  }

  UserGender _convertToUserGender(Gender gender) {
    return gender == Gender.female ? UserGender.female : UserGender.male;
  }
}
