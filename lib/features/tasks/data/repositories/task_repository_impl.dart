import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:breakbot/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:either_dart/either.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final LocalStorageManager storage;

  TaskRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = storage.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> addTask({
    required String title,
    required String priority,
    required DateTime deadline,
  }) async {
    try {
      final task = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        priority: priority,
        deadline: deadline,
      );
      final tasks = storage.getTasks();
      final updatedList = List<Task>.from(tasks)..add(task);
      await storage.saveTasks(updatedList);
      return Right(task);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAISuggestedSlot() async {
    try {
      return Right({
        'suggested_slot': '${DateTime.now().hour}:00',
        'reason': 'وقت مقترح بناءً على عاداتك',
      });
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeTask(String taskId) async {
    try {
      final tasks = storage.getTasks();
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index == -1) {
        return Left(UnknownFailure(message: 'لا توجد المهمة'));
      }
      final task = tasks[index];
      final updated = task.copyWith(isCompleted: true);
      final updatedList = List<Task>.from(tasks).. [index] = updated;
      await storage.saveTasks(updatedList);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
