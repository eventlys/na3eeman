import 'package:flutter/material.dart';
import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Models/salon/voucher_model.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/widgets/buttons/styled_buttons.dart';
import 'package:intl/intl.dart';

class VoucherManagementPage extends StatefulWidget {
  const VoucherManagementPage({super.key});

  @override
  State<VoucherManagementPage> createState() => _VoucherManagementPageState();
}

class _VoucherManagementPageState extends State<VoucherManagementPage> {
  final ApiService _apiService = ApiService();
  List<Voucher> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final owner = context.read<OwnerProvider>();
    if (owner.activeSalonId == null) return;

    try {
      final List<dynamic> vouchers = await _apiService.getSalonVouchers(owner.activeSalonId!);
      setState(() {
        _vouchers = vouchers.map((e) => Voucher.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vouchers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prepaid Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateVoucherDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? _buildEmptyState()
              : _buildVoucherList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateVoucherDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_num_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text('No vouchers found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Create gift cards or prepaid service vouchers.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVoucherList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _vouchers.length,
      itemBuilder: (context, index) {
        final voucher = _vouchers[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: voucher.isRedeemed ? AppColors.almostBlack100 : Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (voucher.isRedeemed ? Colors.grey : Theme.of(context).primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_rounded,
                  color: voucher.isRedeemed ? Colors.grey : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.serviceName ?? 'Value: ${voucher.fixedAmount} JOD',
                      style: TextStyle(color: AppColors.almostBlack300, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(voucher),
                  const SizedBox(height: 4),
                  Text(
                    'Exp: ${DateFormat('MMM dd').format(voucher.expiresAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Voucher voucher) {
    final bool isExpired = voucher.expiresAt.isBefore(DateTime.now());
    final Color color = voucher.isRedeemed ? Colors.grey : (isExpired ? AppColors.error : AppColors.success);
    final String label = voucher.isRedeemed ? 'Redeemed' : (isExpired ? 'Expired' : 'Active');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  void _showCreateVoucherDialog() {
    // In a real app, this would be a full form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Voucher'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quick Issue Wizard'),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Fixed Amount (JOD)')),
            TextField(decoration: InputDecoration(labelText: 'Receiver Email (Optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher issuance coming in next update.')));
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}
