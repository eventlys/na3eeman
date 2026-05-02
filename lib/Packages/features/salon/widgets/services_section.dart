import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class ServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final Set<String>? selectedServiceNames;
  final Function(Map<String, dynamic>)? onToggleService;

  const ServicesSection({
    super.key,
    required this.services,
    this.selectedServiceNames,
    this.onToggleService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: services.map((service) => _buildServiceItem(
        context: context,
        service: service,
        isDark: isDark,
      )).toList(),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required Map<String, dynamic> service,
    required bool isDark,
  }) {
    final name = service['name'] ?? service['serviceName'] ?? 'Service';
    final price = service['price'] ?? '0.00';
    final duration = service['duration'] ?? '30 min';
    final isSelected = selectedServiceNames?.contains(name) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected 
          ? Theme.of(context).primaryColor.withOpacity(0.1) 
          : (isDark ? AppColors.almostBlack600 : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
            ? Theme.of(context).primaryColor 
            : (isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.content_cut_rounded, color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                     name.toString().length > 18 ? '${name.toString().substring(0, 18)}...' : name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.almostBlack300),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '\$$price',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (onToggleService != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onToggleService!(service),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.add,
                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
