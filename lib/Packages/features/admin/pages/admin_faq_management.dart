// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/admin_service_provider.dart';
import '../../../../Models/content/faq_model.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';

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
      final List<dynamic> data = await context
          .read<AdminServiceProvider>()
          .getFAQs();
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
      await context.read<AdminServiceProvider>().deleteFAQ(id);
      _fetchFAQs();
      if (mounted) {
        AppSnackBar.success(context, 'FAQ deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to delete FAQ: $e');
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
            child: Text('cancel'.tr()),
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
                  await context.read<AdminServiceProvider>().createFAQ(data);
                } else {
                  await context.read<AdminServiceProvider>().updateFAQ(
                    faq.id!,
                    data,
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchFAQs();
                }
              } catch (e) {
                if (mounted) {
                  AppSnackBar.error(context, 'Error: $e');
                }
              }
            },
            child: Text('save'.tr()),
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
        title: Text('manage_faqs'.tr()),
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
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            )
          : _faqs.isEmpty
          ? Center(child: Text('no_faqs_found'.tr()))
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
                                title: Text('delete_faq'.tr()),
                                content: const Text(
                                  'Are you sure you want to delete this FAQ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('cancel'.tr()),
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
