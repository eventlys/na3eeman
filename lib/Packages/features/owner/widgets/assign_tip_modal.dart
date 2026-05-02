import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class AssignTipModal extends StatefulWidget {
  const AssignTipModal({super.key});

  @override
  State<AssignTipModal> createState() => _AssignTipModalState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const AssignTipModal(),
      ),
    );
  }
}

class _AssignTipModalState extends State<AssignTipModal> {
  final List<String> interns = ['Ahmed (Intern)', 'Sarah (Intern)', 'Zaid (Intern)'];
  String? selectedIntern;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("assign_daily_tip".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Intern Selection
            DropdownButtonFormField<String>(
              initialValue: selectedIntern,
              decoration: InputDecoration(
                labelText: "select_intern".tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: interns.map((intern) => DropdownMenuItem(value: intern, child: Text(intern))).toList(),
              onChanged: (value) => setState(() => selectedIntern = value),
              validator: (value) => value == null ? 'Please select an intern' : null,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => (value == null || double.tryParse(value) == null) ? 'Enter a valid amount' : null,
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "optional_note".tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: "assign_tip".tr(),
              onPressed: _handleAssign,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleAssign() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tip of \$${_amountController.text} assigned to $selectedIntern'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
