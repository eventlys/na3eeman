import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Models/salon/payment_config_model.dart';
import '../../../../../../core/theme/colors.dart';

class RevenueControlsPage extends StatefulWidget {
  const RevenueControlsPage({super.key});

  @override
  State<RevenueControlsPage> createState() => _RevenueControlsPageState();
}

class _RevenueControlsPageState extends State<RevenueControlsPage> {
  final ApiService _apiService = ApiService();
  SalonPaymentConfig? _config;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final owner = context.read<OwnerProvider>();
    if (owner.activeSalonId == null) return;

    try {
      final config = await _apiService.getSalonPaymentConfig(owner.activeSalonId!);
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_loading_config'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_config == null) return;
    setState(() => _isSaving = true);

    try {
      await _apiService.updateSalonPaymentConfig(_config!.salonId, _config!.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('config_saved_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_saving_config'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('revenue_payment_controls'.tr()),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(
              onPressed: _saveConfig,
              child: Text('save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMethodSection(),
          const SizedBox(height: 32),
          _buildDepositSection(),
          const SizedBox(height: 32),
          _buildPolicySection(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMethodSection() {
    return _buildCard(
      title: 'accepted_payment_methods'.tr(),
      icon: Icons.payments_rounded,
      child: Column(
        children: [
          _buildToggle(
            'allow_cash'.tr(),
            'customers_pay_after'.tr(),
            _config!.allowCash,
            (v) => setState(() => _config = _config!.copyWith(allowCash: v)),
          ),
          _buildToggle(
            'allow_online'.tr(),
            'requires_integration'.tr(),
            _config!.allowOnline,
            (v) => setState(() => _config = _config!.copyWith(allowOnline: v)),
          ),
          _buildToggle(
            'allow_cliq'.tr(),
            'jordan_instant_transfer'.tr(),
            _config!.allowCliq,
            (v) => setState(() => _config = _config!.copyWith(allowCliq: v)),
          ),
          _buildToggle(
            'allow_loyalty_points'.tr(),
            'allow_redemption'.tr(),
            _config!.allowPoints,
            (v) => setState(() => _config = _config!.copyWith(allowPoints: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositSection() {
    return _buildCard(
      title: 'prepayment_deposit_rules'.tr(),
      icon: Icons.security_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'define_deposit_rules'.tr(),
            style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  'percentage'.tr(),
                  _config!.depositType == DepositType.percent,
                  () => setState(() => _config = _config!.copyWith(depositType: DepositType.percent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceChip(
                  'fixed_amount'.tr(),
                  _config!.depositType == DepositType.fixed,
                  () => setState(() => _config = _config!.copyWith(depositType: DepositType.fixed)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _config!.depositValue.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _config!.depositType == DepositType.percent ? 'percentage'.tr() : 'amount_jod'.tr(),
              prefixIcon: Icon(_config!.depositType == DepositType.percent ? Icons.percent_rounded : Icons.money_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) {
              final val = double.tryParse(v) ?? 0;
              setState(() => _config = _config!.copyWith(depositValue: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection() {
    return _buildCard(
      title: 'business_policies'.tr(),
      icon: Icons.gavel_rounded,
      child: Column(
        children: [
          _buildNumberField(
            'cancellation_window'.tr(),
            'cancellation_subtitle'.tr(),
            _config!.cancellationWindowHours,
            (v) => setState(() => _config = _config!.copyWith(cancellationWindowHours: v)),
          ),
          const Divider(height: 32),
          _buildNumberField(
            'no_show_tolerance'.tr(),
            'no_show_subtitle'.tr(),
            _config!.noShowEnforcementThreshold,
            (v) => setState(() => _config = _config!.copyWith(noShowEnforcementThreshold: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Theme.of(context).primaryColor : AppColors.almostBlack100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.almostBlack400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String title, String subtitle, int value, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.almostBlack300)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (v) {
              final val = int.tryParse(v) ?? 0;
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
