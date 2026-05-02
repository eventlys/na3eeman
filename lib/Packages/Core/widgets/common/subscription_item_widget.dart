import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../Helpers/subscription_helper.dart';
import '../../constants/app_color.dart';
import '../../themes/empty_state.dart';
import '../../utils/helpers/themes_helpers.dart';
import '../base/error_boundary.dart';
// import 'package:easy_localization/easy_localization.dart';

class SubscriptionItemWidget extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isSelected;
  final UserGender? gender;

  const SubscriptionItemWidget({
    super.key,
    required this.subscription,
    required this.onTap,
    this.isLoading = false,
    this.isSelected = false,
    this.gender,
  });

  // Helper getters to access subscription data
  String get name => subscription['name'] ?? 'Unnamed Plan';
  String get description => subscription['description'] ?? '';
  double get price => (subscription['price'] as num?)?.toDouble() ?? 0.0;
  String get duration => subscription['duration'] ?? 'MONTHLY';
  bool get isPopular => subscription['isPopular'] == true;
  List<String> get features => List<String>.from(subscription['features'] ?? []);
  String get id => subscription['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ErrorBoundary(
      isDarkMode: isDark,
      userGender: gender,
      child: _buildSubscriptionCard(context, isDark),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, bool isDark) {
    if (isLoading) {
      return _buildLoadingCard(context, isDark);
    }

    final size = MediaQuery.of(context).size;
    
    return Card(
      shadowColor: Colors.transparent,
      elevation: isSelected ? 4 : 2,
      color: isDark ? AppColor.darkCard.withValues(alpha: 0.1) : AppColor.lightCard.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _getBorderSide(context, isDark),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: _getCardGradient(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and popular badge
              _buildHeader(context, isDark),
              
              const SizedBox(height: 8),
              
              // Description
              _buildDescription(context, isDark),
              
              const SizedBox(height: 12),
              
              // Price and duration
              _buildPriceSection(context, isDark),
              
              // Monthly price for longer durations
              if (_isLongDuration(duration))
                _buildMonthlyPrice(context, isDark),

              // Features preview
              if (features.isNotEmpty)
                _buildFeaturesPreview(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, bool isDark) {
    return Card(
      shadowColor: Colors.transparent,
      elevation: 2,
      color: isDark ? AppColor.darkCard.withValues(alpha: 0.1) : AppColor.lightCard.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton header
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Skeleton description
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            const SizedBox(height: 4),
            
            Container(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Skeleton price section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark ? AppColor.skeletonBaseDark : AppColor.skeletonBaseLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.darkText : AppColor.lightText,
            ),
          ),
        ),
        if (isPopular)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColor.darkSecondary.withValues(alpha: 0.4) : AppColor.lightSecondary.withValues(alpha: 0.4),
                  isDark ? AppColor.darkSecondary : AppColor.lightSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("popular".tr(),
              style: TextStyle(
                fontSize: 12,
                color: AppColor.light,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (isSelected)
          Container(
            margin: EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: AppColor.light,
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, bool isDark) {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatPrice(price),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
          ),
        ),
        Text(
          _getReadableDuration(duration),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyPrice(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        SubscriptionHelper.getPricePerMonth(price, duration),
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColor.darkAccent : AppColor.lightAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeaturesPreview(BuildContext context, bool isDark) {
    final previewFeatures = features.take(2).toList();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...previewFeatures.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          if (features.length > 2)
            Text(
              '+ ${features.length - 2} more features',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  BorderSide _getBorderSide(BuildContext context, bool isDark) {
    if (isSelected) {
      return BorderSide(
        color: isDark ? AppColor.darkSuccess : AppColor.lightSuccess, 
        width: 2
      );
    } else if (isPopular) {
      return BorderSide(
        color: isDark ? AppColor.darkSecondary : AppColor.lightSecondary, 
        width: 2
      );
    } else {
      return BorderSide(
        color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
        width: 1
      );
    }
  }

  LinearGradient _getCardGradient(bool isDark) {
    if (gender != null) {
      switch (gender!) {
        case UserGender.male:
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColor.darkMaleBackgroundStart, AppColor.darkMaleBackgroundEnd]
                : [AppColor.lightMaleBackgroundStart, AppColor.lightMaleBackgroundEnd],
          );
        case UserGender.female:
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColor.darkFemaleBackgroundStart, AppColor.darkFemaleBackgroundEnd]
                : [AppColor.lightFemaleBackgroundStart, AppColor.lightFemaleBackgroundEnd],
          );
        case UserGender.nonBinary:
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColor.darkNonBinaryBackgroundStart, AppColor.darkNonBinaryBackgroundEnd]
                : [AppColor.lightNonBinaryBackgroundStart, AppColor.lightNonBinaryBackgroundEnd],
          );
      }
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppColor.darkBackgroundStart, AppColor.darkBackgroundEnd]
          : [AppColor.lightBackgroundStart, AppColor.lightBackgroundEnd],
    );
  }

  // Helper methods
  String _formatPrice(double price) {
    return SubscriptionHelper.formatPrice(price);
  }

  String _getReadableDuration(String duration) {
    return SubscriptionHelper.getReadableDuration(duration);
  }

  bool _isLongDuration(String duration) {
    final upperDuration = duration.toUpperCase();
    return upperDuration == 'YEARLY' || 
           upperDuration == 'ANNUAL' || 
           upperDuration == 'QUARTERLY';
  }
}

// Subscription list view that uses service directly
class SubscriptionListView extends StatefulWidget {
  final UserGender? gender;
  final VoidCallback? onRetry;
  final bool showFeaturedOnly;
  final ValueChanged<Map<String, dynamic>>? onSubscriptionSelected;

