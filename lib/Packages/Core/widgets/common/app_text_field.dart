// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_color.dart';
// import 'package:easy_localization/easy_localization.dart';

/// Themed input field that adapts to the active theme accent.
///
/// ```dart
/// AppTextField(
///   label: "email".tr(),
///   hint: 'you@example.com',
///   controller: _emailCtrl,
///   prefixIcon: Icons.email_outlined,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: _obscure ? 1 : widget.maxLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isDark ? AppColor.darkText : AppColor.lightText,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(
          color: isDark
              ? AppColor.darkTextSecondary
              : AppColor.lightTextSecondary,
          fontSize: 14,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: 20,
                color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark
                      ? AppColor.darkTextHint
                      : AppColor.lightTextHint,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon != null
            ? IconButton(
                icon: Icon(widget.suffixIcon, size: 20, color: primary),
                onPressed: widget.onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: isDark ? AppColor.ninjaDivider : AppColor.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: isDark ? AppColor.ninjaDivider : AppColor.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColor.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColor.error, width: 2),
        ),
        filled: true,
        fillColor: isDark ? AppColor.ninjaSurface : AppColor.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
