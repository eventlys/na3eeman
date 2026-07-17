import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown.dart';

class LegalDocsPage extends StatefulWidget {
  const LegalDocsPage({super.key});

  @override
  State<LegalDocsPage> createState() => _LegalDocsPageState();
}

class _LegalDocsPageState extends State<LegalDocsPage> {
  Map<String, dynamic> _docsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/docs_data.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        _docsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading docs: $e');
    }
  }

  String _formatName(String key) {
    return key.replaceAll('__', ' ').replaceAll('_', ' ');
  }

  void _openMarkdownPage(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          body: Markdown(data: content, selectable: true),
        ),
      ),
    );
  }

  Widget _buildPageTile(String pageKey, dynamic pageData, String categoryKey) {
    if (pageKey == 'main') return const SizedBox.shrink();

    String content = '';
    if (pageData is String) {
      content = pageData;
    } else if (pageData is Map && pageData['main'] != null) {
      content = pageData['main'];
    } else if (pageData is Map && pageData.isNotEmpty) {
      content = pageData.values.first;
    }

    return ListTile(
      title: Text(_formatName(pageKey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _openMarkdownPage(context, _formatName(pageKey), content);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Legal & Information')),
      body: ListView.builder(
        itemCount: _docsData.keys.length,
        itemBuilder: (context, index) {
          final categoryKey = _docsData.keys.elementAt(index);
          final categoryData = _docsData[categoryKey];

          if (categoryData is Map) {
            final pageKeys = categoryData.keys
                .where((k) => k != 'main')
                .toList();

            return ExpansionTile(
              title: Text(
                _formatName(categoryKey),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: pageKeys.map((pageKey) {
                return _buildPageTile(
                  pageKey,
                  categoryData[pageKey],
                  categoryKey,
                );
              }).toList(),
            );
          } else if (categoryData is String) {
            return ListTile(
              title: Text(
                _formatName(categoryKey),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _openMarkdownPage(
                  context,
                  _formatName(categoryKey),
                  categoryData,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
