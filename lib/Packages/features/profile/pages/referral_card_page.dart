import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// Referral Programme page — WAJ parity
/// Customer sees their personal referral code and share it.
class ReferralCardPage extends StatefulWidget {
  const ReferralCardPage({super.key});

  @override
  State<ReferralCardPage> createState() => _ReferralCardPageState();
}

class _ReferralCardPageState extends State<ReferralCardPage> {
  Map<String, dynamic>? _referral;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();
      final res = await api.get('/loyalty/referral/');
      if (res is Map) {
        setState(() => _referral = Map<String, dynamic>.from(res));
      } else if (res is List && res.isNotEmpty) {
        setState(() => _referral = Map<String, dynamic>.from(res.first as Map));
      }
    } catch (e) {
      // If 404, create a referral code automatically
      try {
        final api = ApiService();
        final res = await api.post('/loyalty/referral/', data: {});
        if (res is Map) {
          setState(() => _referral = Map<String, dynamic>.from(res));
        }
      } catch (createErr) {
        setState(() => _error = createErr.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppSnackBar.success(context, 'Referral code copied: $code');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Referral Programme'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(theme),
                      const SizedBox(height: 24),
                      _buildStatsRow(theme),
                      const SizedBox(height: 24),
                      _buildHowItWorks(theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    final code = _referral?['code'] as String? ?? '—';
    final uses = (_referral?['uses_count'] as num?)?.toInt() ?? 0;
    final rewards = (_referral?['rewards_given'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard_rounded, size: 52, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Invite friends, earn rewards',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your unique code and earn loyalty points when friends book their first appointment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Code box
          GestureDetector(
            onTap: () => _copyCode(code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: 6,
                      color: const Color(0xFFEC4899),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.copy_rounded, color: Color(0xFFEC4899), size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copyCode(code),
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              label: const Text('Copy & Share Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final uses = (_referral?['uses_count'] as num?)?.toInt() ?? 0;
    final rewards = (_referral?['rewards_given'] as num?)?.toInt() ?? 0;
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Friends Invited', value: '$uses', icon: Icons.people_rounded, color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Rewards Earned', value: '$rewards pts', icon: Icons.stars_rounded, color: Colors.amber)),
      ],
    );
  }

  Widget _buildHowItWorks(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How It Works', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _Step(number: 1, text: 'Share your referral code with a friend'),
        _Step(number: 2, text: 'They register using your code'),
        _Step(number: 3, text: 'They complete their first appointment'),
        _Step(number: 4, text: 'You both earn loyalty points!'),
      ],
    );
  }

  Widget _buildError(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            const Text('Could not load referral code', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF43F5E)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
