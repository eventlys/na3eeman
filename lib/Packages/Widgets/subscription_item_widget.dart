import 'package:flutter/material.dart';
import '../../Models/subscription_model.dart';
import '../../Services/subscription_helper.dart';

class SubscriptionItemWidget extends StatelessWidget {
  final ShopSubscription subscription;
  final VoidCallback onTap;

  const SubscriptionItemWidget({
    super.key,
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    return Card(
      shadowColor: Colors.transparent,
      elevation: 2,
      color: Color(0x4dffffff),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: subscription.isPopular
            ? BorderSide(color: Color(0xffc25858), width: 2)
            : BorderSide(color: Color(0x80ffffff)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and popular badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subscription.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xccffffff)
                      ),
                    ),
                  ),
                  if (subscription.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x66c25858), Color(0xCCC25858)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Popular',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              // Description
              Text(
                subscription.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF463954),
                ),
              ),

              // Price and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subscription.formattedPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0x99ffffff),
                    ),
                  ),
                  Text(
                    subscription.formattedDuration,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF463954),
                    ),
                  ),
                ],
              ),

              // Monthly price for longer durations
              if (subscription.duration.inDays > 30)
                Text(
                  SubscriptionHelper.getPricePerMonth(
                    subscription.price,
                    subscription.duration,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

