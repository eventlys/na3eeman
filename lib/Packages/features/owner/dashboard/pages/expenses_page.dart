import 'package:flutter/material.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// Expense management page (WAJ parity).
/// Visible to: Owner (all types), Receptionist, Co-Founder.
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String? _error;

  // Summary
  double get _totalAmount => _expenses.fold(0.0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0.0));

  final _categories = [
    {'value': 'PAYROLL', 'label': 'Payroll', 'icon': Icons.people_rounded, 'color': Colors.blue},
    {'value': 'RENT', 'label': 'Rent', 'icon': Icons.store_rounded, 'color': Colors.purple},
    {'value': 'UTILITY', 'label': 'Utilities', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'value': 'SUPPLIES', 'label': 'Supplies', 'icon': Icons.inventory_2_rounded, 'color': Colors.teal},
    {'value': 'MARKETING', 'label': 'Marketing', 'icon': Icons.campaign_rounded, 'color': Colors.orange},
    {'value': 'MAINTENANCE', 'label': 'Maintenance', 'icon': Icons.build_rounded, 'color': Colors.brown},
    {'value': 'OTHER', 'label': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = ApiService();
      final res = await api.get('/salons/expenses/');
      if (res is List) {
        setState(() => _expenses = List<Map<String, dynamic>>.from(res.map((e) => Map<String, dynamic>.from(e as Map))));
      } else if (res is Map && res['results'] is List) {
        setState(() => _expenses = List<Map<String, dynamic>>.from((res['results'] as List).map((e) => Map<String, dynamic>.from(e as Map))));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    String selectedCategory = 'OTHER';
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(ctx).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Expense', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                // Category chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = selectedCategory == cat['value'];
                    final color = cat['color'] as Color;
                    return ChoiceChip(
                      avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : color),
                      label: Text(cat['label'] as String),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedCategory = cat['value'] as String),
                      selectedColor: color,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (JOD)',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                // Date picker row
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModal(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(ctx).dividerColor),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, size: 18),
                      const SizedBox(width: 12),
                      Text('${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}'),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final api = ApiService();
                        await api.post('/salons/expenses/', data: {
                          'category': selectedCategory,
                          'amount': double.tryParse(amountCtrl.text) ?? 0.0,
                          'expense_date': '${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}',
                          'notes': notesCtrl.text,
                        });
                        if (mounted) AppSnackBar.success(context, 'Expense recorded');
                        _load();
                      } catch (e) {
                        if (mounted) AppSnackBar.error(context, 'Error: $e');
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Expense'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Expense Management'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    // Summary header
                    if (_expenses.isNotEmpty)
                      _SummaryCard(total: _totalAmount, count: _expenses.length),
                    Expanded(
                      child: _expenses.isEmpty
                          ? _buildEmpty(theme)
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                                itemCount: _expenses.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (_, i) => _ExpenseCard(expense: _expenses[i], categories: _categories),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmpty(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined, size: 64, color: theme.hintColor),
        const SizedBox(height: 16),
        Text('No expenses recorded yet', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 8),
        Text('Add expenses to track your salon\'s costs', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    ),
  );
}


class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;
  const _SummaryCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
    ),
    child: Row(
      children: [
        const Icon(Icons.account_balance_wallet_rounded, size: 36, color: Colors.white),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Expenses', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text('${total.toStringAsFixed(2)} JOD', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          Text('$count records', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ],
    ),
  );
}


class _ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final List<Map<String, Object>> categories;
  const _ExpenseCard({required this.expense, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = expense['category'] as String? ?? 'OTHER';
    final catMeta = categories.firstWhere((c) => c['value'] == cat, orElse: () => categories.last);
    final color = catMeta['color'] as Color;
    final icon = catMeta['icon'] as IconData;
    final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
    final label = expense['category_display'] as String? ?? cat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (expense['notes'] != null && (expense['notes'] as String).isNotEmpty)
                  Text(expense['notes'] as String, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(expense['expense_date'] as String? ?? '', style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          Text('${amount.toStringAsFixed(2)} JOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}
