import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:either_dart/either.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> addTask({
    required String title,
    required String priority,
    required DateTime deadline,
  });
  Future<Either<Failure, Map<String, dynamic>>> getAISuggestedSlot();
  Future<Either<Failure, void>> completeTask(String taskId);
}