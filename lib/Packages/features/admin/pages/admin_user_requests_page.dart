import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';

/// Admin User Requests page.
///
/// Lists all service requests from users with filters:
/// - Age: Today / This Week / This Month / All
/// - Role: All / Customer / Owner / Employee / Receptionist / Intern / Co-founder
/// - Subscription: All / Artisan / Studio / Elite / Empire
class AdminUserRequestsPage extends StatefulWidget {
  const AdminUserRequestsPage({super.key});

  @override
  State<AdminUserRequestsPage> createState() => _AdminUserRequestsPageState();
}

class _AdminUserRequestsPageState extends State<AdminUserRequestsPage> {
  // ─── Filter State ─────────────────────────────────────────────────────────────
  String _ageFilter = 'all';
  String _roleFilter = 'all';
  String _subFilter = 'all';
  String _searchQuery = '';

  bool _isLoading = false;
  List<Map<String, dynamic>> _requests = [];

  final List<(String, String)> _ageOptions = [
    ('all', 'All'),
    ('today', 'Today'),
    ('week', 'This Week'),
    ('month', 'This Month'),
  ];

  final List<(String, String)> _roleOptions = [
    ('all', 'All Roles'),
    ('CUSTOMER', 'Customer'),
    ('OWNER', 'Owner'),
    ('EMPLOYEE', 'Employee'),
    ('RECEPTIONIST', 'Receptionist'),
    ('INTERN', 'Intern'),
    ('COFOUNDER', 'Co-Founder'),
  ];

  final List<(String, String)> _subOptions = [
    ('all', 'All Plans'),
    ('ARTISAN', 'Artisan'),
    ('STUDIO', 'Studio'),
    ('ELITE', 'Elite'),
    ('EMPIRE', 'Empire'),
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<AdminAnalyticsProvider>();
      final data = await provider.fetchServiceRequests(
        ageFilter: _ageFilter,
        roleFilter: _roleFilter,
        subFilter: _subFilter,
      );
      setState(() => _requests = List<Map<String, dynamic>>.from(data ?? _mockRequests()));
    } catch (_) {
      setState(() => _requests = _mockRequests());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Mock data for when API is not yet connected ──────────────────────────────
  List<Map<String, dynamic>> _mockRequests() {
    return [
      {'id': 1, 'type': 'Bug Report', 'user': 'Ahmad Khalil', 'role': 'CUSTOMER', 'plan': 'N/A', 'submitted': '2026-04-16T08:30:00Z', 'status': 'OPEN', 'suggestion': 'The booking calendar crashes when selecting dates in January.'},
      {'id': 2, 'type': 'Feature Request', 'user': 'Na3eeman Salon', 'role': 'OWNER', 'plan': 'ELITE', 'submitted': '2026-04-15T14:22:00Z', 'status': 'OPEN', 'suggestion': 'Please add a bulk reschedule option for appointments.'},
      {'id': 3, 'type': 'Feature Request', 'user': 'Sara Al-Hassan', 'role': 'RECEPTIONIST', 'plan': 'STUDIO', 'submitted': '2026-04-14T09:15:00Z', 'status': 'RESOLVED', 'suggestion': 'Can we add a customer note field in the booking form?'},
      {'id': 4, 'type': 'Usage Abuse', 'user': 'Unknown User', 'role': 'CUSTOMER', 'plan': 'N/A', 'submitted': '2026-04-13T17:45:00Z', 'status': 'IN_REVIEW', 'suggestion': 'User is spamming fake reviews on multiple salons.'},
      {'id': 5, 'type': 'Bug Report', 'user': 'Business Core', 'role': 'COFOUNDER', 'plan': 'EMPIRE', 'submitted': '2026-04-12T11:00:00Z', 'status': 'OPEN', 'suggestion': 'Export file is missing the date column in CSV format.'},
    ];
  }

  List<Map<String, dynamic>> get _filteredRequests {
    return _requests.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r['user'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r['type'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r['suggestion'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'all' || r['role'] == _roleFilter;
      final matchesSub = _subFilter == 'all' || r['plan'] == _subFilter;
      return matchesSearch && matchesRole && matchesSub;
    }).toList();
  }

  Future<void> _markResolved(Map<String, dynamic> req) async {
    setState(() => req['status'] = 'RESOLVED');
    AppSnackBar.success(context, AppLocalizations.of(context)!.requestResolved);
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final accent = const Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.userRequests,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSpacing.fontLg)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildSearchBar(isDark),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: Column(
          children: [
            // ── Filter chips ─────────────────────────────────────────────────
            _buildFilterRow(l10n, isDark, accent),

            // ── Badge counters row ───────────────────────────────────────────
            _buildBadgeRow(isDark),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRequests.isEmpty
                      ? _buildEmpty(l10n, isDark)
                      : ListView.separated(
                          padding: AppSpacing.pagePadding,
                          itemCount: _filteredRequests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listGap),
                          itemBuilder: (_, i) => _buildRequestCard(
                            _filteredRequests[i], isDark, accent, l10n,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: AppSpacing.sm),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search requests…',
          prefixIcon: const Icon(Icons.search_rounded, size: AppSpacing.iconMd),
          filled: true,
          fillColor: isDark ? AppColors.almostBlack500 : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: AppSpacing.brRound,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        ),
      ),
    );
  }

