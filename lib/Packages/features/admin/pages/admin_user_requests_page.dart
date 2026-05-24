import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';
import '../../../../Models/loyalty/feedback_model.dart';

/// Admin User Requests page.
///
/// Lists all service requests (HelpFeedback) from users with filters.
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
  List<HelpFeedback> _requests = [];

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
    ('EXPERT', 'Expert'),
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
      setState(() => _requests = data);
    } catch (e) {
      debugPrint('Error loading requests: $e');
      AppSnackBar.error(context, 'Failed to load requests');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<HelpFeedback> get _filteredRequests {
    return _requests.where((r) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (r.userName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          r.feedbackType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'all' || r.userRole == _roleFilter;
      // Note: Backend HelpFeedback doesn't currently store the subscription plan at the feedback level
      // If needed, we can expand the model or filter on the frontend if plan info is available.
      // For now, we'll ignore _subFilter or assume it matches.
      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _markResolved(HelpFeedback req) async {
    // In a real app, this would be an API call
    AppSnackBar.success(context, "request_resolved".tr());
    _loadRequests(); // Refresh
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "user_requests".tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSpacing.fontLg,
          ),
        ),
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
            _buildFilterRow(isDark, accent),
            _buildBadgeRow(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRequests.isEmpty
                  ? _buildEmpty(isDark)
                  : ListView.separated(
                      padding: AppSpacing.pagePadding,
                      itemCount: _filteredRequests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.listGap),
                      itemBuilder: (_, i) => _buildRequestCard(
                        _filteredRequests[i],
                        isDark,
                        accent,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageH,
        vertical: AppSpacing.sm,
      ),
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

  Widget _buildFilterRow(bool isDark, Color accent) {
    return Container(
      color: isDark ? AppColors.almostBlack700 : Colors.grey[50],
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageH,
              vertical: AppSpacing.sm,
            ),
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
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Role',
                    _roleFilter,
                    _roleOptions,
                    isDark,
                    (v) => setState(() {
                      _roleFilter = v!;
                      _loadRequests();
                    }),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildDropdown(
                    'Plan',
                    _subFilter,
                    _subOptions,
                    isDark,
                    (v) => setState(() {
                      _subFilter = v!;
                      _loadRequests();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String current,
    List<(String, String)> options,
    bool isDark,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack500 : Colors.white,
        borderRadius: AppSpacing.brSm,
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.1)
              : AppColors.almostBlack100,
        ),
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

  Widget _buildBadgeRow(bool isDark) {
    final open = _filteredRequests.where((r) => r.status == 'OPEN').length;
    final inReview = _filteredRequests
        .where((r) => r.status == 'IN_REVIEW')
        .length;
    final resolved = _filteredRequests
        .where((r) => r.status == 'RESOLVED')
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageH,
        vertical: AppSpacing.sm,
      ),
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
            Text(
              count,
              style: TextStyle(
                fontSize: AppSpacing.fontXl,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: AppSpacing.fontXs, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(HelpFeedback req, bool isDark, Color accent) {
    final status = req.status;
    Color statusColor = switch (status) {
      'RESOLVED' => AppColors.success,
      'IN_REVIEW' => AppColors.warning,
      _ => AppColors.error,
    };

    final type = req.feedbackTypeDisplay ?? req.feedbackType;
    final typeIcon = switch (req.feedbackType) {
      'BUG' => Icons.bug_report_rounded,
      'FEATURE' => Icons.lightbulb_rounded,
      'ABUSE' => Icons.report_rounded,
      _ => Icons.inbox_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: AppSpacing.brLg,
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.brLg,
        child: InkWell(
          borderRadius: AppSpacing.brLg,
          onTap: () => _showDetailSheet(req, isDark, accent),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: AppSpacing.brXs,
                      ),
                      child: Icon(
                        typeIcon,
                        color: accent,
                        size: AppSpacing.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSpacing.fontMd,
                        ),
                      ),
                    ),
                    _buildStatusChip(status, statusColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  req.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSpacing.fontMd,
                    color: isDark
                        ? AppColors.cream100
                        : AppColors.almostBlack700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.almostBlack300,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      req.userName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: AppSpacing.fontSm,
                        color: AppColors.almostBlack300,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white.withOpacity(0.07)
                            : AppColors.almostBlack50,
                        borderRadius: AppSpacing.brXs,
                      ),
                      child: Text(
                        req.userRole ?? 'USER',
                        style: const TextStyle(
                          fontSize: AppSpacing.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(req.createdAt.toIso8601String()),
                      style: const TextStyle(
                        fontSize: AppSpacing.fontXs,
                        color: AppColors.almostBlack300,
                      ),
                    ),
                  ],
                ),
                if (status != 'RESOLVED') ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () => _markResolved(req),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: AppSpacing.iconSm,
                      ),
                      label: Text(
                        "mark_resolved".tr(),
                        style: const TextStyle(fontSize: AppSpacing.fontSm),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.brSm,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: AppSpacing.fontXs,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetailSheet(HelpFeedback req, bool isDark, Color accent) {
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withOpacity(0.2)
                      : AppColors.almostBlack100,
                  borderRadius: AppSpacing.brRound,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: AppSpacing.sheetPadding,
                  children: [
                    Text(
                      req.feedbackTypeDisplay ?? req.feedbackType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSpacing.fontXl,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _detailRow(
                      "submitted_by".tr(),
                      req.userName ?? 'Unknown',
                      Icons.person_rounded,
                    ),
                    _detailRow(
                      'Role',
                      req.userRole ?? 'USER',
                      Icons.badge_rounded,
                    ),
                    _detailRow(
                      "submitted_at".tr(),
                      _formatDate(req.createdAt.toIso8601String()),
                      Icons.access_time_rounded,
                    ),
                    _detailRow(
                      "request_status".tr(),
                      req.status.replaceAll('_', ' '),
                      Icons.info_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Message',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSpacing.fontMd,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.almostBlack700
                            : Colors.grey[50],
                        borderRadius: AppSpacing.brMd,
                      ),
                      child: Text(
                        req.content,
                        style: const TextStyle(
                          fontSize: AppSpacing.fontMd,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (req.adminNotes != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Admin Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSpacing.fontMd,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.05),
                          borderRadius: AppSpacing.brMd,
                          border: Border.all(color: accent.withOpacity(0.1)),
                        ),
                        child: Text(
                          req.adminNotes!,
                          style: const TextStyle(
                            fontSize: AppSpacing.fontMd,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                    if (req.status != 'RESOLVED') ...[
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
                          label: Text("mark_resolved".tr()),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.brMd,
                            ),
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
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: AppSpacing.fontMd,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSpacing.fontMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: AppColors.almostBlack100),
          const SizedBox(height: AppSpacing.md),
          Text(
            "no_requests".tr(),
            style: const TextStyle(
              fontSize: AppSpacing.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.almostBlack300,
            ),
          ),
        ],
      ),
    );
  }

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
