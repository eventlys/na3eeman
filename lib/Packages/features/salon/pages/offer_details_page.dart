import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Models/salon/offer_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class OfferDetailsPage extends StatelessWidget {
  final OfferModel offer;

  const OfferDetailsPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOfferHeader(context, isDark),
                  const SizedBox(height: 24),
                  _buildValiditySection(isDark, context),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(isDark, context),
                  const SizedBox(height: 24),
                  if (offer.includedServices != null &&
                      offer.includedServices!.isNotEmpty)
                    _buildIncludedServices(isDark, context),
                  const SizedBox(height: 120), // Padding for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButtonStyled(
        icon: Icons.arrow_back_rounded,
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: offer.imageUrl != null
            ? Image.network(
                offer.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderBackground(),
              )
            : _buildPlaceholderBackground(),
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Builder(
      builder: (context) {
        return Container(
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
          child: const Center(
            child: Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha:0.3),
            ),
          ),
          child: Text(
            offer.salonName,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          offer.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${offer.price} JOD',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (offer.originalPrice != null) ...[
              const SizedBox(width: 8),
              Text(
                '${offer.originalPrice} JOD',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  decoration: TextDecoration.combine([
                    TextDecoration.lineThrough,
                  ]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildValiditySection(bool isDark, BuildContext context) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.almostBlack50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  offer.validityPeriod,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "about_this_offer".tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          offer.description,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedServices(bool isDark, BuildContext context) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "included_services".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...offer.includedServices!.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(service),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _showBookingSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "book_this_offer".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingSheet(offer: offer),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final OfferModel offer;

  const _BookingSheet({required this.offer});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  DateTime? selectedDate;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag bar
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "select_date_time".tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 24),

          // Date Selection Button
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) setState(() => selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Choose Date',
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time Selection Slots
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "available_slots".tr(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  [
                    '10:00 AM',
                    '11:00 AM',
                    '12:00 PM',
                    '02:00 PM',
                    '03:00 PM',
                  ].map((time) {
                    final isSelected = selectedTime == time;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTime = time),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withValues(alpha:0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (selectedDate != null && selectedTime != null)
                  ? () {
                      Navigator.pop(context); // Close sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "booking_request_sent_successfully".tr(),
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("confirm_booking".tr()),
            ),
          ),
        ],
      ),
    );
  }
}
