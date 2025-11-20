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
      title: const Text('Report a Problem'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _problemType,
                decoration: const InputDecoration(
                  labelText: 'Problem Type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'bug',
                    child: Text('Bug Report'),
                  ),
                  DropdownMenuItem(
                    value: 'abuse',
                    child: Text('Usage Abuse'),
                  ),
                  DropdownMenuItem(
                    value: 'feature',
                    child: Text('Feature Request'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Other'),
                  ),
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
                decoration: const InputDecoration(
                  labelText: 'Subject',
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
                decoration: const InputDecoration(
                  labelText: 'Description',
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
          child: const Text('Cancel'),
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

