import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Models/salon/offer_model.dart';
import '../../../../Providers/features/offers_provider.dart';
// import '../../../../core/theme/colors.dart';
import '../pages/offer_details_page.dart';

class HorizontalSalonScroll extends StatefulWidget {
  const HorizontalSalonScroll({super.key});

  @override
  State<HorizontalSalonScroll> createState() => _HorizontalSalonScrollState();
}

class _HorizontalSalonScrollState extends State<HorizontalSalonScroll> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Load offers if not loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<OffersProvider>(context, listen: false).loadOffers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offersProvider = context.watch<OffersProvider>();
    final offers = offersProvider.offers;

    if (offersProvider.isLoading && offers.isEmpty) {
      return SizedBox(
        height: 170,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    if (offers.isEmpty) {
      return SizedBox(
        height: 170,
        child: Center(child: Text("no_offers_available_at_this_moment".tr())),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return OfferCard(offer: offer);
        },
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final OfferModel offer;

  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsPage(offer: offer),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:isDark ? 0.3 : 0.05),
              offset: const Offset(0, 4),
              blurRadius: 16,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient/image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 120,
                      ),
                    ),
                  ),
                ),
              ),

              // Content Layout
              Positioned(
                left: 18,
                bottom: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.salonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      offer.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${offer.price} JOD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Float Validity tag
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.validityPeriod.contains('until')
                        ? 'Limited Time'
                        : offer.validityPeriod,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
