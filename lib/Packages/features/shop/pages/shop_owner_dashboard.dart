import 'package:flutter/material.dart';
import '../../../../Models/branch_model.dart';
import '../../../../Models/olds/inventory_item.dart';
import '../../../../Models/olds/offer.dart';
import '../../../../Models/profit_data.dart';
import '../../../../Models/subscriptions/subscription.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Utils/constants.dart';
import '../../../Widgets/subscription_card.dart';
import '../../../Widgets/inventory_alert_card.dart';
import '../../../Widgets/profit_graph.dart';
import '../../../Widgets/offers_card.dart';
import '../../../Widgets/branch_card.dart';
import '../../../Navigations/shop_details.dart';
import '../../../Navigations/branch_management.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  ShopOwnerDashboardState createState() => ShopOwnerDashboardState();
}

class ShopOwnerDashboardState extends State<ShopOwnerDashboard> {
  late Future<Subscription> _subscriptionFuture;
  late Future<List<InventoryItem>> _inventoryFuture;
  late Future<ProfitReport> _profitReportFuture;
  late Future<List<Offer>> _offersFuture;
  late Future<List<Branch>> _branchesFuture;
  late Map<String, dynamic> shopData;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
    shopData = {};
  }

  // Future<Map<String, dynamic>> _fetchShopData() async {
  //   // Your logic to fetch shop data
  //   return {
  //     'shopName': 'My Shop',
  //     'location': 'City Center',
  //     'totalProducts': 150,
  //   };
  // }
  void _loadData() {
    _subscriptionFuture = _apiService.getSubscriptionDetailsTyped();
    _inventoryFuture = _apiService.getLowStockItemsTyped();
    _profitReportFuture = _apiService.getProfitReportTyped();
    _offersFuture = _apiService.getCurrentOffersTyped();
    _branchesFuture = _apiService.getBranchesTyped();
  }

  void _showUpgradePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.star, color: AppColors.accentColor),
              title: Text('Enterprise Plan'),
              subtitle: Text('\$199.99/month'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text('Upgrade'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.workspace_premium, color: AppColors.primaryColor),
              title: Text('Premium Plan'),
              subtitle: Text('\$149.99/month'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text('Upgrade'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateOfferPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Offer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Offer Title'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Discount Percentage'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Start Date'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'End Date'),
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
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Offer created successfully!'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            child: Text('Create Offer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              FutureBuilder<Subscription>(
                future: _subscriptionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Failed to load subscription');
                  }
                  return SubscriptionCard(
                    subscription: snapshot.data!,
                    onUpgrade: _showUpgradePopup,
                  );
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<InventoryItem>>(
                future: _inventoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Failed to load inventory');
                  }
                  return InventoryAlertCard(
                    lowStockItems: snapshot.data!,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopDetailsPage(shopData: shopData)),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<ProfitReport>(
                future: _profitReportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Failed to load profit data');
                  }
                  return ProfitGraph(profitReport: snapshot.data!);
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<Offer>>(
                future: _offersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Failed to load offers');
                  }
                  return OffersCard(
                    offers: snapshot.data!,
                    onCreateOffer: _showCreateOfferPopup,
                  );
                },
              ),
              SizedBox(height: 16),
              FutureBuilder<List<Branch>>(
                future: _branchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Failed to load branches');
                  }
                  return BranchCard(
                    branches: snapshot.data!,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BranchManagementPage()),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: AppColors.errorColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: AppColors.errorColor),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

