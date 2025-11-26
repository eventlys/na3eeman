import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/offer_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/utils/formatters.dart';

class OffersCard extends StatelessWidget {
  final VoidCallback onCreateOffer;

  const OffersCard({
    super.key,
    required this.onCreateOffer,
  });

  @override
  Widget build(BuildContext context) {
    final offersProvider = Provider.of<OffersProvider>(context);
    final offers = offersProvider.offers;

    return Card(
      elevation: 4,
      color: AppColor.lightCard,
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
                    color: AppColor.lightText,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onCreateOffer,
                  icon: Image.asset(
                    AppImages.plus,
                    width: 20,
                    height: 20,
                    color: AppColor.light,
                  ),
                  label: Text(
                    'Create',
                    style: TextStyle(color: AppColor.light),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.lightSecondary,
                    foregroundColor: AppColor.light,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (offersProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.loadingPrimaryLight),
                  ),
                ),
              )
            else if (offersProvider.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.error,
                        width: 20,
                        height: 20,
                        color: AppColor.lightError,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Error: ${offersProvider.error}',
                        style: TextStyle(
                          color: AppColor.lightError,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (offers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.info,
                        width: 20,
                        height: 20,
                        color: AppColor.lightTextHint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No active offers',
                        style: TextStyle(
                          color: AppColor.lightTextHint,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...offers.map((offer) => ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColor.lightSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Image.asset(
                    AppImages.megaphone,
                    width: 24,
                    height: 24,
                    color: AppColor.lightSecondary,
                  ),
                ),
                title: Text(
                  offer['title'] ?? 'No Title',
                  style: TextStyle(
                    color: AppColor.lightText,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['description'] ?? 'No Description',
                      style: TextStyle(
                        color: AppColor.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          AppImages.calender,
                          width: 16,
                          height: 16,
                          color: OfferHelpers.calculateDaysRemaining(offer['endDate']) < 3
                            ? AppColor.lightError
                            : AppColor.lightSuccess,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${OfferHelpers.calculateDaysRemaining(offer['endDate'])} days remaining',
                          style: TextStyle(
                            color: OfferHelpers.calculateDaysRemaining(offer['endDate']) < 3
                              ? AppColor.lightError
                              : AppColor.lightSuccess,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Formatters.formatPercentage((offer['discountPercentage'] ?? 0) / 100),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.lightSecondary,
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
