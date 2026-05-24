import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReportProblemOverlay extends StatefulWidget {
  const ReportProblemOverlay({super.key});

  @override
  State<ReportProblemOverlay> createState() => _ReportProblemOverlayState();
}

class _ReportProblemOverlayState extends State<ReportProblemOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _problemType = 'bug';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("report_problem".tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _problemType,
                decoration: const InputDecoration(labelText: 'Problem Type'),
                items: [
                  DropdownMenuItem(
                    value: 'bug',
                    child: Text("bug_report".tr()),
                  ),
                  DropdownMenuItem(
                    value: 'abuse',
                    child: Text("usage_abuse".tr()),
                  ),
                  DropdownMenuItem(
                    value: 'feature',
                    child: Text("feature_request".tr()),
                  ),
                  DropdownMenuItem(value: 'other', child: Text("other".tr())),
                ],
                onChanged: (value) {
                  setState(() {
                    _problemType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: "subject".tr(),
                  hintText: 'Brief description of the problem',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "description".tr(),
                  hintText: 'Please describe the problem in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the problem';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("cancel".tr()),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          child: const Text('Report Problem'),
        ),
      ],
    );
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Implement problem report submission logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem reported successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
