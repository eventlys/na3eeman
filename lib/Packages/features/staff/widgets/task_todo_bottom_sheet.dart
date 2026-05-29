import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/features/intern_provider.dart';
// import '../../../../Models/intern/intern_models.dart';

class TaskTodoBottomSheet extends StatefulWidget {
  const TaskTodoBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskTodoBottomSheet(),
    );
  }

  @override
  State<TaskTodoBottomSheet> createState() => _TaskTodoBottomSheetState();
}

class _TaskTodoBottomSheetState extends State<TaskTodoBottomSheet> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      context.read<InternProvider>().addTask(_taskController.text.trim());
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final internProvider = context.watch<InternProvider>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.almostBlack100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${internProvider.tasks.where((t) => t.isCompleted).length}/${internProvider.tasks.length} tasks completed',
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.almostBlack700
                        : AppColors.almostBlack50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 12),
              IconButtonStyled(icon: Icons.add_rounded, onPressed: _addTask),
            ],
          ),
          const SizedBox(height: 24),
          if (internProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (internProvider.tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 64,
                      color: AppColors.almostBlack100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks for today',
                      style: TextStyle(color: AppColors.almostBlack300),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: internProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = internProvider.tasks[index];
                  return Dismissible(
                    key: Key(task.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => internProvider.deleteTask(task.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.redAccent.withValues(alpha:0.1),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) =>
                            internProvider.toggleTaskCompletion(task),
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.almostBlack300
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: AppColors.almostBlack100,
                        ),
                        onPressed: () => internProvider.deleteTask(task.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
