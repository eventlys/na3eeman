import 'package:flutter/material.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';

/// Rich Analytics Dashboard — WAJ + Bodrah + Fresha parity
/// Revenue chart, staff KPI table, top services, peak hours heatmap,
/// and AI Smart Insights feed.
class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _staffKpis = [];
  List<Map<String, dynamic>> _topServices = [];
  List<Map<String, dynamic>> _insights = [];
  bool _isLoading = true;
  String _period = '7d'; // 7d, 30d, 90d

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      // Fire all requests in parallel
      final results = await Future.wait([
        api.get('/analytics/overview/?period=$_period').catchError((_) => null),
        api.get('/analytics/staff-kpis/').catchError((_) => null),
        api.get('/analytics/top-services/').catchError((_) => null),
        api.get('/analytics/smart-insights/').catchError((_) => null),
      ]);

      setState(() {
        if (results[0] is Map) _summary = Map<String, dynamic>.from(results[0] as Map);
        if (results[1] is List) {
          _staffKpis = List<Map<String, dynamic>>.from(
              (results[1] as List).map((e) => Map<String, dynamic>.from(e as Map)));
        }
        if (results[2] is List) {
          _topServices = List<Map<String, dynamic>>.from(
              (results[2] as List).map((e) => Map<String, dynamic>.from(e as Map)));
        }
        if (results[3] is List) {
          _insights = List<Map<String, dynamic>>.from(
              (results[3] as List).map((e) => Map<String, dynamic>.from(e as Map)));
        } else if (results[3] is Map && results[3]?['insights'] is List) {
          _insights = List<Map<String, dynamic>>.from(
              (results[3]?['insights'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
        }
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          // Period selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range_rounded),
            initialValue: _period,
            onSelected: (v) {
              setState(() => _period = v);
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              PopupMenuItem(value: '90d', child: Text('Last 3 months')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // KPI Cards Row
                  SliverToBoxAdapter(child: _buildKpiRow(theme)),

                  // AI Smart Insights
                  if (_insights.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: '✦ AI Smart Insights', icon: Icons.auto_awesome_rounded)),
                    SliverToBoxAdapter(child: _buildInsightCards(theme)),
                  ],

                  // Top Services
                  if (_topServices.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: 'Top Services', icon: Icons.content_cut_rounded)),
                    SliverToBoxAdapter(child: _buildTopServices(theme)),
                  ],

                  // Staff KPIs
                  if (_staffKpis.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: 'Staff Performance', icon: Icons.people_rounded)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _StaffKpiTile(kpi: _staffKpis[i]),
                        childCount: _staffKpis.length,
                      ),
                    ),
                  ],

                  // Spacer
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiRow(ThemeData theme) {
    final revenue = (_summary?['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final appointments = (_summary?['total_appointments'] as num?)?.toInt() ?? 0;
    final newCustomers = (_summary?['new_customers'] as num?)?.toInt() ?? 0;
    final avgRating = (_summary?['avg_rating'] as num?)?.toDouble() ?? 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      children: [
        _KpiCard(
          label: 'Revenue',
          value: '${revenue.toStringAsFixed(0)} JOD',
          gradient: const [Color(0xFF6C63FF), Color(0xFF3B82F6)],
          icon: Icons.account_balance_wallet_rounded,
        ),
        _KpiCard(
          label: 'Appointments',
          value: '$appointments',
          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
          icon: Icons.calendar_today_rounded,
        ),
        _KpiCard(
          label: 'New Customers',
          value: '$newCustomers',
          gradient: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
          icon: Icons.person_add_rounded,
        ),
        _KpiCard(
          label: 'Avg Rating',
          value: avgRating > 0 ? '${avgRating.toStringAsFixed(1)} ★' : 'N/A',
          gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
          icon: Icons.star_rounded,
        ),
      ],
    );
  }

  Widget _buildInsightCards(ThemeData theme) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        itemCount: _insights.length.clamp(0, 4),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final insight = _insights[i];
          final tip = insight['tip'] as String? ?? insight['message'] as String? ?? 'No tip available';
          final priority = insight['priority'] as String? ?? 'medium';
          final color = priority == 'high' ? const Color(0xFFEF4444)
              : priority == 'medium' ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981);

          return Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, color: color, size: 20),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopServices(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: List.generate(
          _topServices.length.clamp(0, 5),
          (i) {
            final s = _topServices[i];
            final name = s['name'] as String? ?? s['service_name'] as String? ?? 'Service';
            final count = (s['count'] as num?)?.toInt() ?? 0;
            final revenue = (s['revenue'] as num?)?.toDouble() ?? 0.0;
            final pct = i == 0 ? 1.0 : (count / ((_topServices.first['count'] as num?)?.toDouble() ?? 1.0)).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))),
                        ),
                        const SizedBox(width: 10),
                        Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ]),
                      Text('$count bookings  |  ${revenue.toStringAsFixed(0)} JOD',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradient;
  final IconData icon;
  const _KpiCard({required this.label, required this.value, required this.gradient, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StaffKpiTile extends StatelessWidget {
  final Map<String, dynamic> kpi;
  const _StaffKpiTile({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = kpi['name'] as String? ?? kpi['employee_name'] as String? ?? 'Staff';
    final appts = (kpi['appointments'] as num?)?.toInt() ?? 0;
    final rating = (kpi['rating'] as num?)?.toDouble() ?? 0.0;
    final revenue = (kpi['revenue'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('$appts appointments · ${revenue.toStringAsFixed(0)} JOD',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
            if (rating > 0)
              Row(children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 2),
                Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
          ],
        ),
      ),
    );
  }
}
