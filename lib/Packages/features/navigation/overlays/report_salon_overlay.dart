import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
// import 'package:easy_localization/easy_localization.dart';

class ReportSalonOverlay extends StatefulWidget {
  const ReportSalonOverlay({super.key});

  @override
  State<ReportSalonOverlay> createState() => _ReportSalonOverlayState();
}

class _ReportSalonOverlayState extends State<ReportSalonOverlay> {
  final List<File> _evidenceFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _evidenceFiles.add(File(image.path));
        });
        if (mounted) {
          AppSnackBar.success(context, 'Image added to evidence');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _evidenceFiles.add(File(result.files.single.path!));
        });
        if (mounted) {
          AppSnackBar.success(context, 'File added to evidence');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to pick file: $e');
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _salonNameController = TextEditingController();
  final _salonUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIssueType = 'Fake Products';
  final List<String> _issueTypes = [
    'Fake Products',
    'Poor Quality',
    'Wrong Description',
    'Late Delivery',
    'No Delivery',
    'Rude Behavior',
    'Overpricing',
    'Safety Concern',
    'Other',
  ];

  @override
  void dispose() {
    _salonNameController.dispose();
    _salonUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Implement report submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: (RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(maxHeight: 650),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Help us maintain a safe marketplace by reporting salons that violate our policies.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIssueType,
                      items: _issueTypes.map((String type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedIssueType = newValue!;
                        });
                      },
                      dropdownColor: Color(0xffffffff),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      decoration: InputDecoration(
                        labelText: "issue_type".tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(
                          Icons.warning,
                          color: Color(0xb3c25858),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salonNameController,
                      decoration: InputDecoration(
                        labelText: "salon_name".tr(),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store, color: Color(0xb3c25858)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter salon name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Issue Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the issue';
                        }
                        if (value.length < 20) {
                          return 'Please provide more details (at least 20 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildEvidenceSection(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x80c25858),
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "submit_report".tr(),
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x4dffffff),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0x80ffffff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evidence (Optional but helpful)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Screenshots, order numbers, or any other evidence that supports your report.',
            style: TextStyle(fontSize: 12, color: Color(0x80000000)),
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
          if (_evidenceFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _evidenceFiles.asMap().entries.map((entry) {
                  return Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.path.split('/').last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _evidenceFiles.removeAt(entry.key);
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.photo,
                    color: Color(0xb3c25858),
                    size: 18,
                  ),
                  label: const Text('Add Screenshot'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(
                    Icons.attach_file,
                    color: Color(0xb3c25858),
                    size: 18,
                  ),
                  label: const Text('Add File'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
