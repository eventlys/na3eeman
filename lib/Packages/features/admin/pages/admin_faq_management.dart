// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Models/content/faq_model.dart';

class AdminFAQManagementPage extends StatefulWidget {
  const AdminFAQManagementPage({super.key});

  @override
  State<AdminFAQManagementPage> createState() => _AdminFAQManagementPageState();
}

class _AdminFAQManagementPageState extends State<AdminFAQManagementPage> {
  List<FAQModel> _faqs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final List<dynamic> data = await ApiService().getFAQs();
      setState(() {
        _faqs = data.map((e) => FAQModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFAQ(int id) async {
    try {
      await ApiService().deleteFAQ(id);
      _fetchFAQs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQ deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete FAQ: $e')));
      }
    }
  }

  void _showFAQDialog([FAQModel? faq]) {
    final questionController = TextEditingController(text: faq?.question);
    final answerController = TextEditingController(text: faq?.answer);
    final orderController = TextEditingController(
      text: faq?.order.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(faq == null ? 'Add FAQ' : 'Edit FAQ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(labelText: 'Display Order'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'question': questionController.text,
                'answer': answerController.text,
                'order': int.tryParse(orderController.text) ?? 0,
              };

              try {
                if (faq == null) {
                  await ApiService().createFAQ(data);
                } else {
                  await ApiService().updateFAQ(faq.id!, data);
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchFAQs();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage FAQs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showFAQDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchFAQs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  ElevatedButton(
                    onPressed: _fetchFAQs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _faqs.isEmpty
          ? const Center(child: Text('No FAQs found.'))
          : ListView.builder(
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      faq.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      faq.answer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showFAQDialog(faq),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete FAQ'),
                                content: const Text(
                                  'Are you sure you want to delete this FAQ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteFAQ(faq.id!);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
