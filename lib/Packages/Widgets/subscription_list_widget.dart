import 'package:flutter/material.dart';
import '../../Models/subscription_model.dart';
import '../../Services/subscription_details_dialog.dart';
import '../../Services/subscription_helper.dart';
import 'subscription_item_widget.dart';

class SubscriptionListWidget extends StatefulWidget {
  final VoidCallback onSubscriptionSuccess;

  const SubscriptionListWidget({
    super.key,
    required this.onSubscriptionSuccess,
  });

  @override
  State<SubscriptionListWidget> createState() => _SubscriptionListWidgetState();
}

class _SubscriptionListWidgetState extends State<SubscriptionListWidget> {
  final List<ShopSubscription> _allSubscriptions =
      SubscriptionHelper.getSubscriptions();
  int _visibleCount = 3;
  final int _loadMoreCount = 3;

  void _showSubscriptionDetails(ShopSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDetailsDialog(
        subscription: subscription,
        onSubscribe: () {
          _handleSubscription(subscription);
        },
      ),
    );
  }

  void _handleSubscription(ShopSubscription subscription) {
    // Here you would typically call your subscription API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully subscribed to ${subscription.name}!'),
        backgroundColor: Colors.green,
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

  List<ShopSubscription> get _visibleSubscriptions =>
      _allSubscriptions.take(_visibleCount).toList();

  bool get _canLoadMore => _visibleCount < _allSubscriptions.length;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            'Subscribe to the Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff)
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
                foregroundColor: Color(0xff806C99),
                side: BorderSide(color: Color(0x80806C99)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              child: const Text('Show More'),
            ),
          ),

        // Showing X of Y text
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Showing ${_visibleSubscriptions.length} of ${_allSubscriptions.length} plans',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

