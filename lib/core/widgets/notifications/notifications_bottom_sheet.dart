import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../buttons/styled_buttons.dart';

class NotificationsBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Notifications',
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                child: Icon(Icons.notifications_rounded, color: Theme.of(context).primaryColor),
              ),
              title: Text('Notification Title ${index + 1}'),
              subtitle: const Text('This is a notification message mockup details.'),
              trailing: const Text('2h ago', style: TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildBottomSheetContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
