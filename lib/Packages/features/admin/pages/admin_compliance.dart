// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';

/// Super Admin — Compliance & Violations Page.
class AdminCompliancePage extends StatelessWidget {
  const AdminCompliancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Compliance & Violations')),
      drawer: const AppDrawer(
        role: UserRole.admin,
        currentRoute: '/admin/compliance',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Summary', context),
          const SizedBox(height: 12),
          _ComplianceSummary(isDark: isDark),
          const SizedBox(height: 24),
          _SectionLabel('Open Disputes', context),
          const SizedBox(height: 12),
          _DisputeQueue(isDark: isDark),
          const SizedBox(height: 24),
          _SectionLabel('Content Moderation', context),
          const SizedBox(height: 12),
          _ModerationToggles(isDark: isDark),
        ],
      ),
    );
  }
}

class _ComplianceSummary extends StatelessWidget {
  const _ComplianceSummary({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard('12', 'Open Disputes', AppColor.error, context),
        const SizedBox(width: 10),
        _StatCard('5', 'Violations', AppColor.warning, context),
        const SizedBox(width: 10),
        _StatCard('48h', 'Avg. Resolution', AppColor.navyPrimary, context),
      ],
    );
  }
}

Widget _StatCard(
  String value,
  String label,
  Color color,
  BuildContext context,
) {
  return Expanded(
    child: AppCard(
      type: AppCardType.elevated,
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
}

// ── Dispute Queue ─────────────────────────────────────────────────────────────

class _DisputeModel {
  const _DisputeModel(
    this.id,
    this.summary,
    this.user,
    this.date,
    this.priority,
  );
  final String id;
  final String summary;
  final String user;
  final String date;
  final String priority; // 'high' | 'medium' | 'low'
}

final _disputes = [
  const _DisputeModel(
    '#D-4821',
    'Customer requesting refund for no-show expert',
    '@ahmed.r',
    '27 Feb',
    'high',
  ),
  const _DisputeModel(
    '#D-4818',
    'Inappropriate behaviour report',
    '@walid.cuts',
    '26 Feb',
    'high',
  ),
  const _DisputeModel(
    '#D-4812',
    'Fake review submitted',
    '@user_x99',
    '24 Feb',
    'medium',
  ),
  const _DisputeModel(
    '#D-4809',
    'Booking cancellation dispute',
    '@sara.o',
    '23 Feb',
    'low',
  ),
];

class _DisputeQueue extends StatelessWidget {
  const _DisputeQueue({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: _disputes.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          final priorityColor = d.priority == 'high'
              ? AppColor.error
              : d.priority == 'medium'
              ? AppColor.warning
              : AppColor.success;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          d.id,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            d.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color: priorityColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          d.date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.summary,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Reported by ${d.user}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Resolve',
                            onPressed: () {
                              AppSnackBar.info(
                                context,
                                'feature_coming_soon'.tr(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SecondaryButton(
                            text: 'Dismiss',
                            onPressed: () {
                              AppSnackBar.info(
                                context,
                                'feature_coming_soon'.tr(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DangerButton(
                            text: 'Escalate',
                            onPressed: () {
                              AppSnackBar.info(
                                context,
                                'feature_coming_soon'.tr(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < _disputes.length - 1)
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

// ── Moderation Toggles ────────────────────────────────────────────────────────

class _ModerationToggles extends StatefulWidget {
  const _ModerationToggles({required this.isDark});
  final bool isDark;

  @override
  State<_ModerationToggles> createState() => _ModerationTogglesState();
}

class _ModerationTogglesState extends State<_ModerationToggles> {
  var _autoFlag = true;
  var _requireApproval = false;
  var _aiReview = true;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _Toggle(
            'Auto-flag offensive content',
            _autoFlag,
            (v) => setState(() => _autoFlag = v),
          ),
          Divider(
            height: 1,
            color: widget.isDark
                ? AppColor.ninjaDivider
                : AppColor.lightDivider,
          ),
          _Toggle(
            'Require admin approval for new salons',
            _requireApproval,
            (v) => setState(() => _requireApproval = v),
          ),
          Divider(
            height: 1,
            color: widget.isDark
                ? AppColor.ninjaDivider
                : AppColor.lightDivider,
          ),
          _Toggle(
            'AI-assisted review queue',
            _aiReview,
            (v) => setState(() => _aiReview = v),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle(this.label, this.value, this.onChanged);
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }
}

Widget _SectionLabel(String text, BuildContext context) => Text(
  text,
  style: Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
);
