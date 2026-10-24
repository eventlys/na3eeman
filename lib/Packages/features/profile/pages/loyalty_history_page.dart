import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// Loyalty Points History page — WAJ + Fresha parity
/// Shows the customer's current balance and full transaction log.
class LoyaltyHistoryPage extends StatefulWidget {
  const LoyaltyHistoryPage({super.key});

  @override
  State<LoyaltyHistoryPage> createState() => _LoyaltyHistoryPageState();
}

class _LoyaltyHistoryPageState extends State<LoyaltyHistoryPage> {
  Map<String, dynamic>? _balance;
  List<Map<String, dynamic>> _transactions = [];
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
      final balanceRes = await context.read<PointsProvider>().apiGet(
        '/loyalty/balance/',
      );

      if (balanceRes is Map) {
        _balance = Map<String, dynamic>.from(balanceRes);
        if (_balance!['transactions'] is List) {
          _transactions = List<Map<String, dynamic>>.from(
            (_balance!['transactions'] as List).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          );
        }
      }
    } catch (e) {
      _error = e.toString();
      if (mounted) AppSnackBar.error(context, 'Could not load loyalty data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('loyalty_points_title'.tr()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _balance == null
          ? _buildError(theme)
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildBalanceCard(theme)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        'Transaction History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_transactions.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty(theme))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _TxTile(tx: _transactions[i]),
                        childCount: _transactions.length,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    final points = (_balance?['points'] as num?)?.toInt() ?? 0;
    final freeAvailable =
        (_balance?['free_haircuts_available'] as num?)?.toInt() ?? 0;
    final progress = (_balance?['free_haircut_progress'] as num?)?.toInt() ?? 0;
    final jodValue = points / 200.0;
    final hasPenalty = (_balance?['has_pending_penalty'] ?? false);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasPenalty
              ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
              : [const Color(0xFF6C63FF), const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (hasPenalty ? const Color(0xFFFF5252) : const Color(0xFF6C63FF))
                    .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Points',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '$points pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '≈ ${jodValue.toStringAsFixed(2)} JOD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  hasPenalty
                      ? Icons.warning_amber_rounded
                      : Icons.stars_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (hasPenalty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '⚠️ Potential penalty detected for unpaid appointments (>24h). Please settle your balance.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(label: 'Free Cuts', value: '$freeAvailable'),
              const SizedBox(width: 12),
              _StatChip(label: 'Progress', value: '$progress / 10'),
            ],
          ),
          if (progress > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (progress / 10.0).clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${10 - progress.clamp(0, 10)} more appointments for a free haircut',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) => Padding(
    padding: const EdgeInsets.all(60),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_rounded, size: 56, color: theme.hintColor),
        const SizedBox(height: 16),
        Text(
          'No transactions yet',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    ),
  );

  Widget _buildError(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(_error ?? 'An error occurred', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('retry'.tr()),
        ),
      ],
    ),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxTile({required this.tx});

  static const _sourceIcons = <String, IconData>{
    'INVITE': Icons.person_add_rounded,
    'APPOINTMENT': Icons.calendar_today_rounded,
    'REVIEW_SALON': Icons.star_rounded,
    'EARLY': Icons.alarm_on_rounded,
    'LATE': Icons.alarm_off_rounded,
    'GIFT': Icons.card_giftcard_rounded,
    'TIP': Icons.attach_money_rounded,
    'FREE_CUT': Icons.content_cut_rounded,
    'PAYMENT_REDEEM': Icons.shopping_bag_rounded,
    'ADMIN': Icons.admin_panel_settings_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pts = (tx['points'] as num?)?.toInt() ?? 0;
    final isPositive = pts >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final source = tx['source'] as String? ?? '';
    final icon = _sourceIcons[source] ?? Icons.swap_horiz_rounded;
    final label = tx['formatted_source'] as String? ?? source;
    final ts = tx['timestamp'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (ts.isNotEmpty)
                    Text(
                      ts.length >= 10 ? ts.substring(0, 10) : ts,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}$pts pts',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
