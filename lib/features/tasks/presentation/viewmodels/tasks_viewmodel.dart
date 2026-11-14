import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:breakbot/features/tasks/domain/usecases/task_usecases.dart';
import 'package:breakbot/shared/models/base_viewmodel.dart';

class TasksViewModel extends BaseViewModel {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final GetAISuggestedSlotUseCase getAISuggestedSlotUseCase;
  final CompleteTaskUseCase completeTaskUseCase;

  TasksViewModel({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.getAISuggestedSlotUseCase,
    required this.completeTaskUseCase,
  });

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    setLoading(true);
    clearError();
    final result = await getTasksUseCase();
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (tasks) => _tasks = tasks,
    );
    setLoading(false);
  }

  Future<void> addTask({
    required String title,
    required String priority,
    required DateTime deadline,
  }) async {
    setLoading(true);
    clearError();
    final result = await addTaskUseCase(
      title: title,
      priority: priority,
      deadline: deadline,
    );
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (task) => _tasks.add(task),
    );
    setLoading(false);
  }

  Future<Map<String, dynamic>?> getAISuggestedSlot() async {
    setLoading(true);
    clearError();
    final result = await getAISuggestedSlotUseCase();
    Map<String, dynamic>? slot;
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (data) => slot = data,
    );
    setLoading(false);
    return slot;
  }

  Future<void> completeTask(String taskId) async {
    setLoading(true);
    clearError();
    final result = await completeTaskUseCase(taskId);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (_) {
        _tasks = _tasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(isCompleted: true);
          }
          return t;
        }).toList();
      },
    );
    setLoading(false);
  }
}
