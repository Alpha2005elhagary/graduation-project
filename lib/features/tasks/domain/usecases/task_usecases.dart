import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:breakbot/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:either_dart/either.dart';

class GetTasksUseCase {
  final ITaskRepository repository;
  GetTasksUseCase(this.repository);
  Future<Either<Failure, List<Task>>> call() => repository.getTasks();
}

class AddTaskUseCase {
  final ITaskRepository repository;
  AddTaskUseCase(this.repository);
  Future<Either<Failure, Task>> call({
    required String title,
    required String priority,
    required DateTime deadline,
  }) => repository.addTask(title: title, priority: priority, deadline: deadline);
}

class GetAISuggestedSlotUseCase {
  final ITaskRepository repository;
  GetAISuggestedSlotUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call() =>
      repository.getAISuggestedSlot();
}

class CompleteTaskUseCase {
  final ITaskRepository repository;
  CompleteTaskUseCase(this.repository);
  Future<Either<Failure, void>> call(String taskId) =>
      repository.completeTask(taskId);
}