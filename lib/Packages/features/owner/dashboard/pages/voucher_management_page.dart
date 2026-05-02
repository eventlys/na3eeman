import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Models/salon/voucher_model.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/widgets/buttons/styled_buttons.dart';
import 'dart:math';

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
    final salonId = owner.activeSalonId ?? 1;

    try {
      setState(() => _isLoading = true);
      // In real scenario, await _apiService.getSalonVouchers(salonId);
      // For now, since API for vouchers might be under development, we keep it empty
      // but remove the hardcoded mock data.
      final response = await _apiService.get('/salons/vouchers/', queryParams: {'salon': salonId});
      final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
      
      setState(() {
        _vouchers = data.map((e) => Voucher.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _vouchers = [];
          _isLoading = false;
        });
      }
    }
  }

  String _generateVoucherCode(int salonId, int voucherId) {
    final random = Random().nextInt(9000) + 1000; // 4 random digits
    final sId = salonId.toString().padLeft(4, '0').substring(0, 4);
    final vId = voucherId.toString().padLeft(2, '0').substring(0, 2);
    return '$sId$random$vId'; // 10 digits
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Prepaid Vouchers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final v = _vouchers[index];
                    return _buildVoucherCard(v, isDark);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoucherDialog(),
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
          Icon(Icons.confirmation_num_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('No vouchers found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Create gift cards or prepaid service vouchers.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(Voucher v, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  v.code,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showVoucherDialog(voucher: v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('Value', '${v.fixedAmount} JOD', Icons.payments_rounded),
              const SizedBox(width: 24),
              _buildInfoItem('Valid For', '${v.expiresAt.difference(DateTime.now()).inDays} Days', Icons.timer_rounded),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Send to Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: [
                  _buildSocialIcon(Icons.message_rounded, Colors.blue),
                  const SizedBox(width: 12),
                  _buildSocialIcon(Icons.phone_iphone_rounded, Colors.green),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.almostBlack300),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  void _showVoucherDialog({Voucher? voucher}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceCtrl = TextEditingController(text: voucher?.fixedAmount.toString() ?? '');
    final daysCtrl = TextEditingController(text: '30');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32, left: 32, right: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              voucher == null ? 'Create New Voucher' : 'Edit Voucher',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildDialogField('Voucher Value (JOD)', priceCtrl, Icons.payments_rounded, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildDialogField('Valid For (Days)', daysCtrl, Icons.timer_rounded, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: voucher == null ? 'Create Voucher' : 'Update Voucher',
                onPressed: () {
                  Navigator.pop(context);
                  _loadVouchers();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.almostBlack300)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.almostBlack50.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}