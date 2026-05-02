import 'package:flutter/material.dart';
import 'package:na3eeman/Models/loyalty/feedback_model.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:intl/intl.dart';

class FeedbackReviewPage extends StatefulWidget {
  const FeedbackReviewPage({super.key});

  @override
  State<FeedbackReviewPage> createState() => _FeedbackReviewPageState();
}

class _FeedbackReviewPageState extends State<FeedbackReviewPage> {
  List<HelpFeedback> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final List<HelpFeedback> data = await api.getFeedback();
      setState(() {
        _feedbacks = data;
        // Sort by date descending
        _feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      AppSnackBar.error(context, 'Failed to load feedback');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reviewFeedback(int id, String status) async {
    try {
      final api = ApiService();
      await api.reviewFeedback(id, status);
      AppSnackBar.success(context, status == 'valuable' ? 'Feedback marked as valuable! Points awarded.' : 'Feedback marked as read.');
      _loadFeedback();
    } catch (e) {
      AppSnackBar.error(context, 'Failed to update feedback status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedback,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbacks.isEmpty
              ? const Center(child: Text('No feedback entries found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = _feedbacks[index];
                    return _FeedbackCard(
                      feedback: feedback,
                      onMarkRead: () => _reviewFeedback(feedback.id, 'read'),
                      onMarkValuable: () => _reviewFeedback(feedback.id, 'valuable'),
                    );
                  },
                ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final HelpFeedback feedback;
  final VoidCallback onMarkRead;
  final VoidCallback onMarkValuable;

  const _FeedbackCard({
    required this.feedback,
    required this.onMarkRead,
    required this.onMarkValuable,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('MMM d, yyyy • HH:mm').format(feedback.createdAt);
    
    Color statusColor;
    String statusText;
    switch (feedback.status) {
      case 'valuable':
        statusColor = Colors.amber;
        statusText = 'VALUABLE';
        break;
      case 'read':
        statusColor = Colors.grey;
        statusText = 'READ';
        break;
      default:
        statusColor = Theme.of(context).primaryColor;
        statusText = 'PENDING';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'From: ${feedback.userName ?? "Anonymous"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              feedback.content,
              style: const TextStyle(fontSize: 15),
            ),

            if (feedback.status == 'pending') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onMarkRead,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark as Read'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onMarkValuable,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Mark Valuable'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