  // ── Filter chips row ──────────────────────────────────────────────────────────

  Widget _buildFilterRow(AppLocalizations l10n, bool isDark, Color accent) {
    return Container(
      color: isDark ? AppColors.almostBlack700 : Colors.grey[50],
      child: Column(
        children: [
          // Age tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: AppSpacing.sm),
            child: Row(
              children: _ageOptions.map((o) {
                final (value, label) = o;
                final selected = _ageFilter == value;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: accent,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: AppSpacing.fontMd,
                    ),
                    onSelected: (_) => setState(() {
                      _ageFilter = value;
                      _loadRequests();
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          // Role + Sub dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: Row(
              children: [
                Expanded(child: _buildDropdown(
                  'Role',
                  _roleFilter,
                  _roleOptions,
                  isDark,
                  (v) => setState(() { _roleFilter = v!; _loadRequests(); }),
                )),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildDropdown(
                  'Plan',
                  _subFilter,
                  _subOptions,
                  isDark,
                  (v) => setState(() { _subFilter = v!; _loadRequests(); }),
                )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String current, List<(String, String)> options, bool isDark, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack500 : Colors.white,
        borderRadius: AppSpacing.brSm,
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          style: TextStyle(
            fontSize: AppSpacing.fontMd,
            color: isDark ? Colors.white : AppColors.almostBlack,
          ),
          dropdownColor: isDark ? AppColors.almostBlack600 : Colors.white,
          onChanged: onChanged,
          items: options.map((o) {
            final (value, label) = o;
            return DropdownMenuItem(value: value, child: Text(label));
          }).toList(),
        ),
      ),
    );
  }

  // ── Badge counters ────────────────────────────────────────────────────────────

  Widget _buildBadgeRow(bool isDark) {
    final open = _filteredRequests.where((r) => r['status'] == 'OPEN').length;
    final inReview = _filteredRequests.where((r) => r['status'] == 'IN_REVIEW').length;
    final resolved = _filteredRequests.where((r) => r['status'] == 'RESOLVED').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _buildBadge('Open', '$open', AppColors.error, isDark),
          const SizedBox(width: AppSpacing.sm),
          _buildBadge('In Review', '$inReview', AppColors.warning, isDark),
          const SizedBox(width: AppSpacing.sm),
          _buildBadge('Resolved', '$resolved', AppColors.success, isDark),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppSpacing.brSm,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: AppSpacing.fontXl, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: AppSpacing.fontXs, color: color)),
          ],
        ),
      ),
    );
  }

  // ── Request card ──────────────────────────────────────────────────────────────

  Widget _buildRequestCard(Map<String, dynamic> req, bool isDark, Color accent, AppLocalizations l10n) {
    final status = req['status'] as String;
    Color statusColor = switch (status) {
      'RESOLVED' => AppColors.success,
      'IN_REVIEW' => AppColors.warning,
      _ => AppColors.error,
    };

    final type = req['type'] as String;
    final typeIcon = switch (type) {
      'Bug Report' => Icons.bug_report_rounded,
      'Feature Request' => Icons.lightbulb_rounded,
      'Usage Abuse' => Icons.report_rounded,
      _ => Icons.inbox_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: AppSpacing.brLg,
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.brLg,
        child: InkWell(
          borderRadius: AppSpacing.brLg,
          onTap: () => _showDetailSheet(req, isDark, accent, l10n),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: AppSpacing.brXs,
                      ),
                      child: Icon(typeIcon, color: accent, size: AppSpacing.iconMd),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(type,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSpacing.fontMd),
                    )),
                    _buildStatusChip(status, statusColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Suggestion preview
                Text(req['suggestion'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSpacing.fontMd,
                    color: isDark ? AppColors.cream100 : AppColors.almostBlack700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Footer
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: AppSpacing.iconSm, color: AppColors.almostBlack300),
                    const SizedBox(width: AppSpacing.xs),
                    Text(req['user'] as String, style: const TextStyle(fontSize: AppSpacing.fontSm, color: AppColors.almostBlack300)),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withOpacity(0.07) : AppColors.almostBlack50,
                        borderRadius: AppSpacing.brXs,
                      ),
                      child: Text(req['role'] as String,
                        style: const TextStyle(fontSize: AppSpacing.fontXs, fontWeight: FontWeight.bold)),
                    ),
                    if (req['plan'] != 'N/A') ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: AppSpacing.brXs,
                        ),
                        child: Text(req['plan'] as String,
                          style: TextStyle(fontSize: AppSpacing.fontXs, color: accent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const Spacer(),
                    Text(_formatDate(req['submitted'] as String),
                      style: const TextStyle(fontSize: AppSpacing.fontXs, color: AppColors.almostBlack300)),
                  ],
                ),

                // Action row for open requests
                if (status != 'RESOLVED') ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () => _markResolved(req),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: AppSpacing.iconSm),
                      label: Text(l10n.markResolved, style: const TextStyle(fontSize: AppSpacing.fontSm)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.success),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.brSm,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: AppSpacing.fontXs, fontWeight: FontWeight.bold)),
    );
  }

  // ── Detail Sheet ──────────────────────────────────────────────────────────────

  void _showDetailSheet(Map<String, dynamic> req, bool isDark, Color accent, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: AppSpacing.brSheet,
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white.withOpacity(0.2) : AppColors.almostBlack100,
                  borderRadius: AppSpacing.brRound,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: AppSpacing.sheetPadding,
                  children: [
                    Text(req['type'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSpacing.fontXl)),
                    const SizedBox(height: AppSpacing.md),
                    _detailRow(l10n.submittedBy, req['user'] as String, Icons.person_rounded),
                    _detailRow('Role', req['role'] as String, Icons.badge_rounded),
                    _detailRow('Plan', req['plan'] as String, Icons.star_rounded),
                    _detailRow(l10n.submittedAt, _formatDate(req['submitted'] as String), Icons.access_time_rounded),
                    _detailRow(l10n.requestStatus, (req['status'] as String).replaceAll('_', ' '), Icons.info_rounded),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSpacing.fontMd)),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.almostBlack700 : Colors.grey[50],
                        borderRadius: AppSpacing.brMd,
                      ),
                      child: Text(req['suggestion'] as String, style: const TextStyle(fontSize: AppSpacing.fontMd, height: 1.6)),
                    ),
                    if (req['status'] != 'RESOLVED') ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: AppSpacing.buttonHeight,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _markResolved(req);
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: Text(l10n.markResolved),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconMd, color: AppColors.almostBlack300),
          const SizedBox(width: AppSpacing.md),
          Text('$label: ', style: const TextStyle(color: AppColors.almostBlack300, fontSize: AppSpacing.fontMd)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSpacing.fontMd))),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmpty(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: AppColors.almostBlack100),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noRequests,
            style: const TextStyle(fontSize: AppSpacing.fontLg, fontWeight: FontWeight.bold, color: AppColors.almostBlack300)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