  const SubscriptionListView({
    super.key,
    this.gender,
    this.onRetry,
    this.showFeaturedOnly = false,
    this.onSubscriptionSelected,
  });

  @override
  State<SubscriptionListView> createState() => _SubscriptionListViewState();
}

class _SubscriptionListViewState extends State<SubscriptionListView> {
  late Future<List<Map<String, dynamic>>> _subscriptionsFuture;
  bool _isLoading = false;
  String? _error;
  String? _selectedSubscriptionId;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _subscriptionsFuture = SubscriptionHelper.getSubscriptions().then((subscriptions) {
      setState(() => _isLoading = false);
      
      // Convert to Map format if needed
      final List<Map<String, dynamic>> subscriptionMaps = subscriptions.map((sub) {
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

      if (widget.showFeaturedOnly) {
        return subscriptionMaps.where((sub) => sub['isPopular'] == true).toList();
      }
      return subscriptionMaps;
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
      return <Map<String, dynamic>>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ErrorBoundary(
      isDarkMode: isDark,
      userGender: widget.gender,
      onRetry: _loadSubscriptions,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDark),
        ),
        child: _buildContent(isDark),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_error != null) {
      return _buildErrorState(isDark);
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _subscriptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorState(isDark, error: snapshot.error.toString());
        }

        final subscriptions = snapshot.data ?? [];

        if (subscriptions.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildSubscriptionList(subscriptions, isDark);
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return SubscriptionItemWidget(
          subscription: {
            'id': 'loading_$index',
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
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark, {String? error}) {
    return EmptyState.error(
      context: context,
      title: "failed_to_load_subscriptions".tr(),
      description: error ?? _error ?? 'Please check your connection and try again.',
      onRetry: _loadSubscriptions,
      gender: widget.gender,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyState.noItems(
      context: context,
      title: "no_subscriptions_available".tr(),
      description: widget.showFeaturedOnly 
          ? 'There are no featured subscriptions at the moment.'
          : 'There are no subscription plans available right now.',
      actionButton: ElevatedButton(
        onPressed: _loadSubscriptions,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
          foregroundColor: AppColor.light,
        ),
        child: Text("refresh".tr()),
      ),
      gender: widget.gender,
    );
  }

  Widget _buildSubscriptionList(List<Map<String, dynamic>> subscriptions, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return SubscriptionItemWidget(
          subscription: subscription,
          onTap: () => _onSubscriptionSelected(subscription),
          isSelected: _selectedSubscriptionId == subscription['id'],
          gender: widget.gender,
        );
      },
    );
  }

  LinearGradient _getBackgroundGradient(bool isDark) {
    if (widget.gender != null) {
      switch (widget.gender!) {
        case UserGender.male:
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColor.darkMaleBackgroundStart, AppColor.darkMaleBackgroundEnd]
                : [AppColor.lightMaleBackgroundStart, AppColor.lightMaleBackgroundEnd],
          );
        case UserGender.female:
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColor.darkFemaleBackgroundStart, AppColor.darkFemaleBackgroundEnd]
                : [AppColor.lightFemaleBackgroundStart, AppColor.lightFemaleBackgroundEnd],
          );
        case UserGender.nonBinary:
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColor.darkNonBinaryBackgroundStart, AppColor.darkNonBinaryBackgroundEnd]
                : [AppColor.lightNonBinaryBackgroundStart, AppColor.lightNonBinaryBackgroundEnd],
          );
      }
    }

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [AppColor.darkBackgroundStart, AppColor.darkBackgroundEnd]
          : [AppColor.lightBackgroundStart, AppColor.lightBackgroundEnd],
    );
  }

  void _onSubscriptionSelected(Map<String, dynamic> subscription) {
    setState(() {
      _selectedSubscriptionId = subscription['id'];
    });

    widget.onSubscriptionSelected?.call(subscription);

    // Show selection feedback
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${subscription['name']}'),
        backgroundColor: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Direct service integration helper
class SubscriptionServiceHelper {
  static Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final plans = await SubscriptionHelper.getSubscriptions();
      
      return plans.map((plan) {
        return {
          'id': plan.id,
          'name': plan.name,
          'description': plan.description,
          'price': plan.price,
          'duration': plan.duration,
          'features': plan.features,
          'isPopular': plan.isPopular,
          'formattedPrice': SubscriptionHelper.formatPrice(plan.price),
          'monthlyPrice': SubscriptionHelper.getPricePerMonth(plan.price, plan.duration),
          'readableDuration': SubscriptionHelper.getReadableDuration(plan.duration),
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentSubscription() async {
    try {
      final subscription = await SubscriptionHelper.getCurrentSubscription();
      
      if (subscription == null) return null;
      
      return {
        'id': subscription.id,
        'planName': subscription.planName,
        'status': subscription.status,
        'isActive': subscription.isActive,
        'startDate': subscription.startDate,
        'endDate': subscription.endDate,
        'price': subscription.price,
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> subscribeToPlan({
    required String planId,
    required String paymentMethodId,
    String? couponCode,
    bool autoRenew = true,
  }) async {
    try {
      // This would call your actual subscription service
      // For now, we'll simulate the response
      await Future.delayed(Duration(seconds: 2));
      
      return {
        'success': true,
        'subscriptionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Subscription activated successfully',
        'nextBillingDate': DateTime.now().add(Duration(days: 30)),
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getFeaturedPlans() async {
    final allPlans = await getSubscriptionPlans();
    return allPlans.where((plan) => plan['isPopular'] == true).toList();
  }

  static Future<Map<String, dynamic>?> getPlanById(String planId) async {
    final allPlans = await getSubscriptionPlans();
    return allPlans.firstWhere(
      (plan) => plan['id'] == planId,
      orElse: () => allPlans.first,
    );
  }
}
