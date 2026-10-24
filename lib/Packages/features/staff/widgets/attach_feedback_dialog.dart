// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:na3eeman/core/theme/colors.dart';

// import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';

class AttachFeedbackDialog extends StatefulWidget {
  final String staffName;

  const AttachFeedbackDialog({super.key, required this.staffName});

  @override
  State<AttachFeedbackDialog> createState() => _AttachFeedbackDialogState();
}

class _AttachFeedbackDialogState extends State<AttachFeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Shadowing ${widget.staffName}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a brief note/goal for this shadowing session.',
              style: TextStyle(color: AppColors.almostBlack300, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Learning fade technique',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Goal/Feedback is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("cancel".tr()),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text("confirm".tr(), style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Logic would be here to store to database
      // Mocking the success for now
      Navigator.pop(context, _feedbackController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attached to ${widget.staffName}. Notifications sent to Owner & Receptionist.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
