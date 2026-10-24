// ignore_for_file: unused_element
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/task_todo_bottom_sheet.dart';
import '../widgets/time_clock_widget.dart';
import '../../../../Providers/features/intern_provider.dart';

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  bool isTasksExpanded = false;
  bool isShowingAllTasks = false;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);

    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final internProvider = context.read<InternProvider>();
      await internProvider.initInternDashboard();
    });
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    sidebarController.toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final internProvider = context.watch<InternProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                children: [
                  IconButtonStyled(
                    icon: Icons.menu_rounded,
                    onPressed: _toggleSidebar,
                  ),
                ],
              ),
            ),
            actions: [
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => NotificationsBottomSheet.show(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await internProvider.fetchTasks();
              await internProvider.fetchInternActivity();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Clock Section
                  const TimeClockWidget(),

                  const SizedBox(height: 32),

                  // ToDo Tasks Section
                  DashboardSectionHeader(
                    title: "daily_tasks".tr(),
                    actionText: "add_task".tr(),
                    onPressed: () => _showAddTaskSheet(context),
                  ),
                  const SizedBox(height: 16),
                  if (internProvider.isLoading && internProvider.tasks.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildTaskPreview(context, internProvider),

                  const SizedBox(height: 32),
                  const FeedbackSection(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  Widget _buildMentorshipStatus(BuildContext context, String? mentorName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.school_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Journey Under',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  mentorName ?? 'Explore Mentors Below',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (mentorName != null)
            const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildTaskPreview(BuildContext context, InternProvider provider) {
    final completedCount = provider.tasks.where((t) => t.isCompleted).length;
    final totalCount = provider.tasks.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasMore = totalCount > 5;
    final displayedTasks = isShowingAllTasks
        ? provider.tasks
        : provider.tasks.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              isTasksExpanded = !isTasksExpanded;
              if (!isTasksExpanded) isShowingAllTasks = false;
            }),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: totalCount == 0
                              ? 0
                              : completedCount / totalCount,
                          backgroundColor: AppColors.almostBlack100.withValues(
                            alpha: 0.1,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        totalCount == 0
                            ? '0%'
                            : '${((completedCount / totalCount) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Completion',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount of $totalCount tasks done for today',
                          style: const TextStyle(
                            color: AppColors.almostBlack300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isTasksExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.almostBlack300,
                  ),
                ],
              ),
            ),
          ),
          if (isTasksExpanded && totalCount > 0) ...[
            const Divider(height: 1, indent: 20, endIndent: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedTasks.length,
              itemBuilder: (context, index) {
                final task = displayedTasks[index];
                return CheckboxListTile(
                  value: task.isCompleted,
                  onChanged: (val) async {
                    if (val != null) {
                      await provider.toggleTaskStatus(task.id, val);
                    }
                  },
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? AppColors.almostBlack300 : null,
                    ),
                  ),
                  activeColor: Theme.of(context).primaryColor,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
            if (hasMore && !isShowingAllTasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextButton(
                  onPressed: () => setState(() => isShowingAllTasks = true),
                  child: const Text('Show more'),
                ),
              ),
            if (isShowingAllTasks || !hasMore) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskTodoBottomSheet(),
    );
  }
}

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final internProvider = context.watch<InternProvider>();
    final feedbacks = internProvider.feedbacks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: "recent_feedback".tr(),
          actionText: "view_all".tr(),
          onPressed: () {
            Navigator.pushNamed(context, '/feedback_page');
          },
        ),
        const SizedBox(height: 16),
        if (feedbacks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.almostBlack700
                  : AppColors.almostBlack50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  size: 48,
                  color: AppColors.almostBlack300.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "No feedback yet",
                  style: TextStyle(
                    color: AppColors.almostBlack300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: feedbacks.take(3).length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.almostBlack700
                      : AppColors.almostBlack50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            feedback.expertName?[0] ?? 'E',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback.expertName ?? "Expert",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(feedback.createdAt),
                                style: const TextStyle(
                                  color: AppColors.almostBlack300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const ShadowingBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback.feedbackText,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.almostBlack400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class ShadowingBadge extends StatelessWidget {
  const ShadowingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'SHADOWING',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
