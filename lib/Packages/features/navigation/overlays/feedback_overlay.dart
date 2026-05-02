import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FeedbackOverlay extends StatefulWidget {
  const FeedbackOverlay({super.key});

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("send_feedback".tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: "subject".tr(),
                  hintText: 'Brief description of your feedback',
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
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Feedback',
                  hintText: 'Please share your thoughts about the app...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("rating".tr()),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
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
          onPressed: _submitFeedback,
          child: Text("send_feedback".tr()),
        ),
      ],
    );
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Implement feedback submission logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

