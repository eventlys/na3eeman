import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';
import 'package:easy_localization/easy_localization.dart';

/// Super Admin — System Health Page.
class AdminSystemHealthPage extends StatelessWidget {
  const AdminSystemHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('system_health_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(
        role: UserRole.superAdmin,
        currentRoute: '/admin/system',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Service Status', context),
          const SizedBox(height: 12),
          _ServiceStatusList(isDark: isDark),
          const SizedBox(height: 24),
          _SectionLabel('App Version & Deployment', context),
          const SizedBox(height: 12),
          _VersionInfo(isDark: isDark),
          const SizedBox(height: 24),
          _SectionLabel('Recent Error Logs', context),
          const SizedBox(height: 12),
          _ErrorLogList(isDark: isDark),
        ],
      ),
    );
  }
}

// ── Service Status ─────────────────────────────────────────────────────────────

class _ServiceStatusList extends StatelessWidget {
  const _ServiceStatusList({required this.isDark});
  final bool isDark;

  static const _services = [
    ('API Gateway', 'Operational', AppColor.success, true),
    ('Database (PostgreSQL)', 'Operational', AppColor.success, true),
    ('Redis Cache', 'Degraded', AppColor.warning, false),
    ('Push Notifications', 'Operational', AppColor.success, true),
    ('Payment Gateway', 'Operational', AppColor.success, true),
    ('Sentry (Error Tracking)', 'Operational', AppColor.success, true),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: _services.asMap().entries.map((e) {
          final i = e.key;
          final (name, status, color, isUp) = e.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                minLeadingWidth: 10,
              ),
              if (i < _services.length - 1)
                Divider(
                  height: 1,
                  color: isDark ? AppColor.ninjaDivider : AppColor.lightDivider,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Version Info ──────────────────────────────────────────────────────────────

class _VersionInfo extends StatelessWidget {
  const _VersionInfo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        children: [
          _InfoRow('App Version', 'v1.0.0 (build 42)', isDark, context),
          _InfoRow('Backend Version', 'v2.4.1', isDark, context),
          _InfoRow('Last Deploy', '27 Feb 2026, 01:30 UTC', isDark, context),
          _InfoRow('Flutter SDK', '3.29.0', isDark, context),
          _InfoRow('Environment', 'Production', isDark, context),
        ],
      ),
    );
  }
}

Widget _InfoRow(String label, String value, bool isDark, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ── Error Logs ────────────────────────────────────────────────────────────────

class _ErrorLogModel {
  const _ErrorLogModel(this.level, this.message, this.timestamp, this.service);
  final String level;
  final String message;
  final String timestamp;
  final String service;
}

final _logs = [
  const _ErrorLogModel(
    'ERROR',
    'NullPointerException in BookingService.create()',
    '27 Feb 02:14',
    'API',
  ),
  const _ErrorLogModel(
    'WARN',
    'Redis cache miss ratio above threshold (>40%)',
    '27 Feb 01:52',
    'Cache',
  ),
  const _ErrorLogModel(
    'ERROR',
    'Payment gateway timeout (3 retries)',
    '26 Feb 23:11',
    'Payments',
  ),
  const _ErrorLogModel(
    'INFO',
    'Background task TaskWorker.sync() completed: 842ms',
    '26 Feb 22:00',
    'Worker',
  ),
  const _ErrorLogModel(
    'WARN',
    'Push notification delivery rate dropped to 88%',
    '26 Feb 20:33',
    'FCM',
  ),
];

class _ErrorLogList extends StatelessWidget {
  const _ErrorLogList({required this.isDark});
  final bool isDark;

  Color _color(String level) {
    switch (level) {
      case 'ERROR':
        return AppColor.error;
      case 'WARN':
        return AppColor.warning;
      default:
        return AppColor.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: _logs.asMap().entries.map((e) {
          final i = e.key;
          final log = e.value;
          final color = _color(log.level);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.level,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.message,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: 'monospace',
                                  color: isDark
                                      ? AppColor.darkText
                                      : AppColor.lightText,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${log.service} · ${log.timestamp}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColor.darkTextHint
                                  : AppColor.lightTextHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _logs.length - 1)
                Divider(
                  height: 1,
                  color: isDark ? AppColor.ninjaDivider : AppColor.lightDivider,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

Widget _SectionLabel(String text, BuildContext context) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
);
