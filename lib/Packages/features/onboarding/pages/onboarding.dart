import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/utils/helpers/themes_helpers.dart';
import '../../../../Packages/Core/widgets/common/app_button.dart';
import '../../../../Providers/app_providers.dart';
import 'package:provider/provider.dart';

/// Three-step onboarding flow.
/// Step 1: Welcome — Step 2: Pick Gender (sets theme accent) — Step 3: Pick Role.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageCtrl = PageController();
  int _page = 0;

  UserGender? _gender;
  bool _isCustomer = true;

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Subtle gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColor.ninjaBlack, AppColor.ninjaCard]
                    : [AppColor.bananaCream, AppColor.bananaCream2],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                        ? AppColor.ninjaDivider
                                        : AppColor.lightDivider),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (p) => setState(() => _page = p),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomePage(),
                      _GenderPage(
                        selectedGender: _gender,
                        onSelect: (g) {
                          setState(() => _gender = g);
                        },
                      ),
                      _RolePage(
                        isCustomer: _isCustomer,
                        onSelect: (v) => setState(() => _isCustomer = v),
                      ),
                    ],
                  ),
                ),

                // Bottom CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      AppButton(
                        label: _page == 2 ? 'Get Started' : 'Continue',
                        fullWidth: true,
                        icon: _page == 2 ? Icons.arrow_forward_rounded : null,
                        onPressed: (_page == 1 && _gender == null)
                            ? null
                            : _next,
                      ),
                      if (_page == 0) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            'Already have an account? Log in',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColor.darkTextSecondary
                                  : AppColor.lightTextSecondary,
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
        ],
      ),
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cut_rounded, size: 60, color: primary),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to Na3eeman',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your premium barber booking experience.\nBook, manage, and discover the best barbers near you.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Gender (accent theme picker) ─────────────────────────────────────

class _GenderPage extends StatelessWidget {
  const _GenderPage({required this.selectedGender, required this.onSelect});
  final UserGender? selectedGender;
  final ValueChanged<UserGender> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Personalise Your Theme',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll tailor the app colours to your preference.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _GenderCard(
                label: 'Male',
                emoji: '✂️',
                accent: AppColor.navyPrimary,
                bgTint: AppColor.navyBgTint,
                isSelected: selectedGender == UserGender.male,
                onTap: () => onSelect(UserGender.male),
              ),
              const SizedBox(width: 16),
              _GenderCard(
                label: 'Female',
                emoji: '💅',
                accent: AppColor.pinkPrimary,
                bgTint: AppColor.pinkBgTint,
                isSelected: selectedGender == UserGender.female,
                onTap: () => onSelect(UserGender.female),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => onSelect(UserGender.nonBinary),
            child: const Text(
              'Prefer not to say',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.emoji,
    required this.accent,
    required this.bgTint,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final String emoji;
  final Color accent;
  final Color bgTint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.1)
                : bgTint.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected ? accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? accent : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 3: Role ─────────────────────────────────────────────────────────────

class _RolePage extends StatelessWidget {
  const _RolePage({required this.isCustomer, required this.onSelect});
  final bool isCustomer;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How will you use Na3eeman?',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _RoleTile(
            icon: Icons.person_rounded,
            label: 'I\'m a Customer',
            description: 'Book appointments and discover barbers.',
            isSelected: isCustomer,
            primary: primary,
            onTap: () => onSelect(true),
          ),
          const SizedBox(height: 14),
          _RoleTile(
            icon: Icons.cut_rounded,
            label: 'I\'m a Barber / Staff',
            description: 'Manage your shop, bookings, and team.',
            isSelected: !isCustomer,
            primary: primary,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.08)
              : (isDark ? AppColor.ninjaCard : AppColor.lightSurface),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark ? AppColor.ninjaDivider : AppColor.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? primary : AppColor.lightTextHint,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primary, size: 22),
          ],
        ),
      ),
    );
  }
}
