import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/common/app_text_field.dart';
import '../../../../Helpers/config.dart';

// import 'package:easy_localization/easy_localization.dart';

/// Dispute/Issue Resolution Page.
/// Users can submit a dispute for a booking and track its status.
class DisputeResolutionPage extends StatefulWidget {
  const DisputeResolutionPage({super.key});

  @override
  State<DisputeResolutionPage> createState() => _DisputeResolutionPageState();
}

class _DisputeResolutionPageState extends State<DisputeResolutionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  String _selectedType = 'Booking Issue';
  bool _submitting = false;

  static const _disputeTypes = [
    'Booking Issue',
    'Payment Problem',
    'Staff Behaviour',
    'App Bug',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _submitting = false);
    AppSnackBar.success(
      context,
      'Dispute submitted. We\'ll respond within 48 hours.',
    );
    _descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('report_and_disputes'.tr()),
        bottom: TabBar(
          controller: _tabs,
          labelColor: primary,
          unselectedLabelColor: isDark
              ? AppColor.darkTextHint
              : AppColor.lightTextHint,
          indicatorColor: primary,
          tabs: const [
            Tab(text: 'New Report'),
            Tab(text: 'My Cases'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _NewReportTab(
            formKey: _formKey,
            descCtrl: _descCtrl,
            selectedType: _selectedType,
            onTypeChanged: (v) => setState(() => _selectedType = v),
            disputeTypes: _disputeTypes,
            onSubmit: _submit,
            submitting: _submitting,
            isDark: isDark,
          ),
          _MyCasesTab(isDark: isDark),
        ],
      ),
    );
  }
}

// ── New Report Tab ────────────────────────────────────────────────────────────

class _NewReportTab extends StatelessWidget {
  const _NewReportTab({
    required this.formKey,
    required this.descCtrl,
    required this.selectedType,
    required this.onTypeChanged,
    required this.disputeTypes,
    required this.onSubmit,
    required this.submitting,
    required this.isDark,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController descCtrl;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final List<String> disputeTypes;
  final Future<void> Function() onSubmit;
  final bool submitting;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue type
            Text(
              "issue_type".tr(),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: disputeTypes.map((type) {
                final isSelected = selectedType == type;
                return GestureDetector(
                  onTap: () => onTypeChanged(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                                ? AppColor.ninjaCard
                                : AppColor.bananaCream2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark
                                  ? AppColor.ninjaDivider
                                  : AppColor.borderLight),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Booking reference (optional)
            Text(
              'Booking ID (optional)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const AppTextField(
              hint: 'e.g. BK-2026-4821',
              prefixIcon: Icons.confirmation_number_outlined,
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              'Describe the Issue',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: descCtrl,
              hint: 'Please provide as much detail as possible…',
              maxLines: 5,
              validator: (v) => (v == null || v.length < 20)
                  ? 'Please describe the issue (min 20 characters)'
                  : null,
            ),
            const SizedBox(height: 20),

            // Evidence note
            AppCard(
              type: AppCardType.outlined,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColor.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For payment disputes, please attach your receipt or screenshot via email to ${AppConfig.supportEmail}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: "submit_report".tr(),
              isLoading: submitting,
              icon: Icons.send_rounded,
              onPressed: submitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Cases Tab ─────────────────────────────────────────────────────────────

class _CaseModel {
  const _CaseModel(this.id, this.type, this.status, this.date, this.update);
  final String id;
  final String type;
  final String status; // 'open' | 'in_review' | 'resolved' | 'closed'
  final String date;
  final String update;
}

final _myCases = [
  const _CaseModel(
    '#D-4821',
    'Booking Issue',
    'in_review',
    '27 Feb',
    'Our team is reviewing your case. Estimated resolution: 24 hrs.',
  ),
  const _CaseModel(
    '#D-4718',
    'Payment Problem',
    'resolved',
    '20 Feb',
    'Refund of SAR 120 processed. Allow 3–5 business days.',
  ),
];

class _MyCasesTab extends StatelessWidget {
  const _MyCasesTab({required this.isDark});
  final bool isDark;

  Color _statusColor(String s) {
    switch (s) {
      case 'resolved':
        return AppColor.success;
      case 'in_review':
        return AppColor.warning;
      case 'closed':
        return AppColor.lightTextHint;
      default:
        return AppColor.info;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'in_review':
        return 'In Review';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_myCases.isEmpty) {
      return Center(
        child: Text(
          'No active disputes',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _myCases.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final c = _myCases[i];
        final sc = _statusColor(c.status);
        return AppCard(
          type: AppCardType.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    c.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: sc.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      _statusLabel(c.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: sc,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(c.date, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              Text(c.type, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColor.ninjaSurface : AppColor.bananaCream2,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  c.update,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
