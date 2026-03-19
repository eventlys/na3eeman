import 'package:flutter/material.dart';
import '../../Models/shop_extensions.dart';

/// Shop Type Filter Widget
/// Horizontal scrollable filter chips for shop types
class ShopTypeFilter extends StatelessWidget {
  final ShopType? selectedType;
  final Function(ShopType?) onTypeSelected;
  final String language;

  const ShopTypeFilter({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
    this.language = 'ar',
  }) : super(key: key);

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
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Barbershop filter
          _buildFilterChip(context, ShopType.barbershop),

          // Beauty Salon filter
          _buildFilterChip(context, ShopType.beautySalon),

          // Turkish Bath filter
          _buildFilterChip(context, ShopType.turkishBath),

          // Men's Spa filter
          _buildFilterChip(context, ShopType.mensSpa),

          // Hybrid filter
          _buildFilterChip(context, ShopType.hybridBarberSpa),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, ShopType type) {
    return Padding(
      padding: EdgeInsets.only(
        right: language == 'ar' ? 0 : 8,
        left: language == 'ar' ? 8 : 0,
      ),
      child: FilterChip(
        label: Text(type.getDisplayName(language)),
        selected: selectedType == type,
        onSelected: (_) => onTypeSelected(type),
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
