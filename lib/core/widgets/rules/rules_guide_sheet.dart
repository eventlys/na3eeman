// ignore_for_file: dead_null_aware_expression
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../Packages/Core/constants/app_roles.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Services/content_service.dart';

class RulesGuideSheet extends StatefulWidget {
  final bool showGuide;
  final bool showPrivacy;
  final bool isPointsRules;
  final String? documentSlug;
  final String? documentTitle;

  const RulesGuideSheet({
    super.key,
    required this.showGuide,
    this.showPrivacy = false,
    this.isPointsRules = false,
    this.documentSlug,
    this.documentTitle,
  });

  static Future<void> showPointsRules(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          const RulesGuideSheet(showGuide: false, isPointsRules: true),
    );
  }

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

  static Future<void> showPrivacySheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          const RulesGuideSheet(showGuide: false, showPrivacy: true),
    );
  }

  static Future<void> showLegalDocument(BuildContext context, String slug, String title) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          RulesGuideSheet(showGuide: false, documentSlug: slug, documentTitle: title),
    );
  }

  @override
  State<RulesGuideSheet> createState() => _RulesGuideSheetState();
}

class _RulesGuideSheetState extends State<RulesGuideSheet> {
  final ContentService _contentService = ContentService();
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    final role = context.read<AuthProvider>().user?.role ?? UserRole.customer;
    final roleName = role.toString().split('.').last;

    String fetchedContent = '';
    if (widget.documentSlug != null) {
      fetchedContent = await _contentService.getLegalDocument(widget.documentSlug!);
    } else if (widget.isPointsRules) {
      fetchedContent = await _contentService.getAppRules('LOYALTY');
    } else if (widget.showPrivacy) {
      fetchedContent = await _contentService.getPrivacyPolicy();
    } else if (widget.showGuide) {
      fetchedContent = await _contentService.getUserGuide(roleName);
    } else {
      fetchedContent = await _contentService.getAppRules(roleName);
    }

    if (mounted) {
      setState(() {
        _content = fetchedContent;
        _isLoading = false;
      });
    }
  }

  UserRole _currentRole(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return user?.userRole ?? UserRole.customer;
  }

  String _currentRoleName(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.owner:
      case UserRole.ownerExpert:
        return 'owner'.tr();
      case UserRole.receptionist:
        return 'receptionist'.tr();
      case UserRole.cofounder:
        return "cofounder".tr();
      case UserRole.intern:
        return 'intern'.tr();
      case UserRole.expert:
        return 'expert'.tr();
      default:
        return 'customer'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = _currentRole(context);

    final String title;
    final IconData icon;
    final Color accent;

    if (widget.documentSlug != null) {
      title = widget.documentTitle ?? widget.documentSlug!;
      icon = Icons.description_rounded;
      accent = const Color(0xFF00695C); // Teal variant
    } else if (widget.isPointsRules) {
      title = 'loyalty_points_rules'.tr();
      icon = Icons.stars_rounded;
      accent = AppColors.pink;
    } else {
      title = widget.showPrivacy
          ? "privacy_policy".tr()
          : (widget.showGuide
                ? "user_guide_title".tr()
                : "app_rules_title".tr());
      icon = widget.showPrivacy
          ? Icons.lock_person_rounded
          : (widget.showGuide ? Icons.menu_book_rounded : Icons.gavel_rounded);
      accent = widget.showPrivacy
          ? const Color(0xFF2E7D32)
          : (widget.showGuide
                ? const Color(0xFF1565C0)
                : const Color(0xFF6A1B9A));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.15)
                      : AppColors.almostBlack100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: accent, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'rules_for_role_display'.tr(
                              args: [
                                "rules_for_your_role".tr(),
                                _currentRoleName(context, role),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _content.isEmpty
                    ? Center(
                        child: Text(
                          "no_data_available".tr() ?? 'No content available.',
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: _buildContent(context, _content, isDark, accent),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.almostBlack700
                          : Colors.grey[100],
                      foregroundColor: isDark
                          ? Colors.white
                          : AppColors.almostBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "close".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildContent(
    BuildContext context,
    String text,
    bool isDark,
    Color accent,
  ) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];
    String? currentHeader;
    List<String> currentItems = [];

    void flushSection() {
      if (currentHeader != null) {
        widgets.add(
          _buildAccordionSection(
            context,
            currentHeader!,
            currentItems,
            isDark,
            accent,
          ),
        );
        widgets.add(const SizedBox(height: 12));
      } else if (currentItems.isNotEmpty) {
        widgets.addAll(
          currentItems.map((item) => _buildSimpleLine(item, isDark, accent)),
        );
      }
      currentHeader = null;
      currentItems = [];
    }

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (!trimmed.startsWith('•') &&
          !trimmed.startsWith('-') &&
          !RegExp(r'^[\d١٢٣٤٥٦٧٨٩٠]+[.\)]').hasMatch(trimmed)) {
        flushSection();
        currentHeader = trimmed;
      } else {
        currentItems.add(trimmed);
      }
    }
    flushSection();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildAccordionSection(
    BuildContext context,
    String title,
    List<String> items,
    bool isDark,
    Color accent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack500 : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.info_outline_rounded, color: accent, size: 20),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.almostBlack,
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          children: items
              .map((item) => _buildSimpleLine(item, isDark, accent))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSimpleLine(String line, bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(
              line.replaceFirst(
                RegExp(r'^([•\-]|[\d١٢٣٤٥٦٧٨٩٠]+[.\)])\s*'),
                '',
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
