import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:na3eeman/Packages/Core/constants/app_roles.dart';

/// Payroll management page (WAJ parity).
/// Accessible to Owner (all types) and Co-Founder.
class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = ApiService();
      final res = await api.get('/salons/payroll/');
      if (res is List) {
        setState(() => _records = List<Map<String, dynamic>>.from(res.map((e) => Map<String, dynamic>.from(e as Map))));
      } else if (res is Map && res['results'] is List) {
        setState(() => _records = List<Map<String, dynamic>>.from((res['results'] as List).map((e) => Map<String, dynamic>.from(e as Map))));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markPaid(int id) async {
    try {
      final api = ApiService();
      await api.post('/salons/payroll/$id/mark_paid/', data: {});
      AppSnackBar.success(context, 'Payroll record marked as paid');
      _load();
    } catch (e) {
      AppSnackBar.error(context, 'Failed: $e');
    }
  }

  void _showCreateDialog() {
    final employeeCtrl = TextEditingController();
    final baseCtrl = TextEditingController();
    final commCtrl = TextEditingController();
    final dedCtrl = TextEditingController();
    final totalCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Payroll Record', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(employeeCtrl, 'Employee ID', TextInputType.number),
              _field(baseCtrl, 'Base Salary (JOD)', TextInputType.number),
              _field(commCtrl, 'Commission Earned', TextInputType.number),
              _field(dedCtrl, 'Deductions', TextInputType.number),
              _field(totalCtrl, 'Total Paid', TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = ApiService();
                final now = DateTime.now();
                await api.post('/salons/payroll/', data: {
                  'employee': int.tryParse(employeeCtrl.text) ?? 0,
                  'period_start': '${now.year}-${now.month.toString().padLeft(2,'0')}-01',
                  'period_end': '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',
                  'base_salary': double.tryParse(baseCtrl.text) ?? 0,
                  'commission_earned': double.tryParse(commCtrl.text) ?? 0,
                  'deductions': double.tryParse(dedCtrl.text) ?? 0,
                  'total_paid': double.tryParse(totalCtrl.text) ?? 0,
                });
                AppSnackBar.success(context, 'Payroll record created');
                _load();
              } catch (e) {
                AppSnackBar.error(context, 'Error: $e');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, TextInputType type) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Payroll Management'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Record'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _records.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _PayrollCard(
                          record: _records[i],
                          onMarkPaid: () => _markPaid(_records[i]['id'] as int),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.payments_outlined, size: 64, color: theme.hintColor),
        const SizedBox(height: 16),
        Text('No payroll records yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 8),
        Text('Tap + to create a payroll record for your staff', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      ],
    ),
  );

  ThemeData get theme => Theme.of(context);
}


class _PayrollCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onMarkPaid;

  const _PayrollCard({required this.record, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = record['is_paid'] as bool? ?? false;
    final total = (record['total_paid'] as num?)?.toDouble() ?? 0.0;
    final name = record['employee_name'] as String? ?? 'Employee';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.green.withOpacity(0.4) : theme.dividerColor,
          width: isPaid ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${record['period_start'] ?? ''} → ${record['period_end'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(isPaid ? 'Paid' : 'Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('Base', '${record['base_salary'] ?? 0} JOD'),
              _stat('Commission', '${record['commission_earned'] ?? 0} JOD'),
              _stat('Deductions', '${record['deductions'] ?? 0} JOD'),
              _stat('Total', '${total.toStringAsFixed(2)} JOD', highlight: true),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onMarkPaid,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Mark as Paid'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {bool highlight = false}) => Column(
    children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: highlight ? AppColors.primary : null)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );
}
