import 'package:flutter/material.dart';
import '../../../../Helpers/inventory_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/business_service.dart';
import '../../../../Services/enums/gender.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/constants/app_strings.dart';
import '../../../Core/widgets/common/subscription_card.dart';
import '../widgets/branch_card.dart';
import '../widgets/branch_management.dart';
import '../widgets/inventory_alert_card.dart';
import '../widgets/offers_card.dart';
import '../widgets/profit_graph.dart';
import 'shop_details.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  ShopOwnerDashboardState createState() => ShopOwnerDashboardState();
}

class ShopOwnerDashboardState extends State<ShopOwnerDashboard> {
  late InventoryProvider _inventoryProvider;
  late SubscriptionProvider _subscriptionProvider;
  late Map<String, dynamic> shopData;

  @override
  void initState() {
    super.initState();

    // Initialize providers with required services
    final apiService = ApiService();
    final inventoryService = InventoryService(apiService);
    final inventoryHelpers = InventoryHelpers(inventoryService);
    final subscriptionService = SubscriptionService(apiService: apiService);

    _inventoryProvider = InventoryProvider(
      inventoryService: inventoryService,
      inventoryHelpers: inventoryHelpers,
    );

    _subscriptionProvider = SubscriptionProvider(
      subscriptionService: subscriptionService,
    );

    shopData = {};
    _loadData();
  }

  void _loadData() {
    _inventoryProvider.loadLowStockItems();
    _subscriptionProvider.loadSubscriptionData();
  }

  void _showUpgradePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Upgrade Subscription',
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                AppImages.star,
                width: 24,
                height: 24,
                color: AppColor.lightAccent,
              ),
              title: Text(
                'Enterprise Plan',
                style: TextStyle(color: AppColor.lightText),
              ),
              subtitle: Text(
                '\$199.99/month',
                style: TextStyle(color: AppColor.lightTextSecondary),
              ),
              trailing: ElevatedButton(
                onPressed: () => _subscriptionProvider.upgradeToEnterprise(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.lightAccent,
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyle(color: AppColor.light),
                ),
              ),
            ),
            ListTile(
              leading: Image.asset(
                AppImages.workspace_premium,
                width: 24,
                height: 24,
                color: AppColor.lightPrimary,
              ),
              title: Text(
                'Premium Plan',
                style: TextStyle(color: AppColor.lightText),
              ),
              subtitle: Text(
                '\$149.99/month',
                style: TextStyle(color: AppColor.lightTextSecondary),
              ),
              trailing: ElevatedButton(
                onPressed: () => _subscriptionProvider.upgradeToPremium(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.lightPrimary,
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyle(color: AppColor.light),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOfferPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Offer',
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Offer Title',
                  labelStyle: TextStyle(color: AppColor.lightTextHint),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColor.lightPrimary),
                  ),
                ),
                style: TextStyle(color: AppColor.lightText),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColor.lightTextHint),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColor.lightPrimary),
                  ),
                ),
                style: TextStyle(color: AppColor.lightText),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Discount Percentage',
                  labelStyle: TextStyle(color: AppColor.lightTextHint),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColor.lightPrimary),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColor.lightText),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        labelStyle: TextStyle(color: AppColor.lightTextHint),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColor.lightPrimary),
                        ),
                      ),
                      style: TextStyle(color: AppColor.lightText),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        labelStyle: TextStyle(color: AppColor.lightTextHint),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColor.lightPrimary),
                        ),
                      ),
                      style: TextStyle(color: AppColor.lightText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Image.asset(
                        AppImages.check,
                        width: 20,
                        height: 20,
                        color: AppColor.light,
                      ),
                      SizedBox(width: 8),
                      Text('Offer created successfully!'),
                    ],
                  ),
                  backgroundColor: AppColor.lightSuccess,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lightPrimary,
            ),
            child: Text(
              'Create Offer',
              style: TextStyle(color: AppColor.light),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme ? AppColor.darkBackground : AppColor.lightBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: TextStyle(
            color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset(
              AppImages.refresh,
              width: 24,
              height: 24,
              color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
            ),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
        backgroundColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Subscription Card using SubscriptionProvider
              AnimatedBuilder(
                animation: _subscriptionProvider,
                builder: (context, child) {
                  if (_subscriptionProvider.isLoading) {
                    return _buildLoadingCard(isDarkTheme);
                  }
                  if (_subscriptionProvider.error != null) {
                    return _buildErrorCard(
                      'Failed to load subscription: ${_subscriptionProvider.error}',
                      isDarkTheme,
                    );
                  }
                  return SubscriptionCard(
                    onUpgrade: _showUpgradePopup,
                    subscriptionService: _subscriptionProvider,
                    isDarkMode: isDarkTheme,
                    userGender: Gender.male, // You can get this from your user data
                  );
                },
              ),
              SizedBox(height: 16),

              // Inventory Alert Card using InventoryProvider
              AnimatedBuilder(
                animation: _inventoryProvider,
                builder: (context, child) {
                  if (_inventoryProvider.isLoading) {
                    return _buildLoadingCard(isDarkTheme);
                  }
                  if (_inventoryProvider.error != null) {
                    return _buildErrorCard(
                      'Failed to load inventory: ${_inventoryProvider.error}',
                      isDarkTheme,
                    );
                  }
                  return InventoryAlertCard(
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopDetailsPage(shopData: shopData)),
                    ),
                    // inventoryProvider: _inventoryProvider,
                  );
                },
              ),
              SizedBox(height: 16),

              // Profit Graph
              ProfitGraph(
                startDate: DateTime.now().subtract(Duration(days: 30)),
                endDate: DateTime.now(),
                branchId: null, // You can pass specific branch ID if needed
              ),
              SizedBox(height: 16),

              // Offers Card
              OffersCard(
                onCreateOffer: _showCreateOfferPopup,
              ),
              SizedBox(height: 16),

              // Branch Card
              BranchCard(
                onViewAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BranchManagementPage()),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Card(
      color: isDark ? AppColor.darkCard : AppColor.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, bool isDark) {
    return Card(
      color: (isDark ? AppColor.darkError : AppColor.lightError).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset(
              AppImages.error,
              width: 24,
              height: 24,
              color: isDark ? AppColor.darkError : AppColor.lightError,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: isDark ? AppColor.darkText : AppColor.lightText),
              ),
            ),
            TextButton(
              onPressed: _loadData,
              child: Text(
                'Retry',
                style: TextStyle(color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inventoryProvider.dispose();
    _subscriptionProvider.dispose();
    super.dispose();
  }
}
