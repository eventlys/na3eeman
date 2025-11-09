import 'package:flutter/material.dart';

class ContactUsOverlay extends StatefulWidget {
  const ContactUsOverlay({super.key});

  @override
  State<ContactUsOverlay> createState() => _ContactUsOverlayState();
}

class _ContactUsOverlayState extends State<ContactUsOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  final List<String> _categories = [
    'General Inquiry',
    'Technical Support',
    'Billing Issue',
    'Feature Request',
    'Bug Report',
    'Partnership',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Implement form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildContactInfo(),
                      const SizedBox(height: 20),
                      _buildFormFields(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x80806C99),
                  shadowColor: Colors.transparent,
                  side: BorderSide(color: Color(0xff806C99)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x4dffffff),
        border: Border.all(color: Color(0x80ffffff)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.email, size: 16, color: Color(0x80000000)),
              SizedBox(width: 8),
              Text('support@yourapp.com', style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Color(0x80000000)),
              SizedBox(width: 8),
              Text('+1 (555) 123-4567', style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Color(0x80000000)),
              SizedBox(width: 8),
              Text('Mon-Fri 9:00 AM - 6:00 PM', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          items: _categories.map((String category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
          dropdownColor: Color(0xffffffff),
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Category',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person, color: Color(0xFF806C99)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email, color: Color(0xFF806C99)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: 'Subject',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.subject, color: Color(0xFF806C99)),
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
          decoration: const InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your message';
            }
            if (value.length < 10) {
              return 'Message must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}

