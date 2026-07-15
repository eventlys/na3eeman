import 'package:flutter/material.dart';
import '../../../../Helpers/password_helper.dart';
import '../constants/app_color.dart';

class PasswordStrengthIndicator extends StatefulWidget {
  final TextEditingController controller;

  const PasswordStrengthIndicator({super.key, required this.controller});

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  final PasswordHelper _passwordHelper = PasswordHelper();
  Map<String, dynamic> _passwordRequirements = {};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updatePasswordRequirements);
    _updatePasswordRequirements();
  }

  @override
  void didUpdateWidget(PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updatePasswordRequirements);
      widget.controller.addListener(_updatePasswordRequirements);
      _updatePasswordRequirements();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePasswordRequirements);
    super.dispose();
  }

  void _updatePasswordRequirements() {
    setState(() {
      _passwordRequirements = _passwordHelper.getPasswordRequirements(
        widget.controller.text,
      );
    });
  }

  Widget _buildPasswordRequirement(
    BuildContext context,
    String text,
    bool isMet,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 16,
          color: isMet
              ? AppColor.featureCheckLight
              : (isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet
                ? AppColor.featureCheckLight
                : (isDark
                      ? AppColor.darkTextSecondary
                      : AppColor.lightTextSecondary),
            decoration: isMet
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
      ],
    );
  }

  double _getStrengthValue(String strength) {
    switch (strength) {
      case 'strong':
        return 1.0;
      case 'good':
        return 0.75;
      case 'fair':
        return 0.5;
      case 'weak':
      default:
        return 0.25;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _passwordRequirements['strength'] ?? 'weak';
    final message = _passwordRequirements['message'] ?? '';
    final requirements = _passwordRequirements['requirements'] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color strengthColor;
    switch (strength) {
      case 'strong':
        strengthColor = isDark
            ? AppColor.featureCheckDark
            : AppColor.featureCheckLight;
        break;
      case 'good':
        strengthColor = isDark ? AppColor.darkInfo : AppColor.lightInfo;
        break;
      case 'fair':
        strengthColor = isDark ? AppColor.darkWarning : AppColor.lightWarning;
        break;
      case 'weak':
      default:
        strengthColor = isDark ? AppColor.darkError : AppColor.lightError;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _getStrengthValue(strength),
          backgroundColor: isDark ? AppColor.darkCard : AppColor.lightCard,
          color: strengthColor,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: requirements
              .where((req) => req['isMet'] != true)
              .map<Widget>((req) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildPasswordRequirement(
                    context,
                    req['text'],
                    req['isMet'],
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }
}
