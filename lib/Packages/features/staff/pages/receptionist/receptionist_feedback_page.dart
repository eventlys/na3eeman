import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';

class ReceptionistFeedbackPage extends StatefulWidget {
  final bool startWithStaff;
  const ReceptionistFeedbackPage({super.key, this.startWithStaff = false});

  @override
  State<ReceptionistFeedbackPage> createState() => _ReceptionistFeedbackPageState();
}

class _ReceptionistFeedbackPageState extends State<ReceptionistFeedbackPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'All'; // All, Top 5 Positive, Top 5 Negative

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.startWithStaff ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks & Ratings', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "customer_feedback".tr()),
            Tab(text: 'Staff Feedback'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Top 5 Positive', child: Text('Top 5 Positive 👍')),
              const PopupMenuItem(value: 'Top 5 Negative', child: Text('Top 5 Negative 👎')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackList(isStaff: false),
          _buildFeedbackList(isStaff: true),
        ],
      ),
    );
  }

  Widget _buildFeedbackList({required bool isStaff}) {
    // Apply filters string constraints placeholders
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeedbackCard(
          author: isStaff ? 'Karim (Expert)' : 'Mohammed Ali',
          content: isStaff ? 'The salon needs new towels as currently stock feeling heavy.' : 'Very nice haircut and friendly staff! Highly recommend!',
          rating: isStaff ? 4.0 : 5.0,
          target: isStaff ? 'To Owner' : 'To Expert Jafar',
          dateTime: 'Today @ 11:30 AM',
        ),
        _buildFeedbackCard(
          author: isStaff ? 'Jafar (Expert)' : 'Zaid Hassan',
          content: isStaff ? 'Air conditioning requires maintenance session soon.' : 'Waiting time was a bit long but service felt premium.',
          rating: isStaff ? 3.5 : 4.0,
          target: isStaff ? 'To Salon' : 'To Salon',
          dateTime: 'Yesterday',
        ),
      ],
    );
  }

  Widget _buildFeedbackCard({
    required String author,
    required String content,
    required double rating,
    required String target,
    required String dateTime,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardCard(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 4),
                  Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(target, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('"$content"', style: const TextStyle(fontStyle: FontStyle.italic)),
          const Divider(height: 24),
          Text(dateTime, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
        ],
      ),
    ),
    );
  }
}
