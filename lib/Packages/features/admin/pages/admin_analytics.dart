import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';

/// Super Admin — Analytics Page.
/// Shows peak hour heatmap, top services, and retention stats.
class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Usage & Analytics')),
      drawer: const AppDrawer(
        role: UserRole.superAdmin,
        currentRoute: '/admin/analytics',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Retention & Engagement', context),
          const SizedBox(height: 12),
          _StatRow(
            stats: const [
              ('Retention Rate', '74.2%', AppColor.success),
              ('Avg. Sessions/Month', '6.8', AppColor.navyPrimary),
              ('Repeat Bookings', '58%', AppColor.pinkPrimary),
            ],
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _SectionLabel('Peak Hours Heatmap', context),
          const SizedBox(height: 12),
          AppCard(
            type: AppCardType.elevated,
            child: _PeakHoursTable(isDark: isDark),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Top Services', context),
          const SizedBox(height: 12),
          _TopServicesList(isDark: isDark),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stats, required this.isDark});
  final List<(String, String, Color)> stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((s) {
        final (label, value, color) = s;
        return Expanded(
          child: AppCard(
            type: AppCardType.elevated,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Peak Hours Table (heatmap-style) ─────────────────────────────────────────

class _PeakHoursTable extends StatelessWidget {
  const _PeakHoursTable({required this.isDark});
  final bool isDark;

  static const _hours = ['8am', '10am', '12pm', '2pm', '4pm', '6pm', '8pm'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  // Intensity 0.0 - 1.0
  static const _data = [
    [0.3, 0.4, 0.6, 0.5, 0.4, 0.3, 0.2],
    [0.4, 0.5, 0.7, 0.6, 0.5, 0.4, 0.3],
    [0.2, 0.3, 0.5, 0.4, 0.3, 0.2, 0.1],
    [0.3, 0.4, 0.6, 0.7, 0.5, 0.3, 0.2],
    [0.5, 0.8, 1.0, 0.9, 0.8, 0.7, 0.5],
    [0.6, 0.9, 1.0, 1.0, 0.9, 0.8, 0.6],
    [0.2, 0.3, 0.4, 0.3, 0.2, 0.1, 0.1],
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Table(
      columnWidths: const {0: FixedColumnWidth(36)},
      children: [
        // Header row
        TableRow(
          children: [
            const SizedBox(),
            ..._hours.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  h,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        ..._days.asMap().entries.map((dayEntry) {
          final di = dayEntry.key;
          final day = dayEntry.value;
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._hours.asMap().entries.map((hEntry) {
                final intensity = _data[di][hEntry.key];
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(intensity * 0.8 + 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}

// ── Top Services ─────────────────────────────────────────────────────────────

class _TopServicesList extends StatelessWidget {
  const _TopServicesList({required this.isDark});
  final bool isDark;

  static const _services = [
    ('Classic Haircut', '14,230 bookings', 0.92),
    ('Fade & Shave', '11,800 bookings', 0.76),
    ('Beard Trim', '9,540 bookings', 0.62),
    ('Hair Colouring', '7,210 bookings', 0.47),
    ('Kids Haircut', '5,830 bookings', 0.38),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        children: _services.asMap().entries.map((e) {
          final (name, count, pct) = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${e.key + 1}.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColor.darkTextHint
                                : AppColor.lightTextHint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColor.darkTextSecondary
                            : AppColor.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  minHeight: 5,
                ),
              ],
            ),
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
