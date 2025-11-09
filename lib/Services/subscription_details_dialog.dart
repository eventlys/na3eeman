import 'package:flutter/material.dart';
import 'package:na3eeman/Services/subscription_helper.dart';
import '../Models/subscription_model.dart';

class SubscriptionDetailsDialog extends StatelessWidget {
  final ShopSubscription subscription;
  final VoidCallback onSubscribe;

  const SubscriptionDetailsDialog({
    super.key,
    required this.subscription,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? size.width * 0.9 : 500,
          maxHeight: size.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _getBackgroundGradient(subscription),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // color: Color(0xffffffff),
              // Header
              _buildHeader(context),
              const SizedBox(height: 12),

              // Price Section
              _buildPriceSection(),
              const SizedBox(height: 12),

              // Features
              _buildFeaturesSection(),
              const SizedBox(height: 32),

              // Subscribe Button
              _buildSubscribeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getBackgroundGradient(ShopSubscription subscription) {
    if (subscription.isPopular) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x80806C99),
          Color(0x1affffff),
        ],
      );
    } else if (subscription.price > 20) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x80806C99),
          Color(0x4dc25858),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x4dc25858),
          Color(0x1affffff),
        ],
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subscription.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subscription.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (subscription.isPopular)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xB3C25858),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'POPULAR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xb33b7b44),
        ),
        color: Color(0x4dffffff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            subscription.formattedPrice,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xb33b7b44),
            ),
          ),
          Text(
            'for ${subscription.formattedDuration}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (subscription.duration.inDays > 30)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                SubscriptionHelper.getPricePerMonth(
                  subscription.price,
                  subscription.duration,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0x80806C99),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s included:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Column(
          children: subscription.features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[400],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onSubscribe();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0x4dffffff),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Color(0x80C25858),
            ),
          ),
        ),
        child: const Text(
          'Subscribe Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xB3C25858),
          ),
        ),
      ),
    );
  }
}

