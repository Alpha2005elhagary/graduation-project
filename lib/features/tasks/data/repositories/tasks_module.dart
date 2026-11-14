import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';


import 'package:breakbot/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:breakbot/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:breakbot/features/tasks/domain/usecases/task_usecases.dart';
import 'package:breakbot/features/tasks/presentation/viewmodels/tasks_viewmodel.dart';

void configureTasksDependencies() {
  getIt.registerLazySingleton<ITaskRepository>(
    () => TaskRepositoryImpl(storage: getIt<LocalStorageManager>()),
  );
  getIt.registerLazySingleton<GetTasksUseCase>(
    () => GetTasksUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerLazySingleton<AddTaskUseCase>(
    () => AddTaskUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerLazySingleton<GetAISuggestedSlotUseCase>(
    () => GetAISuggestedSlotUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerLazySingleton<CompleteTaskUseCase>(
    () => CompleteTaskUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerLazySingleton<TasksViewModel>(
    () => TasksViewModel(
      getTasksUseCase: getIt<GetTasksUseCase>(),
      addTaskUseCase: getIt<AddTaskUseCase>(),
      getAISuggestedSlotUseCase: getIt<GetAISuggestedSlotUseCase>(),
      completeTaskUseCase: getIt<CompleteTaskUseCase>(),
    ),
  );
}