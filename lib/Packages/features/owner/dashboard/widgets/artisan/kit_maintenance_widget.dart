import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Kit maintenance reminders for solo practitioners (Artisan tier).
class KitMaintenanceWidget extends StatelessWidget {
  const KitMaintenanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = [
      _KitItem('Clippers', 'Due for oiling', Icons.content_cut_rounded,
          urgency: _Urgency.high),
      _KitItem('Razors', 'Replace blades', Icons.cut_rounded,
          urgency: _Urgency.medium),
      _KitItem('Towels', 'Sterilise today', Icons.dry_cleaning_rounded,
          urgency: _Urgency.low),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.build_circle_outlined,
                size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text("kit_maintenance".tr(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.urgencyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(item.icon, size: 18, color: item.urgencyColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(item.task,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.urgencyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.urgencyLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.urgencyColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _Urgency { high, medium, low }

class _KitItem {
  final String name;
  final String task;
  final IconData icon;
  final _Urgency urgency;

  _KitItem(this.name, this.task, this.icon, {required this.urgency});

  Color get urgencyColor {
    switch (urgency) {
      case _Urgency.high:
        return Colors.red;
      case _Urgency.medium:
        return Colors.orange;
      case _Urgency.low:
        return Colors.green;
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case _Urgency.high:
        return 'Urgent';
      case _Urgency.medium:
        return 'Soon';
      case _Urgency.low:
        return 'OK';
    }
  }
}
