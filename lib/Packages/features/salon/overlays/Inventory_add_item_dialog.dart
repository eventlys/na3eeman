import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("add_new_item".tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "item_name".tr(),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _countController,
              decoration: InputDecoration(
                labelText: "initial_count".tr(),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter initial count';
                }
                final count = int.tryParse(value);
                if (count == null || count < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "description_optional".tr(),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("cancel".tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'count': int.parse(_countController.text),
                'description': _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
                'productId':
                    0, // You might need to generate this or get from product list
                'salonId': 1, // Default salon ID
              });
            }
          },
          child: Text("add_item".tr()),
        ),
      ],
    );
  }
}
