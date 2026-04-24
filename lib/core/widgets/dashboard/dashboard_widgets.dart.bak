import 'package:flutter/material.dart';
import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../buttons/styled_buttons.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Providers/features/auth_provider.dart';


class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border; // Changed from Border to BoxBorder for correctness
  final double borderRadius;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.border,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.almostBlack600 : AppColors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50,
        ),
      ),
      child: child,
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onPressed;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionText = 'View List',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (onPressed != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              actionText,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12),
          ),
        ],
      ),
    );
  }
}




class GlobalSearchBar extends StatelessWidget {
  const GlobalSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Management roles (Owner, Receptionist) navigate to staff list
    final isManagement = user?.isOwner == true || user?.isReceptionist == true;

    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack500 : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          readOnly: true,
          onTap: () => Navigator.pushNamed(context, isManagement ? '/staff' : '/salons'),
          decoration: InputDecoration(
            hintText: isManagement 
                ? (AppLocalizations.of(context)?.employeeManagement ?? 'Staff Management')
                : AppLocalizations.of(context)!.searchServicesSalons,
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 7),
          ),
        ),
      ),
    );
  }
}

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    final apiService = ApiService();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.helpUsImprove),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.tellOthers,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (feedbackController.text.isNotEmpty) {
                final response = await apiService.submitServiceRequest({'suggestion': feedbackController.text});
                final bool success = response != null;
                if (success) {
                   if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.success)),
                      );
                   }
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.helpUsImprove,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.requestNewService,
            style: TextStyle(
                color: isDark ? AppColors.cream600 : AppColors.almostBlack400,
                fontSize: 14),
          ),
          const SizedBox(height: 20),
          SecondaryButton(
            text: AppLocalizations.of(context)!.submitSuggestion,
            onPressed: () => _showFeedbackDialog(context),
          ),
        ],
      ),
    );
  }
}
