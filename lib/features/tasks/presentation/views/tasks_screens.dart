import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final storage = getIt<LocalStorageManager>();
  List<Task> tasks = [];
  String newTaskTitle = '';
  String newTaskPriority = 'medium';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      tasks = storage.getTasks();
    });
  }

  void _addTask() {
    if (newTaskTitle.trim().isEmpty) return;
    final task = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: newTaskTitle,
      priority: newTaskPriority,
      deadline: DateTime.now().add(const Duration(days: 1)),
    );
    final updated = List<Task>.from(tasks)..add(task);
    storage.saveTasks(updated);
    setState(() {
      tasks = updated;
      newTaskTitle = '';
    });
  }

  void _toggleTask(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final updated = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
    final updatedList = List<Task>.from(tasks).. [index] = updated;
    storage.saveTasks(updatedList);
    setState(() {
      tasks = updatedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((t) => !t.isCompleted).length;
    final completed = tasks.where((t) => t.isCompleted).length;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Header with stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المهام',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: AppColors.primaryContainer, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statChip('معلقة', pending.toString(), Icons.pending_actions, Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statChip('منتهية', completed.toString(), Icons.check_circle, Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add task form
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'اسم المهمة الجديدة...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => newTaskTitle = v,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الأولوية:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, )),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: newTaskPriority,
                      items: const [
                        DropdownMenuItem(value: 'high', child: Text('عالية', style: TextStyle())),
                        DropdownMenuItem(value: 'medium', child: Text('متوسطة', style: TextStyle())),
                        DropdownMenuItem(value: 'low', child: Text('منخفضة', style: TextStyle())),
                      ],
                      onChanged: (v) => newTaskPriority = v ?? 'medium',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tasks list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.task, size: 64, color: AppColors.outline),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد مهام',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _taskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => _toggleTask(task.id),
          activeColor: AppColors.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? AppColors.outline : AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(task.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _priorityLabel(task.priority),
                style: TextStyle(
                  color: _priorityColor(task.priority),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${task.deadline.day}/${task.deadline.month}',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            final updatedList = tasks.where((t) => t.id != task.id).toList();
            storage.saveTasks(updatedList);
            setState(() {
              tasks = updatedList;
            });
          },
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'high': return 'عالية';
      case 'medium': return 'متوسطة';
      default: return 'منخفضة';
    }
  }
}
