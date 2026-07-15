import 'package:flutter/material.dart';
import '../../Models/salon_extensions.dart';

/// Salon Type Filter Widget
/// Horizontal scrollable filter chips for salon types
class SalonTypeFilter extends StatelessWidget {
  final SalonType? selectedType;
  final Function(SalonType?) onTypeSelected;
  final String language;

  const SalonTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.language = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All filter
          Padding(
            padding: EdgeInsets.only(
              right: language == 'ar' ? 0 : 8,
              left: language == 'ar' ? 8 : 0,
            ),
            child: FilterChip(
              label: Text(language == 'ar' ? 'الكل' : 'All'),
              selected: selectedType == null,
              onSelected: (_) => onTypeSelected(null),
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Expertsalon filter
          _buildFilterChip(context, SalonType.expertshop),

          // Beauty Salon filter
          _buildFilterChip(context, SalonType.beautySalon),

          // Turkish Bath filter
          _buildFilterChip(context, SalonType.turkishBath),

          // Men's Spa filter
          _buildFilterChip(context, SalonType.mensSpa),

          // Hybrid filter
          _buildFilterChip(context, SalonType.hybridExpertSpa),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, SalonType type) {
    return Padding(
      padding: EdgeInsets.only(
        right: language == 'ar' ? 0 : 8,
        left: language == 'ar' ? 8 : 0,
      ),
      child: FilterChip(
        label: Text(type.getDisplayName(language)),
        selected: selectedType == type,
        onSelected: (_) => onTypeSelected(type),
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
