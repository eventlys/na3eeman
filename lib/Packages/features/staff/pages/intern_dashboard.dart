import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/attach_feedback_dialog.dart';
import '../widgets/task_todo_bottom_sheet.dart';
import '../widgets/monthly_target_widget.dart';
import '../../../../Providers/features/intern_provider.dart';
import '../../../../Providers/features/expert_provider.dart';

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  bool isNumericView = true;
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
      final expertProvider = context.read<ExpertProvider>();
      
      await internProvider.initInternDashboard(null);
      await expertProvider.loadExperts(refresh: true, salonId: internProvider.salonId);
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
    final expertProvider = context.watch<ExpertProvider>();

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
              await internProvider.fetchTargets();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mentorship Status Card
                  _buildMentorshipStatus(context, internProvider.assignedMentor),

                  const SizedBox(height: 32),

                  // Active Assignments / Mentors Section
                  DashboardSectionHeader(
                    title: "active_assignments".tr(),
                    actionText: expertProvider.isLoading ? "loading".tr() : "refresh".tr(),
                    onPressed: () => expertProvider.loadExperts(refresh: true, salonId: internProvider.salonId),
                  ),
                  const SizedBox(height: 16),
                  if (expertProvider.isLoading && expertProvider.experts.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildMentorsList(context, expertProvider, internProvider),

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
            color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                const Text('Learning Journey Under', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  mentorName ?? 'Explore Mentors Below', 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
    final displayedTasks = isShowingAllTasks ? provider.tasks : provider.tasks.take(5).toList();

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
                          value: totalCount == 0 ? 0 : completedCount / totalCount,
                          backgroundColor: AppColors.almostBlack100.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        totalCount == 0 ? '0%' : '${((completedCount / totalCount) * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Task Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount of $totalCount tasks done for today',
                          style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isTasksExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, 
                    color: AppColors.almostBlack300
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
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? AppColors.almostBlack300 : null,
                    ),
                  ),
                  activeColor: Theme.of(context).primaryColor,
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
            if (isShowingAllTasks || !hasMore)
              const SizedBox(height: 10),
          ]
        ],
      ),
    );
  }

  Widget _buildTargetsList(InternProvider provider) {
    if (provider.targets.isEmpty) {
      return const Center(child: Text('No targets set for this month', style: TextStyle(color: AppColors.almostBlack300)));
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.targets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return MonthlyTargetWidget(
            target: provider.targets[index],
            isNumericView: isNumericView,
          );
        },
      ),
    );
  }

  Widget _buildMentorsList(BuildContext context, ExpertProvider bProvider, InternProvider iProvider) {
    if (bProvider.experts.isEmpty && !bProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.almostBlack700 : AppColors.almostBlack50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline_rounded, color: AppColors.almostBlack300, size: 40),
            SizedBox(height: 12),
            Text('No experts found in the salon', style: TextStyle(color: AppColors.almostBlack300)),
          ],
        ),
      );
    }

    final allTasksCompleted = iProvider.tasks.every((t) => t.isCompleted);
    final isShadowingAnyone = iProvider.assignedMentor != null;

    return Column(
      children: bProvider.experts.map((mentor) {
        final isShadowing = iProvider.assignedMentor == mentor.name;
        return _buildMentorCard(
          context, 
          iProvider, 
          mentor.id, 
          mentor.name, 
          mentor.specialties.isNotEmpty ? mentor.specialties.first : 'Staff Member', 
          mentor.isActive ? 'Active' : 'Inactive', 
          isShadowing,
          isShadowingAnyone,
          allTasksCompleted
        );
      }).toList(),
    );
  }

  Widget _buildMentorCard(
    BuildContext context, 
    InternProvider iProvider, 
    String id,
    String name, 
    String role, 
    String status, 
    bool isShadowing,
    bool isShadowingAnyone,
    bool allTasksCompleted
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canAttach = !isShadowingAnyone || allTasksCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isShadowing ? Theme.of(context).primaryColor.withOpacity(0.05) : (isDark ? AppColors.almostBlack700 : AppColors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isShadowing 
            ? Theme.of(context).primaryColor.withOpacity(0.3) 
            : (isDark ? AppColors.almostBlack100.withOpacity(0.1) : AppColors.almostBlack50)
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$role • $status', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          if (isShadowing)
            const ShadowingBadge()
          else
            Column(
              children: [
                OutlinedButton(
                  onPressed: canAttach ? () => _attachToMentor(context, iProvider, id, name) : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: canAttach ? Theme.of(context).primaryColor : AppColors.almostBlack100),
                  ),
                  child: const Text('Attach', style: TextStyle(fontSize: 12)),
                ),
                if (!canAttach)
                  const Text('Finish Tasks', style: TextStyle(fontSize: 8, color: Colors.redAccent)),
              ],
            ),
        ],
      ),
    );
  }

  void _attachToMentor(BuildContext context, InternProvider provider, String mentorId, String mentorName) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => AttachFeedbackDialog(staffName: mentorName),
    );
    
    if (feedback != null) {
      try {
        await provider.attachToMentor(int.tryParse(mentorId) ?? 0, feedback, mentorName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Succesfully attached to $mentorName')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update mentor: $e')),
          );
        }
      }
    }
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

class ShadowingBadge extends StatelessWidget {
  const ShadowingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SHADOWING',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

