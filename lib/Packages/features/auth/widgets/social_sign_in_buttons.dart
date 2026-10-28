import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../../Services/auth/social_auth_service.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';

/// Google / Apple sign-in buttons row. Calls the native SDKs, then hands the
/// normalized profile to [AuthProvider] social login. On success the caller is
/// responsible for navigation via [onSuccess].
class SocialSignInButtons extends StatefulWidget {
  final VoidCallback? onSuccess;
  final String? selectedRole;
  final String? selectedGender;

  const SocialSignInButtons({
    super.key,
    this.onSuccess,
    this.selectedRole,
    this.selectedGender,
  });

  @override
  State<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends State<SocialSignInButtons> {
  final SocialAuthService _socialAuth = SocialAuthService();
  bool _busy = false;

  Future<void> _handle(SocialProvider provider) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final result = provider == SocialProvider.google
          ? await _socialAuth.signInWithGoogle()
          : await _socialAuth.signInWithApple();

      if (!mounted) return;

      if (result.cancelled) {
        return;
      }
      if (!result.isSuccess) {
        AppSnackBar.error(
          context,
          (result.errorMessage ?? 'social_sign_in_failed').tr(),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final providerName = _socialAuth.providerNameFor(provider);
      final success = await authProvider.login(
        socialProvider: providerName,
        socialData: result.data!,
      );

      if (!mounted) return;

      if (success) {
        widget.onSuccess?.call();
      } else {
        AppSnackBar.error(
          context,
          authProvider.error ?? 'social_sign_in_failed'.tr(),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showApple = _socialAuth.isAppleSignInAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or_continue_with'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        _SocialButton(
          onPressed: _busy ? null : () => _handle(SocialProvider.google),
          icon: Icons.g_mobiledata_rounded,
          label: 'continue_with_google'.tr(),
        ),
        if (showApple) ...[
          const SizedBox(height: 12),
          _SocialButton(
            onPressed: _busy ? null : () => _handle(SocialProvider.apple),
            icon: Icons.apple_rounded,
            label: 'continue_with_apple'.tr(),
            dark: true,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool dark;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = dark
        ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
        : theme.colorScheme.surface;
    final foreground = dark
        ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
        : theme.colorScheme.onSurface;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: background,
        foregroundColor: foreground,
        side: BorderSide(color: theme.dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28, color: foreground),
      label: Text(label),
    );
  }
}
