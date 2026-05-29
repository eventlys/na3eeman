import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../../../Providers/features/notification_provider.dart';

class NotificationsBottomSheet {
  static void show(BuildContext context) {
    // Initial load
    context.read<NotificationProvider>().loadNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
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
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "notifications".tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllRead(),
                  child: Text(
                    "mark_all_read".tr(),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoading && provider.notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (provider.notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: AppColors.almostBlack200,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'no_notifications'.tr(),
                    style: TextStyle(color: AppColors.almostBlack300),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final n = provider.notifications[index];
                  final isRead = n['is_read'] ?? false;
                  return ListTile(
                    onTap: !isRead ? () => provider.markRead(n['id']) : null,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? Colors.grey.withValues(alpha:0.05)
                          : Theme.of(context).primaryColor.withValues(alpha:0.1),
                      child: Icon(
                        isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: isRead
                            ? AppColors.almostBlack300
                            : Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n['title'] ?? 'System Update',
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      n['message'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isRead
                            ? AppColors.almostBlack300
                            : AppColors.almostBlack500,
                      ),
                    ),
                    trailing: Text(
                      _formatDate(n['created_at']),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.almostBlack200,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}
