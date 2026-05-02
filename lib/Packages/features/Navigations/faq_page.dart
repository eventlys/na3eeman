import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../Models/content/faq_model.dart';
import '../../../Services/content_service.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final ContentService _contentService = ContentService();
  int? _expandedIndex;
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
      final List<Map<String, dynamic>> data = await _contentService.getFAQs();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('FAQs & User Guides', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load FAQs', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchFAQs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _faqs.isEmpty
                  ? const Center(child: Text('No FAQs available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _faqs.length,
                      itemBuilder: (context, index) {
                        final faq = _faqs[index];
                        final isExpanded = _expandedIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.almostBlack600 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isExpanded 
                                  ? Theme.of(context).primaryColor 
                                  : (isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.almostBlack50),
                            ),
                            boxShadow: isExpanded ? [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                title: Text(
                                  faq.question,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isExpanded ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                                trailing: Icon(
                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: isExpanded ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Text(
                                    faq.answer,
                                    style: const TextStyle(
                                      color: AppColors.almostBlack300,
                                      height: 1.5,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
