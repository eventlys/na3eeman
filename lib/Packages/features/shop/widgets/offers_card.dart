import 'package:flutter/material.dart';

import '../../../Core/utils/formatters.dart';

class OffersCard extends StatelessWidget {
  final List<Offer> offers;
  final VoidCallback onCreateOffer;

  const OffersCard({
    super.key,
    required this.offers,
    required this.onCreateOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Offers & Ads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onCreateOffer,
                  icon: Icon(Icons.add),
                  label: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (offers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No active offers',
                    style: TextStyle(
                      color: AppColors.textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              ...offers.map((offer) => ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: AppColors.secondaryColor,
                  ),
                ),
                title: Text(offer.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.description),
                    SizedBox(height: 4),
                    Text(
                      '${offer.daysRemaining} days remaining',
                      style: TextStyle(
                        color: offer.daysRemaining < 3
                          ? AppColors.errorColor
                          : AppColors.successColor,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Formatters.formatPercent(offer.discountPercentage / 100),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
