import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../Packages/Core/constants/app_roles.dart';
import '../../../l10n/app_localizations.dart';

/// Canonical Rules & User Guide bottom sheet.
///
/// Call via:
/// ```dart
/// RulesGuideSheet.showRules(context);
/// RulesGuideSheet.showGuide(context);
/// ```
class RulesGuideSheet extends StatelessWidget {
  final bool showGuide; // false = rules mode, true = guide mode

  const RulesGuideSheet({super.key, required this.showGuide});

  // ─── Public Static Methods ───────────────────────────────────────────────────

  static Future<void> showRulesSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RulesGuideSheet(showGuide: false),
    );
  }

  static Future<void> showGuideSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RulesGuideSheet(showGuide: true),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  UserRole _currentRole(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return user?.role ?? UserRole.customer;
  }

  String _currentRoleName(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return l10n.rulesOwner.split('\n').first.isEmpty ? 'Owner' : 'Owner';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.cofounder:
        return l10n.cofounder;
      case UserRole.intern:
        return 'Intern';
      case UserRole.barber:
      case UserRole.employee:
        return 'Employee';
      default:
        return 'Customer';
    }
  }

  String _rulesText(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return l10n.rulesOwner;
      case UserRole.receptionist:
        return l10n.rulesReceptionist;
      case UserRole.cofounder:
        return l10n.rulesCofounder;
      case UserRole.intern:
        return l10n.rulesIntern;
      case UserRole.barber:
      case UserRole.employee:
        return l10n.rulesEmployee;
      default:
        return l10n.rulesCustomer;
    }
  }

  String _guideText(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return l10n.guideOwner;
      case UserRole.receptionist:
        return l10n.guideReceptionist;
      case UserRole.cofounder:
        return l10n.guideCofounder;
      case UserRole.intern:
        return l10n.guideIntern;
      case UserRole.barber:
      case UserRole.employee:
        return l10n.guideEmployee;
      default:
        return l10n.guideCustomer;
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = _currentRole(context);
    final text = showGuide ? _guideText(context, role) : _rulesText(context, role);
    final title = showGuide ? l10n.userGuideTitle : l10n.appRulesTitle;
    final icon = showGuide ? Icons.menu_book_rounded : Icons.gavel_rounded;
    final accent = showGuide ? const Color(0xFF1565C0) : const Color(0xFF6A1B9A);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: AppSpacing.brSheet,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white.withOpacity(0.2) : AppColors.almostBlack100,
                  borderRadius: AppSpacing.brRound,
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageH,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: AppSpacing.brSm,
                      ),
                      child: Icon(icon, color: accent, size: AppSpacing.iconBase),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                            style: TextStyle(
                              fontSize: AppSpacing.fontLg,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.almostBlack,
                            ),
                          ),
                          Text(
                            l10n.rulesForYourRole,
                            style: TextStyle(
                              fontSize: AppSpacing.fontSm,
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: AppSpacing.brSm,
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        _currentRoleName(context, role),
                        style: TextStyle(
                          color: accent,
                          fontSize: AppSpacing.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: isDark ? AppColors.white.withOpacity(0.08) : AppColors.almostBlack50,
                height: 1,
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.pageH),
                  child: _buildContent(context, text, isDark, accent),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH, AppSpacing.sm, AppSpacing.pageH, AppSpacing.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.brMd,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSpacing.fontBase,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String text, bool isDark, Color accent) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: AppSpacing.sm);

        // Numbered rules (1. / ١.)
        final bool isNumbered = RegExp(r'^[\d١٢٣٤٥٦٧٨٩٠]+[.\)]').hasMatch(line.trim());
        // Bullet points
        final bool isBullet = line.trim().startsWith('•') || line.trim().startsWith('-');

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNumbered) ...[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: AppSpacing.brSm,
                  ),
                  child: Text(
                    line.trim().split(RegExp(r'[.\)]')).first,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSpacing.fontSm,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    line.trim().replaceFirst(RegExp(r'^[\d١٢٣٤٥٦٧٨٩٠]+[.\)]\s*'), ''),
                    style: TextStyle(
                      fontSize: AppSpacing.fontMd,
                      color: isDark ? AppColors.cream : AppColors.almostBlack700,
                      height: 1.5,
                    ),
                  ),
                ),
              ] else if (isBullet) ...[
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 7, right: 10, left: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                    style: TextStyle(
                      fontSize: AppSpacing.fontMd,
                      color: isDark ? AppColors.cream : AppColors.almostBlack700,
                      height: 1.5,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: AppSpacing.fontMd,
                      color: isDark ? AppColors.cream : AppColors.almostBlack700,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
