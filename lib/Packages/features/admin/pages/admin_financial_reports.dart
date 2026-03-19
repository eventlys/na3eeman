import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';

/// Super Admin — Financial Reports Page.
class AdminFinancialReportsPage extends StatelessWidget {
  const AdminFinancialReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      drawer: const AppDrawer(
        role: UserRole.superAdmin,
        currentRoute: '/admin/finance',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Revenue (Last 7 Days)', context),
          const SizedBox(height: 12),
          AppCard(
            type: AppCardType.elevated,
            child: SizedBox(height: 200, child: _RevenueChart(isDark: isDark)),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Subscription Revenue by Tier', context),
          const SizedBox(height: 12),
          _TierBreakdown(isDark: isDark),
          const SizedBox(height: 24),
          _SectionLabel('Pending Payout Requests', context),
          const SizedBox(height: 12),
          _PayoutQueue(isDark: isDark),
        ],
      ),
    );
  }
}

// ── Revenue Line Chart ────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final spots = const [
      FlSpot(0, 12400),
      FlSpot(1, 18200),
      FlSpot(2, 15600),
      FlSpot(3, 22000),
      FlSpot(4, 19800),
      FlSpot(5, 27400),
      FlSpot(6, 31200),
    ];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: (isDark ? AppColor.ninjaDivider : AppColor.lightDivider),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '${(v / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColor.darkTextHint
                        : AppColor.lightTextHint,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[v.toInt()],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColor.darkTextHint
                        : AppColor.lightTextHint,
                  ),
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primary,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: primary.withOpacity(0.1),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

// ── Tier Breakdown ────────────────────────────────────────────────────────────

class _TierBreakdown extends StatelessWidget {
  const _TierBreakdown({required this.isDark});
  final bool isDark;

  static const _tiers = [
    ('Business', 'SAR 42,000', AppColor.tierBusiness, 0.65),
    ('Premium', 'SAR 28,400', AppColor.tierPremium, 0.44),
    ('Elite', 'SAR 18,200', AppColor.tierElite, 0.28),
    ('Gold', 'SAR 12,100', AppColor.tierGold, 0.19),
    ('Basic', 'SAR 3,200', AppColor.tierBasic, 0.05),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        children: _tiers.map((t) {
          final (name, value, color, pct) = t;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      value,
                      style: TextStyle(
                        fontSize: 13,
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
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Payout Queue ─────────────────────────────────────────────────────────────

class _PayoutModel {
  const _PayoutModel(this.shopName, this.amount, this.date, this.status);
  final String shopName;
  final String amount;
  final String date;
  final String status; // 'pending' | 'approved' | 'rejected'
}

final _mockPayouts = [
  const _PayoutModel('Ahmad Barber', 'SAR 12,400', '27 Feb', 'pending'),
  const _PayoutModel('Style Palace', 'SAR 8,700', '25 Feb', 'pending'),
  const _PayoutModel('Nailem Salon', 'SAR 5,300', '24 Feb', 'approved'),
  const _PayoutModel('The Fade Shop', 'SAR 19,200', '22 Feb', 'rejected'),
];

class _PayoutQueue extends StatelessWidget {
  const _PayoutQueue({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: _mockPayouts.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final statusColor = p.status == 'pending'
              ? AppColor.warning
              : p.status == 'approved'
              ? AppColor.success
              : AppColor.error;
          return Column(
            children: [
              ListTile(
                title: Text(
                  p.shopName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${p.amount} · ${p.date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary,
                  ),
                ),
                trailing: p.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionChip('Approve', AppColor.success, () {}),
                          const SizedBox(width: 6),
                          _ActionChip('Reject', AppColor.error, () {}),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          p.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              if (i < _mockPayouts.length - 1)
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

class _ActionChip extends StatelessWidget {
  const _ActionChip(this.label, this.color, this.onTap);
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget _SectionLabel(String text, BuildContext context) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
);
